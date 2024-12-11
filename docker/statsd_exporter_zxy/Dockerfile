FROM ubuntu:20.04
LABEL maintainer="zxy modify statsd_exporter base from busybox to ubuntu for debugging"

COPY statsd_exporter /bin/statsd_exporter

USER        nobody
EXPOSE      9102 9125 9125/udp
HEALTHCHECK CMD wget --spider -S "http://localhost:9102/metrics" -T 60 2>&1 || exit 1
ENTRYPOINT  [ "/bin/statsd_exporter" ]
