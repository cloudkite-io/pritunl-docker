FROM alpine:3.19.1
LABEL maintainer="Victor Trac <victor@cloudkite.io>"

ENV VERSION="1.32.3897.75"

# Build deps
RUN apk --no-cache add --update go git breezy wget py3-pip \ 
    gcc python3 python3-dev make musl-dev linux-headers libffi-dev \
    ipset iptables ip6tables openssl-dev py3-dnspython py3-requests \
    py3-setuptools py3-six openssl procps ca-certificates openvpn

RUN rm /usr/lib/python*/EXTERNALLY-MANAGED \
    && python3 -m ensurepip \ 
    && pip3 install --no-cache-dir --upgrade pip 

# Install go and deps
COPY --from=golang:1.22-alpine /usr/local/go/ /usr/local/go/
ENV PATH="/usr/local/go/bin:${PATH}"

RUN go install github.com/pritunl/pritunl-dns@latest \
    && go install github.com/pritunl/pritunl-web@latest \
    && cp $HOME/go/bin/* /usr/bin

# Install Pritunl
RUN wget https://github.com/pritunl/pritunl/archive/refs/tags/${VERSION}.tar.gz \
    && tar zxvf ${VERSION}.tar.gz \
    && cd pritunl-${VERSION} \
    && python3 setup.py build \
    && pip3 install -r requirements.txt \
    && mkdir -p /var/lib/pritunl \
    && python3 setup.py install \
    && cd .. \
    && rm -rf *${VERSION}* \
    && rm -rf /tmp/* /var/cache/apk/*

RUN sed -i -e '/^attributes/a prompt\t\t\t= yes' /etc/ssl/openssl.cnf
RUN sed -i -e '/countryName_max/a countryName_value\t\t= US' /etc/ssl/openssl.cnf

ADD rootfs /

EXPOSE 80
EXPOSE 443
EXPOSE 1194
ENTRYPOINT ["/init"]
