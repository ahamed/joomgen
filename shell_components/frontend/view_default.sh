#!/bin/bash
date=`date`
year=`date +%Y`

directory="$1"
component_name="$2"
vSingular="$3"
vPlural="$4"

component_ucf="$(tr a-z A-Z <<< ${component_name:0:1})${component_name:1}"
component_uca="$(tr a-z A-Z <<<${component_name})"
singular_ucf="$(tr a-z A-Z <<< ${vSingular:0:1})${vSingular:1}"
singular_uca="$(tr a-z A-Z <<< ${vSingular})"
plural_ucf="$(tr a-z A-Z <<< ${vPlural:0:1})${vPlural:1}"
plural_uca="$(tr a-z A-Z <<< ${vPlural})"

#functions
default_view_singular() {
    
    echo "
<?php
/**
* @package com_${component_name}
* @author JoomShaper http://www.joomshaper.com
* @copyright Copyright (c) 2010 - ${year} JoomShaper
* @license http://www.gnu.org/licenses/gpl-2.0.html GNU/GPLv2 or later
*/

// No Direct Access
defined ('_JEXEC') or die('Resticted Aceess');

?>
    "
}
default_view_plural() {
    
    echo "
<?php
/**
* @package com_${component_name}
* @author JoomShaper http://www.joomshaper.com
* @copyright Copyright (c) 2010 - ${year} JoomShaper
* @license http://www.gnu.org/licenses/gpl-2.0.html GNU/GPLv2 or later
*/

// No Direct Access
defined ('_JEXEC') or die('Resticted Aceess');

?>
    "
}

default_xml() {
    echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<metadata>
	<fields name=\"params\" addfieldpath=\"/components/com_${component_name}/fields\">
		<fieldset name=\"basic\" label=\"COM_${component_uca}_VIEW_MENU_OPTIONS\"></fieldset>
	</fields>
</metadata>
    " 
}

singularView="${directory}/${vSingular}/tmpl"
pluralView="${directory}/${vPlural}/tmpl"

mkdir -p "${singularView}"
echo "${singularView} created" 
mkdir -p "${pluralView}"
echo "${pluralView} created" 

(umask 077 ; touch "${singularView}/default.php")
(default_view_singular > "${singularView}/default.php")
echo "${directory}/default.php created."

(umask 077 ; touch "${pluralView}/default.php")
(default_view_plural > "${pluralView}/default.php")
echo "${directory}/default.php created."

(umask 077 ; touch "${pluralView}/default.xml")
(default_xml > "${pluralView}/default.xml")
echo "${directory}/default.xml created."
