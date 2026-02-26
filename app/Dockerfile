FROM python:3.10-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Add non-root user (UID 10001 matches K8s runAsUser); chown app dir so imports work
RUN addgroup --gid 10001 appgroup && \
    adduser --uid 10001 --ingroup appgroup --disabled-password --gecos "" appuser && \
    chown -R appuser:appgroup /app

USER appuser

# Uvicorn on port 8080 — non-root cannot bind privileged ports (< 1024)
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
