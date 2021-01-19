FROM python:3.9-slim

RUN apt-get update -qq && \
    apt-get install -y -qq build-essential && \
    pip install locust awscli

WORKDIR /locust

COPY run_locust.sh /locust

CMD [ "sh", "-c", "/locust/run_locust.sh" ]