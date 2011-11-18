#!/bin/bash


#function init() {
	# check default config
#	if [ -e $DEFAULT_CONFIG ]; then
#		. $DEFAULT_CONFIG
#	else
#		print_error "Config file $DEFAULT_CONFIG doesn't exist!"
#	fi
#}

# library initialization. no parameters needed
function init() {

	QUIET=0			# Quiet mode. 0=Enable output messages, 1=Disable any output
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

# REQUIRES: 1=ResponseCode
function response_code() {

	case $1 in
		202 ) TXT="OK" ;;
		204 ) TXT="OK" ;;
		400 ) TXT="Incorrect request" ;;
		404 ) TXT="Server or object not found" ;;
		405 ) TXT="Function temporarily unavailable" ;;
		500 ) TXT="Internal API error. Try again later" ;;
		*   ) TXT="" ;;
	esac
	
	if [ -n "$TXT" ]; then
		echo $TXT
	fi
}

# REQUIRES: 1=RequestToAPI
function send_request_nocontent() {

	RESPONSE=`echo "$1" | grep 'HTTP/1.1' | awk '{print $2}'`
	
	case $RESPONSE in
		202 ) return 0 ;;
		204 ) return 0 ;;
		
		*   ) 
			if [ $QUIET -lt 1 ]; then
				response_code $RESPONSE
			fi
			return 4 ;;
	esac
}


# REQUIRES: 1=ServerNum
function reboot_server() { 

	if [ -z $1 ]; then
		return 3
	fi

	if send_request_nocontent "$(curl -I -s -H "X-Auth-Token: ${API_TOKEN}" $API_URL/servers/${1}/reboot)"; then
		return 0
	else
		return $?
	fi	
}

# REQUIRES: 1=ServerNum
function start_server() {

	if [ -z $1 ]; then
		return 3
	fi

	if send_request_nocontent "$(curl -I -s -H "X-Auth-Token: ${API_TOKEN}" $API_URL/servers/${1}/start)"; then
		return 0
	else
		return $?
	fi	
}

# REQUIRES: 1=ServerNum
function shutdown_server() { 

	if [ -z $1 ]; then
		return 3
	fi

	if send_request_nocontent "$(curl -I -s -H "X-Auth-Token: ${API_TOKEN}" $API_URL/servers/${1}/stop)"; then
		return 0
	else
		return $?
	fi	
}

# REQUIRES: 1=ServerNum, 2=OsImageId, 3=IsISP
function reinstall_server() { 

	if [ -z $1 -o -z $2 ]; then
		return 3
	fi
	
#	if [ -n $3 ]; then
#		REQ_STRING="curl -I -s -H 'X-Auth-Token: ${API_TOKEN}' -d 'imageId=${2}&vps_isp' $API_URL/servers/${1}/stop"
#	else
#		REQ_STRING="curl -I -s -H 'X-Auth-Token: ${API_TOKEN}' -d 'imageId=${2}' $API_URL/servers/${1}/stop"
#	fi
	
	REQ_STRING="curl -I -H \"X-Auth-Token: $API_TOKEN\" $API_URL/servers/${1}/restart"
	
echo $REQ_STRING

#echo send_request_nocontent "$("$REQ_STRING")"
	if send_request_nocontent "$($REQ_STRING)"; then
		return 0
	else
		return $?
	fi	
}



# init clodo-utils 
init
