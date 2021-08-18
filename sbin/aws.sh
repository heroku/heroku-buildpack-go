#!/bin/bash

# source this file
export AWS_ACCESS_KEY_ID="$(lpass show --sync=now --notes "Shared-Heroku Languages Team/S3 Bucket: heroku-golang-prod" | jq -r '.AccessKey | .AccessKeyId')"
export AWS_SECRET_ACCESS_KEY="$(lpass show --sync=now --notes "Shared-Heroku Languages Team/S3 Bucket: heroku-golang-prod" | jq -r '.AccessKey | .SecretAccessKey')"
