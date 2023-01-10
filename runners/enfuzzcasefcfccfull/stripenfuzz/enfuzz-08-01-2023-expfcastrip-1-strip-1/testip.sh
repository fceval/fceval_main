#!/usr/bin/env bash

#set -e
sed -i 's/172.24./172.24.24/g' docker-compose.yaml
