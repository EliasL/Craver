FROM python:3.7.13-slim-buster


RUN apt-get update
#RUN apt-get install gdb -y


#libgcc8.5
#modif2.3
#python3.9
RUN mkdir -p /app
WORKDIR /app
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

COPY test.py test.py
#COPY test2.py test2.py

ENV DIM_DNS_NODE=ecs04.lbdaq.cern.ch

CMD [ "python3", "test.py"]

