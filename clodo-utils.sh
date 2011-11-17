#!/bin/bash


function init() {
	# check default config
	if [ -e $DEFAULT_CONFIG ]; then
		. $DEFAULT_CONFIG
	else
		print_error "Config file $DEFAULT_CONFIG doesn't exist!"
	fi
}


# REQUIRES: 1=AuthUser 2=API_Key 3=Datacenter (KH or OVERSUN)
function auth() {

	CLODO_USER=$1
	CLODO_KEY=$2
	CLODO_DC=$3
	
	if [ "$CLODO_DC" = "KH" ]; then
		    API_LINK="http://api.kh.clodo.ru"
	else
		    API_LINK="http://api.clodo.ru"
	fi
	
	AUTH_DATA="$(curl -I -s -H "X-Auth-User: ${CLODO_USER}" -H "X-Auth-Key: ${CLODO_KEY}" $API_LINK)"
	
	if [ -z "$AUTH_DATA" ]; then
		# echo "ERROR: Can't find Cloud Storage server"
		return 2
	fi
	
	ERR=`echo "$AUTH_DATA" | grep 'Unauthorized'`
	if [ $? -eq 0 ]; then
		return 4
		# print_error "Can't get authorization! Check config $DEFAULT_CONFIG"
	fi

    API_URL=`echo "$AUTH_DATA" | grep 'X-Server-Management-Url' | sed 's/X-Server-Management-Url: \(.*\)\r/\1/'`
	if [ -z "$API_URL" ]; then
		return 4
		# print_error "Can't get API URL"
	fi

    API_TOKEN=`echo "$AUTH_DATA" | grep 'X-Auth-Token' | sed 's/X-Auth-Token: \(\w*\)\r/\1/'`
	if [ -z "$API_TOKEN" ]; then
		return 4
		# print_error "Can't get API TOKEN"
	fi
	
	return 0
}


# REQUIRES: 1=RequestToAPI
function send_request_nocontent() {
	
	RESPONSE=`echo "$1" | grep 'HTTP/1.1' | awk '{print $2}'`

	case $RESPONSE in
		202 ) return 0 ;;
		204 ) return 0 ;;
		* ) return 1 ;;
	esac
}


# REQUIRES: 1=ServerNum
function reboot() { 

	if send_request_nocontent "$(curl -I -s -H "X-Auth-Token: ${API_TOKEN}" $API_URL/servers/${1}/reboot)"; then
		return 0
	else
		return $?
	fi	
}

