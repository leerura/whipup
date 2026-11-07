FROM python:3.12-slim

WORKDIR /workspace
COPY tools/data-pipeline/requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt
COPY tools/data-pipeline/src /workspace/tools/data-pipeline/src

CMD ["python", "/workspace/tools/data-pipeline/src/pipeline.py"]
