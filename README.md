# HR Engagement Analysis Platform

A lightweight, intelligent web application for HR teams to analyze employee engagement through survey data. The platform combines manual survey inputs with AI-powered analysis to provide actionable insights and visual representations of workplace sentiment.

## 🌟 Features

### 1. Survey Management
- Quick survey input form for HR/team leads
- Bulk data import via CSV/Excel
- Survey response management and deletion
- Real-time data validation

### 2. AI-Powered Analysis
- Automatic categorization of responses
- Sentiment analysis
- Theme identification
- Actionable recommendations
- Powered by Azure OpenAI GPT models

### 3. Visual Analytics
- Interactive charts and graphs
- Satisfaction trend analysis
- Category distribution visualization
- Sentiment distribution
- Real-time data updates

### 4. Survey Board
- Comprehensive survey management
- Advanced filtering capabilities
- Bulk operations
- Real-time search
- Category-based organization

## 🛠️ Technology Stack

### Frontend
- Vanilla JavaScript
- Tailwind CSS for styling
- Chart.js for visualizations
- Responsive design

### Backend
- Flask (Python)
- Azure OpenAI integration
- JSON file-based storage
- RESTful API architecture

## 📋 Prerequisites

- Python 3.8+
- Azure OpenAI API access
- Modern web browser
- Node.js (for Tailwind CSS compilation, optional)

## 🚀 Getting Started

1. Clone the repository:
```bash
git clone <repository-url>
cd hr_engagement_app
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Configure Azure OpenAI:
- Navigate to Settings page in the application
- Enter your Azure OpenAI credentials:
  - Base URL (endpoint)
  - API Key
  - API Version
  - Deployment Name

4. Run the application:
```bash
python app.py
```

5. Access the application:
```
http://localhost:52552
```

## 📊 Data Structure

### Survey Data
```json
{
    "satisfaction": 1-5,
    "culture": "string",
    "suggestions": "string",
    "timestamp": "ISO datetime",
    "classification": {
        "culture_categories": ["array of strings"],
        "suggestion_categories": ["array of strings"],
        "sentiment": "Positive/Neutral/Negative",
        "key_themes": ["array of strings"]
    }
}
```

### Settings Data
```json
{
    "base_url": "Azure OpenAI endpoint",
    "api_key": "Azure OpenAI API key",
    "api_version": "API version",
    "deployment_name": "Model deployment name"
}
```

## 📱 Pages and Features

### 1. Survey Input (/)
- Quick survey submission form
- Satisfaction rating (1-5)
- Culture comments
- Improvement suggestions
- Real-time validation

### 2. Visual Snapshot (/visual)
- Satisfaction distribution chart
- Trend analysis
- Category distribution
- Interactive visualizations

### 3. AI Insights (/insights)
- AI-generated analysis
- Category breakdown
- Sentiment distribution
- Key themes identification
- Actionable recommendations

### 4. Survey Board (/board)
- Complete survey management
- Advanced filtering:
  - By satisfaction rating
  - By category
  - By sentiment
  - Text search
- Bulk operations
- Real-time updates

### 5. Data Import (/import)
- CSV/Excel file import
- Template download
- Data validation
- Bulk processing

### 6. Settings (/settings)
- Azure OpenAI configuration
- Connection testing
- Credential management

## 🔄 API Endpoints

### Survey Management
- `POST /api/survey` - Submit new survey
- `GET /api/survey-data` - Retrieve all surveys with analysis
- `POST /api/delete-surveys` - Delete selected surveys

### Settings Management
- `POST /api/settings` - Update Azure OpenAI settings
- `GET /api/test-connection` - Test Azure OpenAI connection

### Data Import
- `POST /api/import-surveys` - Import surveys from file

## 🎨 UI Components

### Charts
- Satisfaction Distribution (Bar Chart)
- Trend Analysis (Line Chart)
- Category Distribution (Bar Chart)
- Sentiment Analysis (Pie Chart)

### Interactive Elements
- Real-time filters
- Search functionality
- Bulk selection
- Confirmation dialogs
- Status notifications

## 🔒 Security Considerations

- API key storage in server-side JSON
- Input validation and sanitization
- CORS configuration
- Error handling and logging

## 🔧 Customization

### Categories
Culture categories and suggestion categories are dynamically generated based on AI analysis, including:
- Communication
- Leadership
- Work-Life Balance
- Team Collaboration
- Professional Growth
- Training
- Process Improvement
- Resources

### Sentiment Analysis
Three-tier sentiment classification:
- Positive
- Neutral
- Negative

## 📈 Future Enhancements

1. Authentication System
- User roles (Admin, HR, Manager)
- Access control
- Secure login

2. Database Integration
- SQL/NoSQL database support
- Data backup and recovery
- Enhanced querying

3. Advanced Analytics
- Custom report generation
- Historical trend analysis
- Department-wise comparison

4. Export Features
- PDF report generation
- Excel export
- Data visualization export

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Authors

- OpenHands Team

## 🙏 Acknowledgments

- Azure OpenAI team for AI capabilities
- Chart.js for visualization
- Tailwind CSS for styling
- Flask team for the web framework