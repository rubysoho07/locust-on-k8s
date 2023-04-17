FROM python:3.10-slim

WORKDIR /locust

RUN pip install -q locust
COPY run_locust.sh /root

CMD [ "sh", "-c", "/root/run_locust.sh" ]