docker image build -t craver_server:latest .
docker run -it -p 8080:8080 --env-file env_vars.env craver_server:latest 