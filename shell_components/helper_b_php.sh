#!/bin/bash
date=`date`
year=`date +%Y`


#functions
create_backend_helper() {
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
use Joomla\CMS\Language\Text;

class ${name_ucf}Helper extends JHelperContent
{

    public static function addSubmenu(\$vName)
    {
        JHtmlSidebar::addEntry(
            Text::_('COM_${cname_uca}_TITLE_VIEW_NAME'),
            'index.php?option=com_${cName}&view=view_plural',
            \$vName === 'view_plural'
        );
        //Every view which is suppose to show in the left side will be added here
	}

	//Debugging function. Removed in the production package
	public static function debug(\$data, \$die = true)
    {
		echo \"<pre>\"; print_r(\$data); echo \"</pre>\"; if(\$die)die;
	}
}

    "
}
directory=$1
cName=$2
(umask 077 ; touch "${directory}/${cName}.php")
(create_backend_helper "$cName" > "${directory}/${cName}.php")
