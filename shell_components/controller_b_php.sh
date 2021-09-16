#!/bin/bash
date=`date`
year=`date +%Y`

#functions
create_controller_b_php() {
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

class ${cname_ucf}Controller extends JControllerLegacy {

  public function display(\$cachable=false,\$urlparams=false){
    \$view   = \$this->input->get('view','default_view_plural');
    \$layout = \$this->input->get('layout','default');
    \$id     = \$this->input->getInt('id');
    \$this->input->set('view',\$view);
    
    if(\$view == 'default_view_singular' && \$layout == 'edit' && !\$this->checkEditId('com_${cName}.edit.default_view_singular',\$id)) {
      \$this->setError(JText::sprintf('JLIB_APPLICATION_ERROR_UNHELD_ID',\$id));
      \$this->setMessage(\$this->getError(),'error');
      \$this->setRedirect(JRoute::_('index.php?option=com_${cName}&view=default_view_plural',false));

      return false;
    }

    parent::display(\$cachable,\$urlparams);

    return \$this;
  }
}
"
}
directory=$1
cName=$2
(umask 077 ; touch "${directory}/controller.php")
(create_controller_b_php "$cName" > "${directory}/controller.php")