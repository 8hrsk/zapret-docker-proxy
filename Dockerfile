FROM sameersbn/squid

RUN mkdir -p /var/log/squid3 && \
    chown proxy:proxy /var/log/squid3

# Setup the environment

RUN apt-get update && \ 
    apt-get install -y init && \
    apt-get clean all

ENV container=docker

COPY container.target /etc/systemd/system/container.target

RUN ln -sf /etc/systemd/system/container.target /etc/systemd/system/default.target

ENTRYPOINT ["/sbin/init"]

RUN apt-get update && \
    apt-get install systemd

STOPSIGNAL SIGRTMIN+3

RUN systemctl set-default multi-user.target

# Download essentials

RUN apt-get install -y curl iptables dnscrypt-proxy lsof && \
    apt-get clean

# Setup directories and files

COPY zapret /opt/zapret

WORKDIR /opt/zapret

ADD configs/zapret.configs /opt/zapret/configs

COPY configs/dnscrypt-proxy.toml /etc/dnscrypt-proxy/dnscrypt-proxy.toml
COPY configs/resolv.conf /etc/resolv.conf
# COPY configs/tinyproxy.conf /etc/tinyproxy/tinyproxy.conf
COPY configs/squid.conf /etc/squid/squid.conf

COPY scripts/enable_services.sh /opt/zapret/enable_services.sh
COPY scripts/iptables.sh /opt/zapret/iptables.sh
COPY scripts/start_zapret.sh /opt/zapret/start_zapret.sh
COPY scripts/blockcheck.sh /opt/zapret/run_blockcheck_in_container.sh

COPY /zapret/init.d/custom.d.examples.linux/50-discord /zapret/init.d/sysv/custom.d/50-discord

COPY start.sh /opt/zapret/start.sh

RUN chmod +x ./install_bin.sh ./install_prereq.sh ./install_easy.sh
RUN chmod +x ./enable_services.sh ./iptables.sh ./start_zapret.sh ./start.sh

# Zapret installation

RUN ./install_bin.sh && \
    echo "1" | ./install_prereq.sh

COPY config /opt/zapret/config

# Add ips to iptables ! Currently unavailable
# RUN ./iptables.sh

CMD [ "/bin/bash" ]