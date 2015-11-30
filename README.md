# Simple Docker service discovery #

`docker-hosts` maintains a file in the format of `/etc/hosts` that contains IP addresses and hostnames of all Docker
containers on the host. When the generated file is mounted at `/etc/hosts` within your Docker container it
provides simple hostname resolution. This allows you to set up `redis` and `web` containers where the `web` container
is able to connect to `redis` via its hostname, without a need for linking of containers together. This allows for
independent life-cycles of containers. You can optionally provide a domain like `dev.docker`, so `redis.dev.docker`
is a usable alias, as well (by default is set to `docker`).

## Running ##

The easiest way to run it is inside a Docker container using the provided `tozd/docker-hosts` Docker image. You have
to provide host's Docker socket file to it. For example, create an empty file `/srv/var/hosts` on the host and mount
it as a volume into the container so that `docker-hosts` will keep it populated with entries.

```
docker run -d -v /var/run/docker.sock:/var/run/docker.sock -v /srv/var/hosts:/hosts -e DOMAIN_NAME=dev.docker tozd/docker-hosts
```

Optionally, you can also mount a volume onto `/var/log/hosts` to store logs.

Then read-only mount `/srv/var/hosts` into all containers where you want hostname resolution to happen. For example:

```
docker run -i -t -v /srv/var/hosts:/etc/hosts:ro centos /bin/bash
```

Within the `centos` container, you'll see `/etc/hosts` has an entry for the container you just started, as well as
any other containers already running. `/etc/hosts` will continue to reflect all of the containers currently running
on this Docker host.

The **only** container that should have write access to the generated hosts file is the container running this
application.

## Running on the host ##

You can also run `docker-hosts` directly on the host. First, you have to build it. This project uses
[gpm][https://github.com/pote/gpm] and [gvp][https://github.com/pote/gvp]. Both must be available on your
path. Run:

```
make
```

-- or --

```
gvp init
source gvp in
gpm install
go build -v -o stage/docker-host ./...
```

Start the `docker-host` process and give it the path to a file that will be mounted as `/etc/hosts` in your containers:

```
docker-host --domain-name=dev.docker /srv/var/hosts
```

Optionally specify `DOCKER_HOST` environment variable.

## History ##

This is a fork of the [original docker-hosts](https://github.com/blalor/docker-hosts) project.

This utility was inspired by Michael Crosby's [skydock](https://github.com/crosbymichael/skydock) project.
`docker-hosts` and skydock (paired with skydns) work in much the same way: the container lifecycle
is monitored via the Docker daemon's events, and resolvable hostnames are made available to appropriately-configured
containers.  The end result is that you have a simple way of connecting containers together on the same Docker host,
without having to resort to links or manual configuration. This does *not* provide a solution to container connectivity
across Docker hosts.  For that you should look at something like Jeff Lindsay's
[registrator](https://github.com/progrium/registrator).
