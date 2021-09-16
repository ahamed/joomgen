#!/bin/bash
date=`date`
year=`date +%Y`

#functions
create_router_php() {
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

class ${cname_ucf}Router extends JComponentRouterView
{
	protected \$noIDs = false;

	public function __construct(\$app = null, \$menu = null)
	{
        \$params = JComponentHelper::getParams('com_${cName}');
		\$this->noIDs = (bool) \$params->get('sef_ids', 1);
        
        //Register your views here


        parent::__construct(\$app, \$menu);	
		\$this->attachRule(new JComponentRouterRulesNomenu(\$this));

		if (\$params->get('sef_advanced', 0)) {
			\$this->attachRule(new JComponentRouterRulesMenu(\$this));
			\$this->attachRule(new JComponentRouterRulesStandard(\$this));
		} else {
			JLoader::register('${cname_ucf}RouterRulesLegacy', __DIR__ . '/helpers/legacyrouter.php');
			\$this->attachRule(new ${cname_ucf}RouterRulesLegacy(\$this));
		}
    }
}

function ${cName}BuildRoute(&\$query){
	\$app = JFactory::getApplication();
	\$router = new ${cname_ucf}Router(\$app, \$app->getMenu());

	return \$router->build(\$query);
}

function ${cName}ParseRoute(\$segments){
	\$app = JFactory::getApplication();
	\$router = new ${cname_ucf}Router(\$app, \$app->getMenu());

	return \$router->parse(\$segments);
}
"
}
directory=$1
cName=$2
(umask 077 ; touch "${directory}/router.php")
(create_router_php "$cName" > "${directory}/router.php")