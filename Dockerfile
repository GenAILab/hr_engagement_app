FROM python:3.12-slim

WORKDIR /app

COPY Pipfile Pipfile.lock ./
RUN pip install pipenv && \
    pipenv install --deploy --system

COPY . .

EXPOSE 80

ENV FLASK_APP=api.app
ENV PORT=80

# Simpler CMD that's less prone to errors
CMD ["python", "-m", "flask", "run", "--host=0.0.0.0", "--port=80"] 