FROM python:3.12-slim

WORKDIR /app

COPY Pipfile Pipfile.lock ./
RUN pip install pipenv && \
    pipenv install --deploy --system

COPY . .

EXPOSE 80

CMD ["python", "-m", "api.app"] 