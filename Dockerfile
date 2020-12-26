FROM alpine:3.9

# greet me :)
MAINTAINER Tobias Rös - <roes@amicaldo.de>

ARG VERSION=1.0.0
ENV SPEEDTEST_VERSION=${VERSION}

# install dependencies
RUN apk update && apk add \
  bash \
  git \
  nodejs \
  nodejs-npm \
  nginx \
  nginx-mod-http-lua \
  python3 \
  py-pip


RUN pip install speedtest-cli

# remove default content
RUN rm -R /var/www/*

# create directory structure
RUN mkdir -p /etc/nginx
RUN mkdir -p /run/nginx
RUN mkdir -p /etc/nginx/global
RUN mkdir -p /var/www/html

# touch required files
RUN touch /var/log/nginx/access.log && touch /var/log/nginx/error.log

# install vhost config
ADD ./config/vhost.conf /etc/nginx/conf.d/default.conf
ADD config/nginxEnv.conf /etc/nginx/modules/nginxEnv.conf

# install webroot files
ADD ./ /var/www/html/

# install bower dependencies
RUN npm install -g yarn && cd /var/www/html/ && yarn install

EXPOSE 80
EXPOSE 443

RUN chown -R nginx:nginx /var/www/html/
RUN chmod +x /var/www/html/config/run.sh
RUN chmod 755 /var/www/html/scripts/speedtestRunner.py
ENTRYPOINT ["/var/www/html/config/run.sh"]

#speedtest ookla
RUN apk add --no-cache --virtual deps tar curl && \
    ARCH=$(apk info --print-arch) && \
    echo ARCH=$ARCH && \
    case "$ARCH" in \
      x86) _arch=i386 ;; \
      armv7) _arch=armhf ;; \
      *) _arch="$ARCH" ;; \
    esac && \
    echo https://bintray.com/ookla/download/download_file?file_path=ookla-speedtest-${VERSION}-${_arch}-linux.tgz && \
    curl -fsSL -o /tmp/ookla-speedtest.tgz \
      https://bintray.com/ookla/download/download_file?file_path=ookla-speedtest-${VERSION}-${_arch}-linux.tgz && \
    tar xvfz /tmp/ookla-speedtest.tgz -C /usr/local/bin speedtest && \
    rm -rf /tmp/ookla-speedtest.tgz && \
    adduser -D speedtest && \
    su speedtest -c "speedtest --accept-license --accept-gdpr" && \
    apk del deps

