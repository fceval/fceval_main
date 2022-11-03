#!/bin/bash
# Copyright 2016 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
#docker images  | grep none | awk '{print $3}' | xargs docker rmi
#pass the param:fuzzer name
docker container prune -f
echo $1
docker rmi -f $(docker images | grep -E "$1" | awk '{print $3}')

