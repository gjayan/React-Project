#!/bin/bash

AWS_ACCOUNT_ID=775422423362
AWS_REGION=ap-south-1
IMAGE_REPO_NAME=gayathri-ecr
TASK_FAMILY=gayathri-react
ECS_CLUSTER=dev
SERVICE_NAME=gayathri-service-react





#Script to get current task definition, and based on that add new ecr image address to old template and remove attributes that are not needed, then we send new task definition, get new revision number from output and update service
#set -e

ECR_IMAGE=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$IMAGE_REPO_NAME:$1
TASK_DEFINITION=$(aws ecs describe-task-definition --task-definition "$TASK_FAMILY" --region "$AWS_REGION")
NEW_TASK_DEFINTIION=$(echo $TASK_DEFINITION | jq --arg IMAGE "$ECR_IMAGE" '.taskDefinition | .containerDefinitions[0].image = $IMAGE | del(.taskDefinitionArn) | del(.revision) | del(.status) | del(.requiresAttributes) | del(.compatibilities) | del(.registeredAt) | del(.registeredBy)')
NEW_REVISION=$(aws ecs register-task-definition --region "$AWS_REGION" --cli-input-json "$NEW_TASK_DEFINTIION")
NEW_REVISION_DATA=$(echo $NEW_REVISION | jq '.taskDefinition.revision')
NEW_SERVICE=$(aws ecs update-service --cluster ${ECS_CLUSTER} \
                       --service ${SERVICE_NAME} \
                       --task-definition ${TASK_FAMILY}:${NEW_REVISION})
aws ecs update-service --cluster $ECS_CLUSTER --service $SERVICE_NAME --task-definition $TASK_FAMILY --desired-count 0
sleep 30s
aws ecs update-service --cluster $ECS_CLUSTER --service $SERVICE_NAME --task-definition $TASK_FAMILY --desired-count 1
echo "deployment done"
echo "${TASK_FAMILY}, Revision: ${NEW_REVISION_DATA}"
