FROM alpine:3.10
MAINTAINER Victor Trac <victor@cloudkite.io>

ENV VERSION="1.29.2547.95"

# Build deps
RUN apk --no-cache add --update go git bzr wget py2-pip \ 
    gcc python python-dev make musl-dev linux-headers libffi-dev openssl-dev \
    py-setuptools openssl procps ca-certificates openvpn 
    
RUN pip install --upgrade pip 

# Install go
COPY --from=golang:1.13-alpine /usr/local/go/ /usr/local/go/
ENV PATH="/usr/local/go/bin:${PATH}"

# Pritunl Install
RUN go get github.com/pritunl/pritunl-dns \
    && go get github.com/pritunl/pritunl-web

RUN wget https://github.com/pritunl/pritunl/archive/${VERSION}.tar.gz \
    && tar zxvf ${VERSION}.tar.gz \
    && cd pritunl-${VERSION} \
    && python setup.py build \
    && pip install -r requirements.txt \
    && python2 setup.py install \
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
