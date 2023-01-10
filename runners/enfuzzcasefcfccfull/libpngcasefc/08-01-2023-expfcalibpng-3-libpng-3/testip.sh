#!/usr/bin/env bash

#set -e
sed -i 's/172.24./172.24.4/g' docker-compose.yaml
