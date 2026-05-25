FROM python:3.11-slim
COPY Quakewatch/ /Quakewatch/
WORKDIR /Quakewatch
RUN pip install --no-cache-dir -r requirements.txt
EXPOSE 5000
CMD ["python", "app.py"]
