FROM python:3.9-slim

RUN pip install ansible requests

COPY requirements.yml .
RUN ansible-galaxy install -r requirements.yml

COPY . /ansible
WORKDIR /ansible

CMD ["ansible-playbook", "playbook.yml"]