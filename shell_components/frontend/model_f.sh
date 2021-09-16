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
model_singular() {
    
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

use Joomla\CMS\Factory;
use Joomla\CMS\MVC\Model\ItemModel;
use Joomla\CMS\Language\Multilanguage;

class ${component_ucf}Model${singular_ucf} extends ItemModel {
    protected \$_context = 'com_${component_name}.${vSingular}';

    protected function populateState() {
		\$app = Factory::getApplication('site');
		\$itemId = \$app->input->getInt('id');
		\$this->setState('${vSingular}.id', \$itemId);
		\$this->setState('filter.language', Multilanguage::isEnabled());
	}

    public function getItem( \$itemId = null ) {
		\$user = Factory::getUser();
		\$itemId = (!empty(\$itemId))? \$itemId : (int)\$this->getState('${vSingular}.id');
		
		if ( \$this->_item == null ) {
			\$this->_item = array();
		}

		if (!isset(\$this->_item[\$itemId])) {
			try {
				\$db = \$this->getDbo();
				\$query = \$db->getQuery(true);
				\$query->select('a.*');
				\$query->from(\$db->quoteName('#__${component_name}_${vPlural}', 'a'));
				\$query->where('a.id = ' . (int) \$itemId);
				
				// Filter by published state.
				\$query->where('a.published = 1');

				if (\$this->getState('filter.language')) {
					\$query->where('a.language in (' . \$db->quote(Factory::getLanguage()->getTag()) . ',' . \$db->quote('*') . ')');
				}

				//Authorised
				\$groups = implode(',', \$user->getAuthorisedViewLevels());
				\$query->where('a.access IN (' . \$groups . ')');

				\$db->setQuery(\$query);
				\$data = \$db->loadObject();

				\$this->_item[\$itemId] = \$data;
			}
			catch (Exception \$e) {
				if (\$e->getCode() == 404 ) {
					JError::raiseError(404, \$e->getMessage());
				} else {
					\$this->setError(\$e);
					\$this->_item[\$itemId] = false;
				}
			}
        }
		return \$this->_item[\$itemId];
    }

}
    "
}
model_plural() {
    
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
use Joomla\CMS\Factory;
use Joomla\CMS\MVC\Model\ListModel;
use Joomla\CMS\Language\Multilanguage;

jimport( 'joomla.application.component.helper' );

class ${component_ucf}Model${plural_ucf} extends ListModel
{
	protected function populateState(\$ordering = null, \$direction = null)
	{
		\$app = Factory::getApplication('site');
		\$this->setState('list.start', \$app->input->get('limitstart', 0, 'uint'));
		\$this->setState('filter.language', Multilanguage::isEnabled());
	}

	protected function getListQuery()
	{
		\$db = \$this->getDbo();
		\$query = \$db->getQuery(true);
		\$query->select('a.*');
	  	\$query->from(\$db->quoteName('#__${component_name}_${vPlural}', 'a'));

        \$query->where(\$db->quoteName('a.published') . ' = ' . \$db->quote('1'));

        if (\$this->getState('filter.language')) {
            \$query->where(\$db->quoteName('a.language') . ' IN (' . \$db->quote(Factory::getLanguage()->getTag()) . ',' . \$db->quote('*') . ')');
        }
		return \$query;
	}
}
    "
}

(umask 077 ; touch "${directory}/${vSingular}.php")
(model_singular > "${directory}/${vSingular}.php")
echo "${directory}/${vSingular}.php created."

(umask 077 ; touch "${directory}/${vPlural}.php")
(model_plural > "${directory}/${vPlural}.php")
echo "${directory}/${vPlural}.php created."
