#!/bin/bash
date=`date`
year=`date +%Y`

#functions
create_controller_f_php() {
    cName="$1"
    cname_uca="$(tr a-z A-Z <<<${cName})"
    cname_ucf="$(tr a-z A-Z <<< ${cName:0:1})${cName:1}"
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

class ${cname_ucf}Controller extends JControllerLegacy
{
  public function display(\$cachable=false, \$urlparams=false)
  {
    parent::display(\$cachable,\$urlparams);
    return \$this;
  }
}
"
}
directory=$1
cName=$2
(umask 077 ; touch "${directory}/controller.php")
(create_controller_f_php "$cName" > "${directory}/controller.php")