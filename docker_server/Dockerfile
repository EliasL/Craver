FROM python:3.7.13-slim-buster

COPY .wgetrc .wgetrc
ENV http_proxy=http://128.141.22.113:8080
ENV https_proxy=http://128.141.22.113:8080

RUN apt-get update

RUN mkdir -p /app
WORKDIR /app
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt


ADD database_scripts database_scripts 
WORKDIR /app/database_scripts

EXPOSE 8080
CMD [ "python3", "requestHandler.py"]

