#!/bin/bash
# Copyright 2016 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
#docker images  | grep none | awk '{print $3}' | xargs docker rmi

docker container prune -f
echo $(docker images --filter dangling=true -q)
for img in  $(docker images --filter dangling=true -q)
do
docker rmi $img -f
echo $img
done
cd $HOME/collabfuzzzxy/runners
make collab_fuzz_runner
collab_fuzz_build -f libfuzzer -t objdump
cd $HOME/collabfuzzzxy/runners/myrun3
collab_fuzz_compose -f libfuzzer -- objdump
docker-compose up --abort-on-container-exit


