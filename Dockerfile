FROM thimico/alpine
MAINTAINER Thiago Menezes <thimico@me.com>

ENV DB_HOST localhost
ENV DB_PORT 3306
ENV DB_USER zabbix
ENV DB_PASS zabbix

# Copy init scripts
COPY rootfs /

# Install zabbix
RUN echo '@community http://nl.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories && \
    echo '@edge http://nl.alpinelinux.org/alpine/edge/main' >> /etc/apk/repositories && \
    apk add --update \
    bash \
    python \
    py2-pip \
    tzdata \
    py-pip \
    net-snmp-dev \
    net-snmp-libs \
    net-snmp \
    net-snmp-perl \
    net-snmp-tools \
    mysql-client \
    zabbix@community \
    zabbix-setup@community \
    zabbix-mysql@community \
    zabbix-agent@community \
    zabbix-utils@community \
    && pip install --upgrade pip \
    && pip install git+https://github.com/verdel/j2cli.git \
    && pip install requests \
    && apk del build-dependencies \
    # Clean up
    && rm -rf \
    /usr/share/man \
    /tmp/* \
    /var/cache/apk/*

# Add s6-overlay
ENV S6_OVERLAY_VERSION v1.21.4.0

RUN apk add --update curl && \
    curl -sSL https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-amd64.tar.gz \
    | tar xvfz - -C / && \
    apk del curl && \
    rm -rf /var/cache/apk/*

RUN chmod 640 /etc/zabbix/zabbix_server.conf
RUN chown root:zabbix /etc/zabbix/zabbix_server.conf
RUN cp /usr/share/zoneinfo/Brazil/East  /etc/localtime
RUN echo "Brazil/East" >  /etc/timezone

# Export volumes directory
VOLUME ["/etc/zabbix/alertscripts", "/etc/zabbix/externalscripts", "/etc/zabbix/tls"]

# Export ports
EXPOSE 10051/tcp 10052/tcp
