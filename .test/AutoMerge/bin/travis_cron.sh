#!/bin/bash

### Step 1: Make sure that you have curl installed
### Step 2: Install the Travis CLI client: https://github.com/travis-ci/travis.rb
### Step 3: travis login --org
### Step 4: ./cron.sh

body='{
"request": {
"branch":"master"
}}'

curl -s -X POST \
   -H "Content-Type: application/json" \
   -H "Accept: application/json" \
   -H "Travis-API-Version: 3" \
   -H "Authorization: token $(travis token --org)" \
   -d "$body" \
   https://api.travis-ci.com/repo/JuliaRegistries%2FGeneral/requests
