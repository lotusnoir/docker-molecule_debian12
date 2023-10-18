FROM debian:12
LABEL maintainer="lotusnoir"

ARG container docker
ARG LC_ALL C
ARG DEBIAN_FRONTEND noninteractive
STOPSIGNAL SIGRTMIN+3

RUN apt-get update \
    && apt-get install -y --no-install-recommends mlocate apt-utils locales systemd systemd-sysv sudo python3-apt python3-pip python3-setuptools python3-wheel iproute2 net-tools procps wget ca-certificates \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc /usr/share/man \
    && apt-get clean

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LANGUAGE en_US:en      

RUN pip3 install --break-system-packages --no-cache-dir --upgrade pip \
    && pip3 install --break-system-packages --no-cache-dir ansible cryptography jmespath

RUN wget -q -O /usr/local/bin/goss https://github.com/aelsabbahy/goss/releases/download/v0.4.2/goss-linux-amd64 && chmod +x /usr/local/bin/goss

RUN mkdir -p /lib/systemd && ln -s /lib/systemd/system /usr/lib/systemd/system;
RUN rm -f /lib/systemd/system/multi-user.target.wants/* \
    /etc/systemd/system/*.wants/* \
    /lib/systemd/system/local-fs.target.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* \
    /lib/systemd/system/sockets.target.wants/*initctl* \
    /lib/systemd/system/sysinit.target.wants/systemd-tmpfiles-setup* \
    /lib/systemd/system/systemd-update-utmp*

VOLUME [ "/tmp", "/run", "/run/lock" ]
ENTRYPOINT ["/lib/systemd/systemd", "log-level=info", "unit=sysinit.target"]
