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
#	echo $API_URL
#	echo $API_TOKEN
else
	print_error "- AUTH ($?)"
	exit 1
fi

#if reboot $SERVER_NUM; then
#	print_good "+ REBOOT"
#else
#	print_error "- REBOOT ($?)"
#	exit 1
#fi

if reinstall_server $SERVER_NUM 551; then
	print_good "+ REINSTALL"
else
	print_error "- REINSTALL ($?)"
	exit 1
fi
