FROM python:3.14-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

RUN pip install --no-cache-dir --upgrade \
    "setuptools>=78.1.1" \
    "msgpack>=1.2.1"

COPY . .

EXPOSE 5000

CMD ["python", "app.py"]