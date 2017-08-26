#!/bin/sh
OAUTH_TOKEN="bacd4353ca9a4f771f16dc7d0c16802de87ca025"
API_URL="https://api.github.com/user/repos?type=all&per_page=100"

HEADERS=`curl -sI -H "Authorization: token ${OAUTH_TOKEN}" -s "${API_URL}" | grep `
NEXT=$