from flask import Flask, render_template, request, jsonify, send_from_directory
from flask_cors import CORS
import json
import os
from datetime import datetime
import openai
from functools import wraps

app = Flask(__name__)
CORS(app)

# Initialize data storage
DATA_FILE = 'survey_data.json'
SETTINGS_FILE = 'azure_settings.json'

def load_data():
    if os.path.exists(DATA_FILE):
        with open(DATA_FILE, 'r') as f:
            return json.load(f)
    return {'surveys': []}

def save_data(data):
    with open(DATA_FILE, 'w') as f:
        json.dump(data, f)

def load_settings():
    if os.path.exists(SETTINGS_FILE):
        with open(SETTINGS_FILE, 'r') as f:
            return json.load(f)
    return None

def save_settings(settings):
    with open(SETTINGS_FILE, 'w') as f:
        json.dump(settings, f)

def configure_azure_client():
    settings = load_settings()
    if not settings:
        return None, None
    
    client = openai.AzureOpenAI(
        azure_endpoint=settings['base_url'],
        api_key=settings['api_key'],
        api_version=settings['api_version']
    )
    return client, settings['deployment_name']

def classify_response(client, deployment_name, response):
    """Classify a single survey response using Azure OpenAI."""
    try:
        prompt = f"""You are an HR analytics expert. Analyze and categorize the following employee feedback.
        Return ONLY a JSON object with the following structure, no other text:
        {{
            "culture_categories": ["category1", "category2"],
            "suggestion_categories": ["category1", "category2"],
            "sentiment": "Positive/Neutral/Negative",
            "key_themes": ["theme1", "theme2"]
        }}

        Use 2-3 categories for each field. Common culture categories include: Communication, Leadership, Work-Life Balance, Team Collaboration, Professional Growth, Company Values, etc.
        Common suggestion categories include: Training, Process Improvement, Team Building, Management Style, Resources, Communication Channels, etc.

        Employee Feedback to analyze:
        Satisfaction Rating: {response['satisfaction']}/5
        Culture Comment: {response['culture']}
        Suggestions: {response['suggestions']}
        """

        completion = client.chat.completions.create(
            model=deployment_name,
            messages=[
                {"role": "system", "content": "You are an HR analytics expert that categorizes employee feedback. Always respond with valid JSON only."},
                {"role": "user", "content": prompt}
            ],
            temperature=0.3,
            max_tokens=500,
            response_format={ "type": "json_object" }
        )

        # Parse the response as JSON
        classification = json.loads(completion.choices[0].message.content)
        return classification
    except Exception as e:
        print(f"Error classifying response: {str(e)}")
        # Return a default classification if there's an error
        return {
            "culture_categories": ["Uncategorized"],
            "suggestion_categories": ["Uncategorized"],
            "sentiment": "Neutral",
            "key_themes": ["General Feedback"]
        }

def generate_insights(surveys):
    client, deployment_name = configure_azure_client()
    if not client:
        return "Azure OpenAI not configured. Please configure settings first."

    # First, classify all responses
    classified_surveys = []
    for survey in surveys:
        if 'classification' not in survey:
            classification = classify_response(client, deployment_name, survey)
            if classification:
                survey['classification'] = classification
        classified_surveys.append(survey)

    # Prepare analysis data
    categories_summary = {
        'culture': {},
        'suggestions': {},
        'sentiment': {'Positive': 0, 'Neutral': 0, 'Negative': 0},
        'themes': {}
    }

    # Aggregate classifications
    for survey in classified_surveys:
        if 'classification' in survey:
            cls = survey['classification']
            
            # Count culture categories
            for cat in cls.get('culture_categories', []):
                categories_summary['culture'][cat] = categories_summary['culture'].get(cat, 0) + 1
            
            # Count suggestion categories
            for cat in cls.get('suggestion_categories', []):
                categories_summary['suggestions'][cat] = categories_summary['suggestions'].get(cat, 0) + 1
            
            # Count sentiments
            sentiment = cls.get('sentiment', 'Neutral')
            categories_summary['sentiment'][sentiment] = categories_summary['sentiment'].get(sentiment, 0) + 1
            
            # Count themes
            for theme in cls.get('key_themes', []):
                categories_summary['themes'][theme] = categories_summary['themes'].get(theme, 0) + 1

    # Generate comprehensive analysis
    analysis_prompt = f"""
    Analyze the following employee survey data and provide insights:

    Total Responses: {len(surveys)}
    Average Satisfaction: {sum(s['satisfaction'] for s in surveys) / len(surveys):.2f}/5

    Category Distribution:
    Culture Categories: {json.dumps(categories_summary['culture'])}
    Suggestion Categories: {json.dumps(categories_summary['suggestions'])}
    Sentiment Distribution: {json.dumps(categories_summary['sentiment'])}
    Key Themes: {json.dumps(categories_summary['themes'])}

    Provide a comprehensive analysis including:
    1. Overall Assessment
    2. Key Findings by Category
    3. Sentiment Analysis
    4. Recommendations
    5. Trends and Patterns

    Format the response in markdown.
    """

    try:
        response = client.chat.completions.create(
            model=deployment_name,
            messages=[
                {"role": "system", "content": "You are an expert HR analyst specializing in employee engagement and workplace culture."},
                {"role": "user", "content": analysis_prompt}
            ],
            temperature=0.7,
            max_tokens=1500
        )
        
        analysis = response.choices[0].message.content
        return {
            'analysis': analysis,
            'categories': categories_summary,
            'classified_surveys': classified_surveys
        }
    except Exception as e:
        return f"Error generating insights: {str(e)}"

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/visual')
def visual():
    return render_template('visual.html')

