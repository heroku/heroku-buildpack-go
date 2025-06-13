#!/bin/bash

# source this file
export AWS_ACCESS_KEY_ID="$(op read "op://Heroku Languages Team/y6etv4np7575qb6ykgb6wqcnjy/notesPlain" | jq -r '.AccessKey | .AccessKeyId')"
export AWS_SECRET_ACCESS_KEY="$(op read "op://Heroku Languages Team/y6etv4np7575qb6ykgb6wqcnjy/notesPlain" | jq -r '.AccessKey | .SecretAccessKey')"
