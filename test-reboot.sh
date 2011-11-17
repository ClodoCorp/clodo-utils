#!/bin/bash

. clodo-utils.sh
. ~/.clodo-utils

# some functions for colorized output
function print_error() {
	echo -e "\033[01;31m${1}\033[01;00m"
}
function print_good() {
	echo -e "\033[01;32m${1}\033[01;00m"
}



if auth $CLODO_USER $CLODO_KEY "KH"; then
	print_good "+ AUTH"
	echo $API_URL
	echo $API_TOKEN
	echo; echo; echo
else
	print_error "- AUTH"
	exit 1
fi

if reboot $SERVER_NUM; then
	print_good "+ REBOOT"
	echo;echo;echo
else
	print_error "- REBOOT"
	echo send_request_nocontent; echo
	echo "$(curl -I -s -H "X-Auth-Token: ${API_TOKEN}" $API_URL/servers/${SERVER_NUM}/reboot)"
fi
