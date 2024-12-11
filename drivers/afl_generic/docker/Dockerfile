FROM python:3 AS builder
RUN pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/ && pip config set install.trusted-host mirrors.aliyun.com
RUN apt-get update

RUN wget https://www.python.org/ftp/python/3.7.2/Python-3.7.2.tgz

RUN tar -xvf Python-3.7.2.tgz

RUN cd Python-3.7.2 && ./configure --prefix=/usr/local/python3.7 && make && make install
RUN rm /usr/bin/python3

RUN ln -s /usr/local/python3.7/bin/python3 /usr/bin/python3
RUN cd ..
 
RUN apt-get update && \
    apt-get install -y --no-install-recommends  apt-utils sudo protobuf-compiler && \
    pip install pipenv -i http://pypi.douban.com/simple --trusted-host pypi.douban.com

 
  


RUN pip install cython pyzmq -i http://pypi.douban.com/simple --trusted-host pypi.douban.com
 

WORKDIR /build

## The Pipfile installs the current package as editable, remove it from the
# requirements.
COPY Pipfile Pipfile.lock setup.py ./

#RUN ["/bin/bash", "-c", " \
#    set -o pipefail && \
#    pipenv lock --requirements --keep-outdated \
#        | sed '/-e ./d' > requirements.txt \
#    "]

RUN ["/bin/bash", "-c", " \
    set -o pipefail && \
    pipenv lock --keep-outdated \
        | sed '/-e ./d' > requirements.txt \
    "]
#RUN pip uninstall -y protobuf && pip install protobuf==3.11.3 -i https://pypi.douban.com/simple && pip show protobuf
# A separate build step is necessary since the *_pb2.py files need to be
# generated separately
COPY . ./
RUN python setup.py bdist_wheel

FROM python:3 AS production
RUN apt-get update && \
    apt-get install -y --no-install-recommends  apt-utils sudo
#RUN adduser --disabled-password --gecos "" coll && \
#    mkdir /data && \
#    chown -R coll:coll /data
RUN mkdir /data
ENV FUZZER_TYPE=afl OUTPUT_DIR=/out AFL_PATH=/fuzzers/afl ARG=''

WORKDIR /app

COPY --from=builder /build/requirements.txt .
RUN pip install --requirement requirements.txt

COPY --from=builder /build/dist/collabfuzz_generic_driver-*.whl .
RUN pip install collabfuzz_generic_driver-*.whl
#RUN pip uninstall -y protobuf && pip install protobuf==3.11.3 -i https://pypi.douban.com/simple && pip show protobuf
RUN pip install zmq && pip show protobuf

COPY docker/entry.sh .
RUN chmod +x entry.sh
CMD ["./entry.sh"]
