FROM python:3.10-slim

WORKDIR /app

# You must copy your python script and requirements here later
# For now, we create a placeholder to ensure the build succeeds
RUN echo "Placeholder" > requirements.txt

COPY . .

CMD ["python3", "-m", "http.server", "8678"]

