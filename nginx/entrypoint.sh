#!/bin/bash -x


# Set the uid:gid to run as
[ "$nginx_uid" ] && usermod  -o -u "$nginx_uid" nginx
[ "$nginx_gid" ] && groupmod -o -g "$nginx_gid" nginx


# chown -r the /www folder only if owned by root. We asume that means it's a docker volume
[ "$(stat -c %u:%g /www)" = "0:0" ] && chown nginx:nginx /www


# Also enable ssl in addition to http, if specified. Requires cert files in /ssl folder
[ "$nginx_ssl" ] && ln -sf /etc/nginx/sites-available/default-ssl /etc/nginx/sites-enabled/default-ssl


if [ "$pipework_wait" ]; then
	for _pipework_if in $pipework_wait; do
		echo "Waiting for pipework to bring up $_pipework_if..."
		pipework --wait -i $_pipework_if
	done
	sleep 1
fi


# Copy "$@" special variable into a regular variable
_nginx_args="$@"


# Start nginx
nginx $_nginx_args

