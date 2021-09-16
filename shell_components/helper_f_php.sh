#!/bin/bash
date=`date`
year=`date +%Y`


#functions
create_frontend_helper() {
    cName="$1"
    cname_uca="$(tr a-z A-Z <<<${cName})"
    name_ucf="$(tr a-z A-Z <<< ${cName:0:1})${cName:1}"
    echo "
<?php
/**
* @package com_${cName}
* @author JoomShaper http://www.joomshaper.com
* @copyright Copyright (c) 2010 - ${year} JoomShaper
* @license http://www.gnu.org/licenses/gpl-2.0.html GNU/GPLv2 or later
*/

// No Direct Access
defined ('_JEXEC') or die('Resticted Aceess');

class ${name_ucf}Helper {
	
	public static function debug(\$data, \$die = true) {
		echo \"<pre>\"; print_r(\$data); echo \"</pre>\";
		if (\$die) die;
	}

	public static function pluralize(\$amount, \$singular, \$plural) {
		\$amount = (int)\$amount;
		if (\$amount <= 1) {
			return JText::_(\$singular);
		}
		return JText::_(\$plural);
	}
}
    "
}
directory=$1
cName=$2
(umask 077 ; touch "${directory}/helper.php")
(create_frontend_helper "$cName" > "${directory}/helper.php")
