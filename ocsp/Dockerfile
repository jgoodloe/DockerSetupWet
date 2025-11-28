FROM python:3.10-slim

WORKDIR /app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt || true

COPY . .

# Placeholder command until you add your script
CMD ["python3", "-m", "http.server", "8678"]

