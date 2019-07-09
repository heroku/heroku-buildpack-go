#!/bin/bash

# source this file
export AWS_ACCESS_KEY_ID="$(lpass show --sync=now --notes 9022891142845286058 | jq -r '.AccessKey | .AccessKeyId')"
export AWS_SECRET_ACCESS_KEY="$(lpass show --sync=now --notes 9022891142845286058 | jq -r '.AccessKey | .SecretAccessKey')"