#!/bin/bash
date=`date`

#functions
create_config_xml() {
    cName="$1"
    cname_uca="$(tr a-z A-Z <<<${cName})"
    echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<config>
    <fieldset name=\"basic\" label=\"COM_${cname_uca}_FIELDSET_BASIC_LABEL\"></fieldset>
    <fieldset name=\"permissions\" label=\"JCONFIG_PERMISSIONS_LABEL\" description=\"JCONFIG_PERMISSIONS_DESC\">
        <field name=\"rules\" type=\"rules\" label=\"JCONFIG_PERMISSIONS_LABEL\" filter=\"rules\" component=\"com_${cName}\" section=\"component\" />
    </fieldset>
</config>
    "
}
directory=$1
cName=$2
(umask 077 ; touch "${directory}/config.xml")
(create_config_xml "$cName" > "${directory}/config.xml")
