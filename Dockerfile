FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV LANG=C.UTF-8

WORKDIR /app

COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

COPY . /app/

EXPOSE 8000

ENV DJANGO_SETTINGS_MODULE=farm_flow.settings

CMD ["daphne", "-b", "0.0.0.0", "-p", "8000", "-v", "2", "farm_flow.asgi:application"]