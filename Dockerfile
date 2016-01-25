FROM alpine:3.3
MAINTAINER Linki <linki+docker.com@posteo.de>

ENV RAILS_ENV production

COPY install.sh /
COPY entrypoint.sh /

WORKDIR /app

RUN /install.sh

COPY setup_database bin/

VOLUME ["/app/files"]
EXPOSE 3000

ENTRYPOINT ["/entrypoint.sh"]
CMD HOST=0.0.0.0 PORT=3000 foreman start web
