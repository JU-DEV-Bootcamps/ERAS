#!/bin/bash

set -e

cd ~/app || exit 1

echo "Stop containers running..."
docker compose down

echo "Pull images lastest versions..."
docker compose pull

echo "Setting up containers - detach mode..."
docker compose up -d

echo "Project's Containers running."

echo "Start cleaning up prod environment..."

echo "Deleting orphan containers..."
docker container prune -f

echo "Deleting unused images ..."
docker image prune -a -f

# echo "Deleting unused volumes..."
# docker volume prune -f


echo "Deployment succesful."