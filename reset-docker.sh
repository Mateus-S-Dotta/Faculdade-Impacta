docker compose down

docker rm -f $(docker ps -aq) 2>/dev/null

docker rmi -f $(docker images -aq) 2>/dev/null

docker network prune -f

docker builder prune -af

docker volume ls -q | grep -v 'pgdata' | xargs -r docker volume rm
