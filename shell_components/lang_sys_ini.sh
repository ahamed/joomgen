#!/bin/bash
date=`date`
year=`date +%Y`

#functions
create_lang_sys_ini() {
    cName="$1"
    cname_uca="$(tr a-z A-Z <<<${cName})"
    cname_ucf="$(tr a-z A-Z <<< ${cName:0:1})${cName:1}"
    echo "
COM_${cname_uca}=\"${cName}\"
${cname_uca}=\"${cName}\"
    "
}
directory=$1
cName=$2
(umask 077 ; touch "${directory}/en-GB.com_${cName}.sys.ini")
(create_lang_sys_ini "$cName" > "${directory}/en-GB.com_${cName}.sys.ini")