FROM python:3.14-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir --upgrade \
    "setuptools>=78.1.1" \
    "msgpack>=1.2.1"

COPY app.py .
COPY test_app.py .

ENV FLASK_HOST=0.0.0.0

RUN useradd --create-home appuser && \
    chown -R appuser:appuser /app

USER appuser

EXPOSE 5000

CMD ["python", "app.py"]