@app.route('/insights')
def insights():
    return render_template('insights.html')

@app.route('/settings')
def settings():
    current_settings = None #load_settings()
    return render_template('settings.html', 
                         settings=current_settings,
                         azure_configured=current_settings is not None)

@app.route('/import')
def import_page():
    return render_template('import.html')

@app.route('/static/<path:filename>')
def serve_static(filename):
    return send_from_directory('static', filename)

@app.route('/api/survey', methods=['POST'])
def submit_survey():
    data = request.json
    survey_data = load_data()
    
    data['timestamp'] = datetime.now().isoformat()
    
    # Classify the new response
    client, deployment_name = configure_azure_client()
    if client:
        classification = classify_response(client, deployment_name, data)
        if classification:
            data['classification'] = classification
    
    survey_data['surveys'].append(data)
    save_data(survey_data)
    
    return jsonify({'status': 'success'})

@app.route('/api/import-surveys', methods=['POST'])
def import_surveys():
    try:
        data = request.json
        if not data or 'surveys' not in data:
            return jsonify({'success': False, 'message': 'No survey data provided'}), 400

        surveys = data['surveys']
        if not isinstance(surveys, list):
            return jsonify({'success': False, 'message': 'Invalid data format'}), 400

        # Validate surveys
        for survey in surveys:
            if not all(key in survey for key in ['satisfaction', 'culture', 'suggestions']):
                return jsonify({'success': False, 'message': 'Missing required fields'}), 400
            
            try:
                satisfaction = int(survey['satisfaction'])
                if satisfaction < 1 or satisfaction > 5:
                    return jsonify({'success': False, 'message': 'Invalid satisfaction rating'}), 400
            except (ValueError, TypeError):
                return jsonify({'success': False, 'message': 'Invalid satisfaction rating'}), 400

        # Load existing data
        survey_data = load_data()
        
        # Add timestamp and classify if not present
        now = datetime.now().isoformat()
        client, deployment_name = configure_azure_client()
        
        for survey in surveys:
            if 'timestamp' not in survey or not survey['timestamp']:
                survey['timestamp'] = now
            
            # Classify the response if Azure OpenAI is configured
            if client and 'classification' not in survey:
                classification = classify_response(client, deployment_name, survey)
                if classification:
                    survey['classification'] = classification

        # Append new surveys
        survey_data['surveys'].extend(surveys)
        save_data(survey_data)

        return jsonify({
            'success': True,
            'imported': len(surveys),
            'total': len(survey_data['surveys'])
        })

    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/api/survey-data', methods=['GET'])
def get_survey_data():
    data = load_data()
    
    # Generate AI insights if Azure OpenAI is configured
    if load_settings() and data['surveys']:
        insights_data = generate_insights(data['surveys'])
        if isinstance(insights_data, dict):
            data['ai_insights'] = insights_data['analysis']
            data['categories'] = insights_data['categories']
            data['surveys'] = insights_data['classified_surveys']
        else:
            data['ai_insights'] = insights_data
    
    return jsonify(data)

@app.route('/api/settings', methods=['POST'])
def update_settings():
    settings = request.json
    required_fields = ['base_url', 'api_key', 'api_version', 'deployment_name']
    
    # Validate required fields
    for field in required_fields:
        if not settings.get(field):
            return jsonify({'success': False, 'message': f'Missing required field: {field}'}), 400
    
    try:
        save_settings(settings)
        return jsonify({'success': True})
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/api/test-connection')
def test_connection():
    try:
        client, deployment_name = configure_azure_client()
        if not client:
            return jsonify({
                'success': False,
                'message': 'Azure OpenAI not configured'
            })

        # Test the connection with a simple completion
        response = client.chat.completions.create(
            model=deployment_name,
            messages=[
                {"role": "user", "content": "Hello"}
            ],
            max_tokens=5
        )
        
        return jsonify({
            'success': True,
            'message': 'Connection successful'
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'message': str(e)
        })

@app.route('/board')
def board():
    return render_template('board.html')

@app.route('/api/delete-surveys', methods=['POST'])
def delete_surveys():
    try:
        data = request.json
        if not data or 'timestamps' not in data:
            return jsonify({'success': False, 'message': 'No timestamps provided'}), 400

        timestamps = set(data['timestamps'])
        survey_data = load_data()
        
        # Filter out surveys with matching timestamps
        survey_data['surveys'] = [
            survey for survey in survey_data['surveys']
            if survey['timestamp'] not in timestamps
        ]
        
        save_data(survey_data)
        return jsonify({'success': True})

    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=52552)
    