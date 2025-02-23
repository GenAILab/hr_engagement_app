[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https%3A%2F%2Fgithub.com%2Fvercel%2Fexamples%2Ftree%2Fmain%2Fpython%2Fflask3&demo-title=Flask%203%20%2B%20Vercel&demo-description=Use%20Flask%203%20on%20Vercel%20with%20Serverless%20Functions%20using%20the%20Python%20Runtime.&demo-url=https%3A%2F%2Fflask3-python-template.vercel.app%2F&demo-image=https://assets.vercel.com/image/upload/v1669994156/random/flask.png)

# Flask + Vercel

This example shows how to use Flask 3 on Vercel with Serverless Functions using the [Python Runtime](https://vercel.com/docs/concepts/functions/serverless-functions/runtimes/python).

## Demo

https://flask-python-template.vercel.app/

## How it Works

This example uses the Web Server Gateway Interface (WSGI) with Flask to enable handling requests on Vercel with Serverless Functions.

## Running Locally

```bash
npm i -g vercel
vercel dev
```

Your Flask application is now available at `http://localhost:3000`.

## One-Click Deploy

Deploy the example using [Vercel](https://vercel.com?utm_source=github&utm_medium=readme&utm_campaign=vercel-examples):

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https%3A%2F%2Fgithub.com%2Fvercel%2Fexamples%2Ftree%2Fmain%2Fpython%2Fflask3&demo-title=Flask%203%20%2B%20Vercel&demo-description=Use%20Flask%203%20on%20Vercel%20with%20Serverless%20Functions%20using%20the%20Python%20Runtime.&demo-url=https%3A%2F%2Fflask3-python-template.vercel.app%2F&demo-image=https://assets.vercel.com/image/upload/v1669994156/random/flask.png)

## Technical Specifications

### Application Structure

- **api/**: Contains the main application logic and API endpoints.
  - `app.py`: The main Flask application file that defines routes and handles requests.
- **.github/workflows/**: Contains GitHub Actions workflows for CI/CD.
  - `preview-deploy.yaml`: Workflow for deploying preview environments on Vercel.
  - `production-deploy.yaml`: Workflow for deploying production environments on Vercel.
- **static/**: Contains static files such as CSS, JavaScript, and images.
- **templates/**: Contains HTML templates for rendering views.

### Pipenv Requirements

The project uses Pipenv for managing Python dependencies. The `Pipfile` and `Pipfile.lock` files define the required packages and their versions.

To install the dependencies, run:

```bash
pipenv install
```

To activate the virtual environment, use:

```bash
pipenv shell
```

### Environment Variables

The application requires certain environment variables to be set for proper configuration:

- `VERCEL_ORG_ID`: Your Vercel organization ID.
- `VERCEL_PROJECT_ID`: Your Vercel project ID.
- `VERCEL_TOKEN`: Your Vercel API token.

These should be set in your GitHub repository secrets for the workflows to function correctly.

### Deployment

The application is deployed using Vercel. The deployment process is automated using GitHub Actions:

- **Preview Deployments**: Triggered on pushes to the `cursor_test` branch. Deploys to a preview environment.
- **Production Deployments**: Triggered on pushes to the `main` branch. Deploys to the production environment.

### Setting Up a New Vercel Project

To create a new Vercel project based on this specification:

1. Clone the repository to your local machine.
2. Set up the environment variables as described above.
3. Ensure that your Vercel account is linked to your GitHub repository.
4. Push changes to the appropriate branch to trigger the deployment workflows.

### Additional Information

Include any other relevant information, such as testing instructions, contribution guidelines, or links to documentation.
