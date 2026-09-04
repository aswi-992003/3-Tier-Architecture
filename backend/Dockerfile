FROM python:3.14-slim AS builder

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir --upgrade pip setuptools wheel \
    && pip install --no-cache-dir --prefix=/install -r requirements.txt


FROM python:3.14-slim

WORKDIR /app

COPY --from=builder /install /usr/local

COPY . .

RUN python -m pip uninstall -y pip setuptools wheel || true

EXPOSE 5000

CMD ["python", "app.py"]