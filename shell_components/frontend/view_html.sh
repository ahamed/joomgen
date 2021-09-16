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
view_html_singular() {
    
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

use Joomla\CMS\MVC\View\HtmlView;

class ${component_ucf}View${singular_ucf} extends HtmlView {

    protected \$item;

    public function display(\$tpl = null) {
        \$model      = \$this->getModel();
        \$this->item = \$this->get('Item');

        return parent::display(\$tpl = null);
    }
}
    "
}
view_html_plural() {
    
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

use Joomla\CMS\MVC\View\HtmlView;

class ${component_ucf}View${plural_ucf} extends HtmlView
{

    protected \$items; 
	protected \$pagination;

    public function display(\$tpl = null)
    {
        \$model 			= \$this->getModel();
		\$this->items		= \$this->get('Items');
		\$this->pagination	= \$this->get('Pagination');

        return parent::display(\$tpl = null);
    }
}
    "
}

metadata_xml() {
    echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<metadata>
	<view>
		<options>
			<default name=\"COM_${component_uca}_VIEW_NAME\" />
		</options>
	</view>
</metadata>
    "
}

singularView="${directory}/${vSingular}"
pluralView="${directory}/${vPlural}"
mkdir -p "${singularView}"
echo "${singularView} created" 
mkdir -p "${pluralView}"
echo "${pluralView} created" 

(umask 077 ; touch "${singularView}/view.html.php")
(view_html_singular > "${singularView}/view.html.php")
echo "${directory}/view.html.php created."

(umask 077 ; touch "${pluralView}/view.html.php")
(view_html_plural > "${pluralView}/view.html.php")
echo "${directory}/view.html.php created."

(umask 077 ; touch "${pluralView}/metadata.xml")
(metadata_xml > "${pluralView}/metadata.xml")
echo "${directory}/metadata.xml created."
