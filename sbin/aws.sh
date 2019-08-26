#!/bin/bash

# source this file
export AWS_ACCESS_KEY_ID="$(lpass show --sync=now --notes "Shared-Go Language/Go S3 Bucket" | jq -r '.AccessKey | .AccessKeyId')"
export AWS_SECRET_ACCESS_KEY="$(lpass show --sync=now --notes "Shared-Go Language/Go S3 Bucket" | jq -r '.AccessKey | .SecretAccessKey')"