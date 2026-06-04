FROM alpine:3.22

RUN apk update && apk add --no-cache \
	nginx \
	openssl \
	gettext

RUN mkdir -p /run/nginx /etc/nginx/ssl

#Copy nginx as a template
COPY ./conf/nginx.conf /etc/nginx/http.d/default.conf.template

#Copy setup script
COPY ./tools/setup_nginx.sh /usr/local/bin/
COPY ./tools/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup_nginx.sh /usr/local/bin/entrypoint.sh

#Expose the pre-defined nginx port
EXPOSE 443

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
