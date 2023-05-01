#!/bin/bash
# 1. Connect to the EC2 instance using SSH.
# 2. Install Docker and Docker Compose on the EC2 instance if they are not already installed.
# 3. Stop and remove any existing containers that are running on the EC2 instance.
# 4. Pull the latest Docker image from Docker Hub.
# 5. Start the new containers based on the Docker image.
# 6. Check the health of the application by running a curl command to the health endpoint.
#       If the application is healthy, exit the script.
# BONUS: If the application is not healthy, send a notification via Slack or email. (curl) 

KEY_PATH=$1
USER=$2
HOST=$3
IMAGE_NAME=$4
DOCKER_COMPOSE_PATH="/home/ubuntu/devops_exam/" # $5
PORT=8089 # $6
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/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"

ssh -i $KEY_PATH $USER@$HOST << EOF

if ! command -v docker &> /dev/null; then
    echo 'docker is not installed'
    sudo apt-get update
    sudo apt-get install -y docker.io
    sudo systemctl enable docker.service
    sudo systemctl start docker.service
else
    echo 'docker already installed'
fi


if ! command -v docker-compose &> /dev/null; then
    echo 'docker-compose is not installed'
    sudo apt-get install -y docker-compose
else
    echo 'docker-compose already installed'
fi



sudo docker stop $(sudo docker ps -aq) 
sudo docker rm $(sudo docker ps -aq)

cd $DOCKER_COMPOSE_PATH
sudo docker pull $IMAGE_NAME
sudo docker-compose up -d

EOF

HEALTH_CHECK_OUTPUT=$(curl -s -o /dev/null -w "%{http_code}" http://$HOST:$PORT/todo)

if [ $HEALTH_CHECK_OUTPUT -eq 200 ]; then
    echo "Application is healthy"
    curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"Application is healthy\"}" $SLACK_WEBHOOK_URL
else
    echo "Application is not healthy"
    # Send a notification via Slack
    curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"Application is not healthy\"}" $SLACK_WEBHOOK_URL
fi