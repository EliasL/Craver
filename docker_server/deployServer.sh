docker image build -t test:latest2 .
docker run -it -p 8080:8080 --env-file env_vars.env test:latest2 