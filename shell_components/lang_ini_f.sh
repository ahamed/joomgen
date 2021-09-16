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
COM_${cname_uca}_COMPONENT_NOT_INSTALLED_OR_MISSING_FILE=\"Component not installed or missing file!\"

COM_${cname_uca}_NO_RECORD_FOUND=\"No Record Found!\"
    "
}
directory=$1
cName=$2
(umask 077 ; touch "${directory}/en-GB.com_${cName}.ini")
(create_lang_sys_ini "$cName" > "${directory}/en-GB.com_${cName}.ini")