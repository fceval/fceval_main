FROM magma/moptafl_asan/libpng
RUN export DEBIAN_FRONTEND=noninteractive   && apt-get update  && apt-get install -y tzdata && ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime  && dpkg-reconfigure --frontend noninteractive tzdata
RUN apt-get update && apt-get install -y libasound2-dev libflac-dev libogg-dev libtool libvorbis-dev libopus-dev libmp3lame-dev libmpg123-dev nasm zlib1g-dev liblzma-dev libjpeg-turbo8-dev libreadline-dev
COPY magma /targets/magma
COPY magma/binutils /targets/binutils
COPY magma/unibench /targets/unibench
ENV AFL_SKIP_CPUFREQ=1 
ENV AFL_NO_AFFINITY=1


