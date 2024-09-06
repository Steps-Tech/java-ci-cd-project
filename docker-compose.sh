#Installation Commands
mkdir -p ~/.docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/download/v2.3.3/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose
chmod +x ~/.docker/cli-plugins/docker-compose
docker compose version

#Command to run the Compose file
docker compose help
touch docker-compose.yml
docker compose up  
    or
docker compose up -d # d: detach mode
docker compose ps # Use to identify the running services
docker compose stop # Stop the docker compose
docker compose down # use to remove containers entirly but not remove volume to detach volume use --volumes flag

