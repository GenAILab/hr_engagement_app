# CLAUDE.md - HR Engagement App Guidelines

## Build & Run Commands
- Install: `pipenv install`
- Run locally: `vercel dev`
- Docker build: `docker build -t hr_engagement_app .`
- Docker run: `docker run -p 80:80 hr_engagement_app`

## Code Style Guidelines
- Use Flask app patterns with clear route organization
- Follow PEP 8 conventions for Python (snake_case variables/functions)
- Imports: standard library first, third-party second, local modules last
- Use Pydantic for data validation and type hints where appropriate
- Error handling: Use specific try/except blocks with informative error messages
- Structure HTML templates to extend from base.html
- Keep Azure OpenAI API calls in separate helper functions
- Maintain clean separation between API routes and business logic
- Document functions with docstrings for complex operations

## Deployment
- Main deployment via Vercel (see vercel.json for configuration)
- Docker alternative available for containerized deployment