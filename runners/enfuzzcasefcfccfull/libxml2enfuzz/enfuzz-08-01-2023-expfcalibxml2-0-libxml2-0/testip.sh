#!/usr/bin/env bash

#set -e
sed -i 's/172.24./172.24.7/g' docker-compose.yaml
