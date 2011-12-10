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
#	echo $API_TOKEN
else
	print_error "- AUTH ($?)"
	exit 1
fi

if create_virtual_server "TestCreate" 256 7 0 1; then
	print_good "+ CREATE SERVER"
else
	print_error "- CREATE SERVER ($?)"
	exit 1
fi



# SCALE
# Request URL:https://testapi.kh.clodo.ru/v1/servers/?callback=jQuery16108745810857508332_1323538727553&vps_type=ScaleServer&vunit_type=medium&vbd_type=sas&vbd_size=5&vps_plan=0&vps_cpu_speed=0&vps_memory=512&vps_lan=0&vps_ip_count=1&vps_title=&vps_admin=1&vps_reserve=&vps_os_version=111&vps_os_bits=64&vps_os_hvm=0&users_id=8271&bitrix_recovery=0&vps_isp=&vps_swapsize=128&vps_hddshaper=1&vps_memory_max=4096&vps_memblocksize=1&vps_minfreebytes=128&vps_meminterval=1&http_type=post&X-Auth-Token=CLODO_2f552ae97d9c998fb65154264efcdebb&_=1323541658243

# VIRTUAL
# Request URL:https://testapi.kh.clodo.ru/v1/servers/?callback=jQuery16108745810857508332_1323538727625&vps_type=VirtualServer&vunit_type=medium&vbd_type=sas&vbd_size=5&vps_cpu_count=4&vps_cpu_speed=2267&vps_memory=256&vps_lan=0&vps_ip_count=1&vps_title=asdasdasdasd&vps_admin=1&vps_reserve=&vps_os_version=111&vps_os_bits=64&vps_os_hvm=0&users_id=8271&bitrix_recovery=0&vps_isp=&vps_swapsize=128&vps_hddshaper=1&vps_winusers=1&vps_abonement=1&vps_pay_period=h&http_type=post&X-Auth-Token=CLODO_2f552ae97d9c998fb65154264efcdebb&_=1323542193834
