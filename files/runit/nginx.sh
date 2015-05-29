#!/bin/sh

nginx -p `pwd` -c /etc/nginx.conf -g 'daemon off'
