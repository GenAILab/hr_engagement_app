FROM python:3.12-slim

WORKDIR /app

COPY Pipfile Pipfile.lock ./
RUN pip install pipenv && \
    pipenv install --deploy --system

COPY . .

EXPOSE 80

ENV FLASK_APP=api.app
ENV PORT=80

CMD ["python", "-c", "from api.app import app; app.run(host='0.0.0.0', port=int(os.environ.get('PORT', 80)))"] 