#!/usr/bin/env bash

#set -e
sed -i 's/172.24./172.24.19/g' docker-compose.yaml
