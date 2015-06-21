FROM tozd/runit

MAINTAINER Jernej Kos <jernej@kos.mx>

ENV DOMAIN_NAME docker

ADD . /build

RUN apt-get update -q -q && \
 apt-get install --yes --force-yes wget git && \
 wget -q https://storage.googleapis.com/golang/go1.4.2.linux-amd64.tar.gz -O /tmp/go.tar.gz && \
 tar -C /usr/local -xzf /tmp/go.tar.gz && \
 export PATH="$PATH:/usr/local/go/bin" && \
 wget -q https://raw.githubusercontent.com/pote/gvp/v0.2.0/bin/gvp -O /tmp/gvp && \
 cd /build && \
 . /tmp/gvp && \
 wget -qO- https://raw.githubusercontent.com/pote/gpm/v1.3.1/bin/gpm | bash && \
 go build -v -o /usr/local/bin/docker-host ./... && \
 rm -rf /tmp/gvp /build /usr/local/go /tmp/go.tar.gz && \
 apt-get purge --yes --force-yes git wget && \
 apt-get autoremove --yes --force-yes

ADD ./etc /etc

