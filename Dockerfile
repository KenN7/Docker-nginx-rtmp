FROM alpine:latest as builder

ARG NGINX_VERSION=1.15.3
ARG NGINX_RTMP_VERSION=1.2.1

RUN	apk update		&&	\
	apk add				\
		git			\
		gcc			\
		binutils		\
		gmp			\
		isl			\
		libgomp			\
		libatomic		\
		libgcc			\
		openssl			\
		pkgconf			\
		pkgconfig		\
		mpfr3			\
		mpc1			\
		libstdc++		\
		ca-certificates		\
		libssh2			\
		expat			\
		pcre			\
		musl-dev		\
		libc-dev		\
		pcre-dev		\
		zlib-dev		\
		openssl-dev		\
		curl			\
		make            

RUN	cd /tmp/									&&	\
	curl --remote-name http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz			&&	\
	git clone https://github.com/arut/nginx-rtmp-module.git -b v${NGINX_RTMP_VERSION}

RUN	cd /tmp										&&	\
	tar xzf nginx-${NGINX_VERSION}.tar.gz						&&	\
	cd nginx-${NGINX_VERSION}							&&	\
	./configure										\
		--prefix=/opt/nginx								\
		--with-http_ssl_module								\
		--add-module=../nginx-rtmp-module					&&	\
	make										&&	\
	make install

# FROM alpine:latest
FROM alpine:latest
RUN apk update && apk add \
        python3 \
		openssl \
		libstdc++ \
		ca-certificates \
		pcre \
    && rm -rf /var/cache/apk/*

COPY --from=builder /opt/nginx /opt/nginx
COPY --from=builder /tmp/nginx-rtmp-module/stat.xsl /opt/nginx/conf/stat.xsl
COPY player.html /html/player.html
RUN rm /opt/nginx/conf/nginx.conf
ADD run.sh /run/run.sh
ADD authserv.py /run/authserv.py

EXPOSE 1935
EXPOSE 80

CMD /run/run.sh

