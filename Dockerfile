# --- Étape 1 : build (dépendances dans un venv) ---
FROM python:3.14-alpine AS builder
WORKDIR /app
COPY requirements.txt .
RUN python -m venv /venv && /venv/bin/pip install --no-cache-dir -r requirements.txt \
 && /venv/bin/python -m pip uninstall -y pip

# --- Étape 2 : image finale minimale ---
FROM python:3.14-alpine
RUN apk upgrade --no-cache \
 && pip uninstall -y pip \
 && rm -rf /root/.cache \
 && addgroup -S app && adduser -S -G app -H app
WORKDIR /app
COPY --from=builder /venv /venv
COPY --chown=app:app . .
ENV PATH="/venv/bin:$PATH" PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
USER app
EXPOSE 4000
HEALTHCHECK CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:4000')" || exit 1
CMD ["python", "main.py"]
