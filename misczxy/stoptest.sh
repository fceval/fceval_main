#!/bin/bash
# Copyright 2016 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
#docker images  | grep none | awk '{print $3}' | xargs docker rmi

 
cd $HOME/collabfuzzzxy/runners/myrun3
docker-compose down -v


