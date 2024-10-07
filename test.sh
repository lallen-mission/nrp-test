#!/bin/bash

docker-compose build
docker-compose up -d
curl -s localhost:8080/myapp/en-us/index > /dev/null
docker-compose logs | tail -5