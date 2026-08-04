#!/bin/bash

# Make sure container is stopped
./stop.sh

# Build and start container
docker-compose up --build -d

# Wait for the container to be ready
until docker ps | grep -q "zapret-proxy"; do
  echo "Waiting for container to start..."
  sleep 2
done

# Execute starting script
docker exec zapret-proxy ./start_zapret.sh
