FROM tozd/runit

MAINTAINER Jernej Kos <jernej@kos.mx>

ADD . /build

RUN apt-get update -q -q && \
 apt-get install --yes --force-yes golang wget git && \
 wget -q https://raw.githubusercontent.com/pote/gvp/v0.2.0/bin/gvp -O /tmp/gvp && \
 cd /build && \
 . /tmp/gvp && \
 wget -qO- https://raw.githubusercontent.com/pote/gpm/v1.3.1/bin/gpm | bash && \
 go build -v -o /usr/local/bin/docker-host ./... && \
 rm -rf /tmp/gvp /build && \
 apt-get purge --yes --force-yes git wget golang && \
 apt-get autoremove --yes --force-yes

ADD ./etc /etc

