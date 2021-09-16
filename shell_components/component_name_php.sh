#!/bin/bash
date=`date`
year=`date +%Y`


#functions
create_component_name_php() {
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

use Joomla\CMS\Factory;
use Joomla\CMS\HTML\HTMLHelper;
use Joomla\CMS\Launguage\Text;
use Joomla\CMS\MVC\Controller\BaseController;
use Joomla\CMS\Uri\Uri;

//helper & model
\$com_helper = JPATH_BASE . '/components/com_${cName}/helpers/helper.php';

if (file_exists(\$com_helper))
{
    require_once(\$com_helper);
}
else
{
	echo '<p class=\"alert alert-warning\">' . Text::_('COM_${cname_uca}_COMPONENT_NOT_INSTALLED_OR_MISSING_FILE') . '</p>';
	return;
}

HTMLHelper::_('jquery.framework');
\$doc = Factory::getDocument();

// Include CSS files
\$doc->addStylesheet(Uri::root(true) . '/components/com_${cName}/assets/css/style.css');


\$controller = BaseController::getInstance('${name_ucf}');
\$input 	= Factory::getApplication()->input;
\$view 		= \$input->getCmd('view','default');
\$input->set('view', \$view);
\$controller->execute(\$input->getCmd('task'));
\$controller->redirect();
    "
}
directory=$1
cName=$2
(umask 077 ; touch "${directory}/${cName}.php")
(create_component_name_php "$cName" > "${directory}/${cName}.php")
