FROM alpine:3.15.4
LABEL MAINTAINER Victor Trac <victor@cloudkite.io>

ENV VERSION="1.30.3116.68"

RUN apk -U upgrade

# Build deps
RUN apk --no-cache add --update go git wget py3-pip \ 
    gcc python3 python3-dev cargo make musl-dev linux-headers libffi-dev openssl-dev \
    py-setuptools openssl procps ca-certificates openvpn 
    
RUN pip install --upgrade pip

# Pritunl Install
RUN export GOPATH=/go \
    && go get github.com/pritunl/pritunl-dns \
    && go get github.com/pritunl/pritunl-web \
    && cp /go/bin/* /usr/bin/ 

RUN wget https://github.com/pritunl/pritunl/archive/refs/tags/${VERSION}.tar.gz \
    && ls -lh \
    && tar -zxvf ${VERSION}.tar.gz \
    && cd pritunl-${VERSION} \
    && python3 setup.py build \
    && pip install -r requirements.txt \
    && python3 setup.py install \
    && cd .. \
    && rm -rf *${VERSION}* \
    && rm -rf /tmp/* /var/cache/apk/*

RUN sed -i -e '/^attributes/a prompt\t\t\t= yes' /etc/ssl1.1/openssl.cnf
RUN sed -i -e '/countryName_max/a countryName_value\t\t= US' /etc/ssl1.1/openssl.cnf

ADD rootfs /

EXPOSE 80
EXPOSE 443
EXPOSE 1194
ENTRYPOINT ["/init"]
