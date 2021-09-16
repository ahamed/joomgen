#!/bin/bash

#constants
DIR=`pwd`

#variables
year=`date +%Y`

component_name="$1"

echo "Enter view name (singular): "
read vSingular

echo "Enter view name (plural): "
read vPlural

component_ucf="$(tr a-z A-Z <<< ${component_name:0:1})${component_name:1}"
component_uca="$(tr a-z A-Z <<<${component_name})"
singular_ucf="$(tr a-z A-Z <<< ${vSingular:0:1})${vSingular:1}"
singular_uca="$(tr a-z A-Z <<< ${vSingular})"
plural_ucf="$(tr a-z A-Z <<< ${vPlural:0:1})${vPlural:1}"
plural_uca="$(tr a-z A-Z <<< ${vPlural})"

#predicted table name
table_name="#__${component_name}_${vPlural}"


#functions
write_singular_controller(){
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

class "${component_ucf}"Controller"${singular_ucf}" extends JControllerForm {
	public function __construct(\$config = array())
	{
		parent::__construct(\$config);
	}

	protected function allowAdd(\$data = array())
	{
		return parent::allowAdd(\$data);
	}

	protected function allowEdit(\$data = array(), \$key = 'id')
	{
        \$id = (int) isset(\$data[\$key]) ? \$data[\$key] : 0;
		\$user = Factory::getUser();

		if (!\$id) {
			return parent::allowEdit(\$data, \$key);
		}

		if (\$user->authorise('core.edit', 'com_${component_name}.${vSingular}.' . \$id)) {
			return true;
		}

		if (\$user->authorise('core.edit.own', 'com_${component_name}.${vSingular}.' . \$id)) {
			\$record = \$this->getModel()->getItem(\$id);
			if (empty(\$record)) {
				return false;
			}
			return \$user->id === \$record->created_by;
		}
		return false;
	}
}
	"
}

write_plural_controller(){
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
use Joomla\Utilities\ArrayHelper;

class "${component_ucf}"Controller"${plural_ucf}" extends JControllerAdmin
{
	public function getModel(\$name = '${singular_ucf}', \$prefix = '"${component_ucf}"Model', \$config = array('ignore_request' => true))
	{
		\$model = parent::getModel(\$name, \$prefix, \$config);
		return \$model;
	}
}
		"
}

write_singular_model(){
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
use Joomla\CMS\Table\Table;
use Joomla\String\StringHelper;

class "${component_ucf}"Model"${singular_ucf}" extends JModelAdmin
{
	protected \$text_prefix = 'COM_${component_uca}';

	public function getTable(\$name = '${singular_ucf}', \$prefix = '"${component_ucf}"Table', \$config = array())
	{
		return Table::getInstance(\$name, \$prefix, \$config);
	}

	public function getForm(\$data = array(), \$loadData = true)
	{
		\$app = Factory::getApplication();
		\$form = \$this->loadForm('com_${component_name}.${vSingular}','${vSingular}',array('control' => 'jform', 'load_data' => \$loadData));

		if (empty(\$form))
		{
			return false;
		}

		return \$form;
	}

	public function loadFormData()
	{
		\$data = Factory::getApplication()
			->getUserState('com_${component_name}.edit.${vSingular}.data',array());

		if (empty(\$data))
		{
			\$data = \$this->getItem();
		}

		return \$data;
	}

	protected function canDelete(\$record)
	{
		if (!empty(\$record->id))
		{
			if (\$record->published != -2)
			{
				return ;
			}

			\$user = Factory::getUser();

			return parent::canDelete(\$record);
		}
	}

	protected function canEditState(\$record)
	{
		return parent::canEditState(\$record);
	}

	public function getItem(\$pk = null)
	{
		return parent::getItem(\$pk);
	}

  private function generateNewTitleLocally(\$alias, \$title)
  {
    // Alter the title & alias
    \$table = \$this->getTable();

    while (\$table->load(array('alias' => \$alias)))
	{
      \$title = StringHelper::increment(\$title);
      \$alias = StringHelper::increment(\$alias, 'dash');
    }

    return array(\$title, \$alias);
  }

	public function save(\$data)
	{
		\$input = Factory::getApplication()->input;
		\$task 	= \$input->get('task');

		if (\$task === 'save2copy')
		{
			\$originalTable = clone \$this->getTable();
			\$originalTable->load(\$input->getInt('id'));

			if (\$data['title'] == \$originalTable->title)
			{
				list(\$title, \$alias) = \$this->generateNewTitleLocally(\$data['alias'], \$data['title']);
				\$data['title'] = \$title;
				\$data['alias'] = \$alias;
			}
			else
			{
				if (\$data['alias'] === \$originalTable->alias)
				{
					\$data['alias'] = '';
				}
			}

			\$data['published'] = 0;
		}
		if (parent::save(\$data))
			return true;
		return false;
	}
}
	"
}

write_plural_model(){
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

class "${component_ucf}"Model"${plural_ucf}" extends JModelList
{
	public function __construct(array \$config = array())
	{
		if (empty(\$config['filter_fields']))
		{
			\$config['filter_fields'] = [
				'id','a.id',
				'title', 'a.title',
				'ordering', 'a.ordering',
				'created_by', 'a.created_by',
				'created', 'a.created',
				'published', 'a.published',
				'id', 'a.id'
			];
		}
		parent::__construct(\$config);
	}

	protected function populateState(\$ordering = 'a.ordering', \$direction = 'asc')
	{
		\$app = Factory::getApplication();
		\$context = \$this->context;

		\$search = \$this->getUserStateFromRequest(\$this->context . '.filter.search', 'filter_search');
		\$this->setState('filter.search', \$search);

		\$access = \$this->getUserStateFromRequest(\$this->context . '.filter.access', 'filter_access');
		\$this->setState('filter.access', \$access);

		\$published = \$this->getUserStateFromRequest(\$this->context . '.filter.published', 'filter_published', '');
		\$this->setState('filter.published', \$published);

		\$language = \$this->getUserStateFromRequest(\$this->context . '.filter.language', 'filter_language', '');
		\$this->setState('filter.language', \$language);

		parent::populateState(\$ordering, \$direction);
	}

	protected function getStoreId(\$id = '')
	{
		\$id .= ':' . \$this->getState('filter.search');
		\$id .= ':' . \$this->getState('filter.access');
		\$id .= ':' . \$this->getState('filter.published');
		\$id .= ':' . \$this->getState('filter.language');

		return parent::getStoreId(\$id);
	}

	protected function getListQuery()
	{
		\$app 	= Factory::getApplication();
		\$state = \$this->get('State');
		\$db 	= Factory::getDbo();
		\$query = \$db->getQuery(true);

		\$query->select('a.*, l.title_native as lang');
		\$query->from(\$db->quoteName('${table_name}', 'a'));
		\$query->join('LEFT' , \$db->quoteName('#__languages', 'l') . ' ON (' . \$db->quoteName('a.language') . ' = ' . \$db->quoteName('l.lang_code') . ' )');
		
		// Join over the users for the checked out user.
		\$query->select('uc.name AS editor')
			->join('LEFT', '#__users AS uc ON uc.id=a.checked_out');

		\$query->select('ua.name AS author_name')
			->join('LEFT', '#__users AS ua ON ua.id = a.created_by');

		\$query->select('ug.title AS access_title')
			->join('LEFT','#__viewlevels AS ug ON ug.id = a.access');

		if (\$status = \$this->getState('filter.published')) {
			if (\$status != '*')
				\$query->where(\$db->quoteName('a.published') . ' = ' . \$status);
		} else {
			\$query->where(\$db->quoteName('a.published') . ' IN (0,1)');
		}
		\$orderCol 	= \$this->getState('list.ordering','a.ordering');
		\$orderDirn = \$this->getState('list.direction','desc');

		\$order = \$db->escape(\$orderCol) . ' ' . \$db->escape(\$orderDirn);
		\$query->order(\$order);

		return \$query;
	}
}
	"
}

write_table(){
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

use Joomla\CMS\Application\ApplicationHelper;
use Joomla\CMS\Date\Date;
use Joomla\CMS\Factory;
use Joomla\CMS\Table\Table;

class "${component_ucf}"Table"${singular_ucf}" extends Table
{
	public function __construct(&\$db)
	{
		parent::__construct('${table_name}', 'id', \$db);
	}

	public function bind(\$src, \$ignore = array())
	{
		return parent::bind(\$src, \$ignore);
	}

	public function store(\$updateNulls = false)
	{
		\$user = Factory::getUser();
		\$app  = Factory::getApplication();
		\$date = new Date('now', \$app->getCfg('offset'));

		if (\$this->id)
		{
			\$this->modified = (string)\$date;
			\$this->modified_by = \$user->get('id');
		}

		if (empty(\$this->created))
		{
			\$this->created = (string)\$date;
		}

		if (empty(\$this->created_by))
		{
			\$this->created_by = \$user->get('id');
		}

		\$table = Table::getInstance('${singular_ucf}','"${component_ucf}"Table');

		if (\$table->load(['alias' => \$this->alias]) && (\$table->id != \$this->id || \$this->id == 0))
		{
			\$this->setError(Text::_('COM_"${component_uca}"_ERROR_UNIQUE_ALIAS'));
			return false;
		}

		return parent::store(\$updateNulls);
	}

	public function check()
	{
		if (trim(\$this->title) == '')
		{
			throw new UnexpectedValueException(sprintf('The title is empty'));
		}

        \$this->handleAlias();

		return true;
    }

    private function handleAlias()
	{
        if (empty(\$this->alias))
		{
			\$this->alias = \$this->title;
		}

		\$this->alias = ApplicationHelper::stringURLSafe(\$this->alias, \$this->language);

		if (trim(str_replace('-','',\$this->alias)) === '')
		{
			\$this->alias = Factory::getDate()->format('Y-m-d-H-i-s');
		}
    }

	public function publish(\$pks = null, \$published = 1, \$userId = 0)
	{
		\$k = \$this->_tbl_key;
		JArrayHelper::toInteger(\$pks);
		\$publilshed = (int) \$published;

		if (empty(\$pks))
		{
			if (\$this->\$k)
			{
				\$pks = array(\$this->\$k);
			}
			else
			{
				\$this->setError(Text::_('JLIB_DATABASE_ERROR_NO_ROWS_SELECTED'));
				return false;
			}
        }

		\$where = \$k . '=' . implode(' OR '. \$k . ' = ', \$pks);
		\$query = \$this->_db->getQuery(true)
			->update(\$this->_db->quoteName(\$this->_tbl))
			->set(\$this->_db->quoteName('published') . ' = '. \$published)
			->where(\$where);

		\$this->_db->setQuery(\$query);

		try
		{
			\$this->_db->execute();
		}
		catch(\RuntimeException \$e)
		{
			\$this->setError(\$e->getMessage());
			return false;
		}

		if (in_array(\$this->\$k, \$pks))
		{
			\$this->published = \$published;
		}

		\$this->setError('');

		return true;
	}
}
	"
}

write_singular_view_dot_html(){
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
use Joomla\CMS\Toolbar\ToolbarHelper;
use Joomla\CMS\MVC\View\HtmlView;

class "${component_ucf}"View"${singular_ucf}" extends HtmlView
{
	protected \$item;
	protected \$form;

	public function display(\$tpl = null)
	{
		\$this->item = \$this->get('Item');
		\$this->form = \$this->get('Form');

		if (count(\$errors = \$this->get('Errors')))
		{
			JError::raiseError(500, implode('<br>',\$errors));
			return false;
		}

		\$this->addToolbar();

		return parent::display(\$tpl);
	}

	protected function addToolbar()
	{
		\$input = Factory::getApplication()->input;
		\$input->set('hidemainmenu',true);

		\$user = Factory::getUser();
		\$userId = \$user->get('id');
		\$isNew = \$this->item->id == 0;
		\$canDo = "${component_ucf}"Helper::getActions('com_${component_name}','component');

		ToolbarHelper::title(Text::_('COM_${component_uca}_${singular_uca}_TITLE_' . (\$isNew ? 'ADD' : 'EDIT')), '');

		if (\$canDo->get('core.edit'))
		{
			ToolbarHelper::apply('${vSingular}.apply','Toolbar_APPLY');
			ToolbarHelper::save('${vSingular}.save','Toolbar_SAVE');
			ToolbarHelper::save2new('${vSingular}.save2new');
			ToolbarHelper::save2copy('${vSingular}.save2copy');
		}

		ToolbarHelper::cancel('${vSingular}.cancel','Toolbar_CLOSE');
	}
}
	"
}

write_plural_view_dot_html(){
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
use Joomla\CMS\MVC\View\HtmlView;
use Joomla\CMS\Toolbar\Toolbar;
use Joomla\CMS\Toolbar\ToolbarHelper;

class "${component_ucf}"View"${plural_ucf}" extends HtmlView
{
	protected \$items;
	protected \$state;
	protected \$pagination;
	protected \$model;
	public \$filterForm, \$activeFilters;

	public function display(\$tpl = null)
	{
		\$this->items			= \$this->get('Items');
		\$this->state			= \$this->get('State');
		\$this->pagination		= \$this->get('Pagination');
		\$this->model			= \$this->getModel('${vPlural}');
		\$this->filterForm		= \$this->get('FilterForm');
		\$this->activeFilters	= \$this->get('ActiveFilters');

		"${component_ucf}"Helper::addSubmenu('${vPlural}');

		if (count(\$errors = \$this->get('Errors'))) {
			JError::raiseError(500,implode('<br>', \$errors));
			return false;
		}

		\$this->addToolbar();
		\$this->sidebar = HTMLHelperSidebar::render();

		return parent::display(\$tpl);
	}

	protected function addToolbar()
	{
		\$state	= \$this->get('State');
		\$canDo	= "${component_ucf}"Helper::getActions('com_${component_name}','component');
		\$user	= Factory::getUser();
		\$bar	= Toolbar::getInstance('toolbar');

		if (\$canDo->get('core.create'))
		{
			ToolbarHelper::addNew('${vSingular}.add');
		}

		if (\$canDo->get('core.edit'))
		{
			ToolbarHelper::editList('${vSingular}.edit');
		}

		if (\$canDo->get('core.edit.state'))
		{
			ToolbarHelper::publish('${vPlural}.publish','Toolbar_PUBLISH',true);
			ToolbarHelper::unpublish('${vPlural}.unpublish','Toolbar_UNPUBLISH',true);
			ToolbarHelper::archiveList('${vPlural}.archive');
			ToolbarHelper::checkin('${vPlural}.checkin');
		}

		if (\$state->get('filter.published') === -2 && \$canDo->get('core.delete'))
		{
			ToolbarHelper::deleteList('','${vPlural}.delete','Toolbar_EMPTY_TRASH');
		}
		elseif (\$canDo->get('core.edit.state'))
		{
			ToolbarHelper::trash('${vPlural}.trash');
		}

		if (\$canDo->get('core.admin'))
		{
			ToolbarHelper::preferences('com_${component_name}');
		}

		HTMLHelperSidebar::setAction('index.php?option=com_${component_name}&view=${vPlural}');
		ToolbarHelper::title(Text::_('CHANGE_TITLE'),'');
	}
}
	"
}

write_singular_edit_dot_php(){
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
use Joomla\CMS\HTML\HTMLHelper;
use Joomla\CMS\Router\Route;

\$doc = Factory::getDocument();
HTMLHelper::_('behavior.formvalidator');
HTMLHelper::_('behavior.keepalive');
HTMLHelper::_('formbehavior.chosen','select',null,array('disable_search_threshold' => 0));
?>

<form action=\"<?php echo Route::_('index.php?option=com_${component_name}&view=${vSingular}&layout=edit&id=' . (int) \$this->item->id); ?>\" name=\"adminForm\" id=\"adminForm\" method=\"post\" class=\"form-validate\">
	<?php if (!empty(\$this->sidebar)) { ?>
    <div id=\"j-sidebar-container\" class=\"span2\">
		<?php echo \$this->sidebar; ?>
    </div>
    <div id=\"j-main-container\" class=\"span10\" >
		<?php } else { ?>
            <div id=\"j-main-container\"></div>
		<?php } ?>
	<div class=\"form-horizontal\">
		<div class=\"row-fluid\">
			<div class=\"span12\">
				<?php echo \$this->form->renderFieldset('basic'); ?>
			</div>
		</div>
	</div>

	<input type=\"hidden\" name=\"task\" value=\"${vSingular}.edit\" />
	<?php echo HTMLHelper::_('form.token'); ?>
	</div>
</form>

	"
}

write_plural_default_dot_php(){
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
use Joomla\CMS\HTML\HTMLHelper;
use Joomla\CMS\Layout\LayoutHelper;
use Joomla\CMS\Language\Text;
use Joomla\CMS\Router\Route;

\$user 		= Factory::getUser();
\$listOrder = \$this->escape(\$this->state->get('list.ordering'));
\$listDirn 	= \$this->escape(\$this->state->get('list.direction'));
\$canOrder 	= \$user->authorise('core.edit.state','com_${component_name}');
\$saveOrder = (\$listOrder == 'a.ordering');

if(\$saveOrder)
{
	\$saveOrderingUrl = 'index.php?option=com_${component_name}&task=${vPlural}.saveOrderAjax&tmpl=component';
	\$html = HTMLHelper::_('sortablelist.sortable', '"${vSingular}"List','adminForm', strtolower(\$listDirn),\$saveOrderingUrl);
}

HTMLHelper::_('jquery.framework', false);
?>

<script type=\"text/javascript\">
    Joomla.orderTable = function() {
        table = document.getElementById('sortTable');
        direction = document.getElementById('directionTable');
        order = table.options[table.selectedIndex].value;
        if (order != '<?php echo \$listOrder; ?>') {
            dirn = 'asc';
        } else {
            dirn = direction.options[direction.selectedIndex].value;
        }
        Joomla.tableOrdering(order, dirn, '');
    }
</script>

<form action=\"<?php echo Route::_('index.php?option=com_${component_name}&view=${vPlural}'); ?>\" method=\"POST\" name=\"adminForm\" id=\"adminForm\">
	<?php if (!empty(\$this->sidebar)) { ?>
	<div id=\"j-sidebar-container\" class=\"span2\">
		<?php echo \$this->sidebar; ?>
	</div>

	<div id=\"j-main-container\" class=\"span10\" >
		<?php } else { ?>
			<div id=\"j-main-container\"></div>
		<?php } ?>

		<?php echo LayoutHelper::render('joomla.searchtools.default', array('view' => \$this)); ?>
		<div class=\"clearfix\"></div>
		<?php if (!empty(\$this->items)) { ?>
			<table class=\"table table-striped\" id=\""${vSingular}"List\">
				<thead>
					<tr>
						<th class=\"nowrap center hidden-phone\" width=\"1%\">
							<?php echo HTMLHelper::_('grid.sort', '<i class=\"icon-menu-2\"></i>', 'a.ordering', \$listDirn, \$listOrder, null, 'asc', 'JGRID_HEADING_ORDERING'); ?>
						</th>

						<th width=\"1%\" class=\"hidden-phone\">
							<input type=\"checkbox\" name=\"checkall-toggle\" value=\"\" title=\"<?php echo Text::_('JGLOBAL_CHECK_ALL'); ?>\" onclick=\"Joomla.checkAll(this)\" />
						</th>

						<th width=\"1%\" class=\"nowrap center\">
							<?php echo HTMLHelper::_('grid.sort', 'JSTATUS', 'a.published', \$listDirn, \$listOrder); ?>
						</th>

						<th>
							<?php echo HTMLHelper::_('grid.sort','JGLOBAL_TITLE','a.title',\$listDirn,\$listOrder); ?>
						</th>
						
						<th>
							<?php echo HTMLHelper::_('grid.sort','COM_${component_uca}_CREATED_BY','a.created_by',\$listDirn,\$listOrder); ?>
						</th>
						
						<th>
							<?php echo HTMLHelper::_('grid.sort','COM_${component_uca}_CREATED','a.created',\$listDirn,\$listOrder); ?>
						</th>
						
						<th>
							<?php echo HTMLHelper::_('grid.sort','COM_${component_uca}_ID','a.id',\$listDirn,\$listOrder); ?>
						</th>

					</tr>
				</thead>

				<tfoot>
					<tr>
						<td colspan=\"10\">
							<?php echo \$this->pagination->getListFooter(); ?>
						</td>
					</tr>
				</tfoot>

				<tbody>
					<?php foreach(\$this->items as \$i => \$item): ?>

						<?php
						\$canCheckin	= \$user->authorise('core.manage', 'com_checkin') || \$item->checked_out == \$user->get('id') || \$item->checked_out == 0;
						\$canChange		= \$user->authorise('core.edit.state', 'com_${component_name}') && \$canCheckin;
						\$canEdit		= \$user->authorise( 'core.edit', 'com_${component_name}' );
						?>

						<tr class=\"row<?php echo \$i % 2; ?>\" sortable-group-id=\"1\">
							<td class=\"order nowrap center hidden-phone\">
								<?php if(\$canChange) :
									\$disableClassName = '';
									\$disabledLabel = '';
									if(!\$saveOrder) :
										\$disabledLabel = Text::_('JORDERINGDISABLED');
										\$disableClassName = 'inactive tip-top';
									endif;
									?>

									<span class=\"sortable-handler hasTooltip <?php echo \$disableClassName; ?>\" title=\"<?php echo \$disabledLabel; ?>\">
										<i class=\"icon-menu\"></i>
									</span>
									<input type=\"text\" style=\"display: none;\" name=\"order[]\" size=\"5\" class=\"width-20 text-area-order \" value=\"<?php echo \$item->ordering; ?>\" >
								<?php else: ?>
									<span class=\"sortable-handler inactive\">
										<i class=\"icon-menu\"></i>
									</span>
								<?php endif; ?>
							</td>

							<td class=\"center hidden-phone\">
								<?php echo HTMLHelper::_('grid.id', \$i, \$item->id); ?>
							</td>

							<td class=\"center\">
								<div class=\"btn-group\">
									<?php echo HTMLHelper::_('jgrid.published', \$item->published, \$i, '${vPlural}.', true,'cb');?>
									<?php
										if (\$canChange) {
											HTMLHelper::_('actionsdropdown.' . ((int) \$item->published === 2 ? 'un' : '') . 'archive', 'cb' . \$i, '${vPlural}');
											HTMLHelper::_('actionsdropdown.' . ((int) \$item->published === -2 ? 'un' : '') . 'trash', 'cb' . \$i, '${vPlural}');
											echo HTMLHelper::_('actionsdropdown.render', \$this->escape(\$item->title));
										}
									?>
								</div>
							</td>

							<td>
								<?php if (\$item->checked_out) : ?>
									<?php echo HTMLHelper::_('jgrid.checkedout', \$i,\$item->editor, \$item->checked_out_time, '${vPlural}.', \$canCheckin); ?>
								<?php endif; ?>

								<?php if (\$canEdit) : ?>
									<a class=\"title\" href=\"<?php echo Route::_('index.php?option=com_${component_name}&task=${vSingular}.edit&id='. \$item->id); ?>\">
										<?php echo \$this->escape(\$item->title); ?>
									</a>
								<?php else : ?>
									<?php echo \$this->escape(\$item->title); ?>
								<?php endif; ?>

								<span class=\"small break-word\">
									<?php echo Text::sprintf('JGLOBAL_LIST_ALIAS', \$this->escape(\$item->alias)); ?>
								</span>
							</td>

							<td>
								<?php echo Factory::getUser(\$item->created_by)->get('username', \$item->created_by); ?>
							</td>

							<td>
								<?php echo HTMLHelper::_('date', \$item->created, 'd M, Y'); ?>
							</td>
							
							<td>
								<?php echo \$item->id; ?>
							</td>
						</tr>
					<?php endforeach; ?>
				</tbody>
			</table>
		<?php } else { ?>
			<div class=\"no-record-found\"><?php echo Text::_('COM_${component_uca}_NO_RECORD_FOUND'); ?></div>
		<?php } ?>

		<input type=\"hidden\" name=\"task\" value=\"\" />
		<input type=\"hidden\" name=\"boxchecked\" value=\"0\" />
		<input type=\"hidden\" name=\"filter_order\" value=\"<?php echo \$listOrder; ?>\" />
		<input type=\"hidden\" name=\"filter_order_Dir\" value=\"<?php echo \$lilstDirn; ?>\" />
		<?php echo HTMLHelper::_('form.token'); ?>
	</div>
</form>
	"
}

write_form_xml(){
	echo "<?xml version=\"1.0\" encoding=\"utf-8\" ?>
<form>
    <fieldset name=\"basic\">
        <field name=\"id\" type=\"hidden\" />
        <field name=\"title\" type=\"text\" label=\"JGLOBAL_TITLE\" description=\"JFIELD_TITLE_DESC\" class=\"inputbox\" required=\"true\" />
        <field name=\"alias\" type=\"text\" id=\"alias\" label=\"JFIELD_ALIAS_LABEL\" description=\"JFIELD_ALIAS_DESC\" hint=\"JFIELD_ALIAS_PLACEHOLDER\" size=\"40\" />
    </fieldset>
</form>
	"
}

write_form_filter_xml(){
	echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<form>
    <fields name=\"filter\">
        <field name=\"search\" type=\"text\" label=\"JSEARCH_FILTER\" description=\"\" hint=\"JSEARCH_FILTER\" />
		<field name=\"published\" type=\"status\" label=\"JOPTION_SELECT_PUBLISHED\" description=\"JOPTION_SELECT_PUBLISHED_DESC\" onchange=\"this.form.submit();\">
            <option value=\"\">JOPTION_SELECT_PUBLISHED</option>
        </field>
    </fields>
    <fields name=\"list\">
        <field name=\"fullordering\" type=\"list\" label=\"COM_CONTACT_LIST_FULL_ORDERING\" description=\"COM_CONTACT_LIST_FULL_ORDERING_DESC\" default=\"a.name ASC\" onchange=\"this.form.submit();\">
            <option value=\"\">JGLOBAL_SORT_BY</option>
            <option value=\"a.ordering ASC\">JGRID_HEADING_ORDERING_ASC</option>
            <option value=\"a.ordering DESC\">JGRID_HEADING_ORDERING_DESC</option>
            <option value=\"a.published ASC\">JSTATUS_ASC</option>
            <option value=\"a.published DESC\">JSTATUS_DESC</option>
            <option value=\"a.title ASC\">JGLOBAL_TITLE_ASC</option>
            <option value=\"a.title DESC\">JGLOBAL_TITLE_DESC</option>
        </field>
        <field name=\"limit\" type=\"limitbox\" label=\"COM_CONTACT_LIST_LIMIT\" description=\"COM_CONTACT_LIST_LIMIT_DESC\" default=\"25\" class=\"input-mini\" onchange=\"this.form.submit();\" />
    </fields>
</form>
	"
}

file_created(){
	tput setaf 7; echo "Created file: "$1; tput sgr0;
}

directory_created(){
	tput setaf 5; echo "Created directory: "$1; tput sgr0;
}

console_log() {
	tput setaf 4; echo $1; tput sgr0;
}
#end of functions
DIR="${DIR}/administrator/components";
#main
if [ -d "${DIR}/com_${component_name}" ]
	then
		console_log "Component found! Overwriting existing one..."
	else 
		mkdir "${DIR}/com_${component_name}"	
		(directory_created "${DIR}/com_${component_name}")
fi

#mkdir "${DIR}/com_${component_name}"
#(directory_created "${DIR}/com_${component_name}")
DIR="${DIR}/com_${component_name}"

folders=(controllers models tables views)

for folder in "${folders[@]}"; do
	directory=${DIR}"/${folder}"
	if [ -d ${directory} ]
	then
		#tempPath=${DIR}/${folder}
		#rm -r "${DIR}/${folder}"
		(console_log ${folder}" already exists. Overwrting the existings...")
	else
		mkdir ${directory}
		(directory_created "${directory}")
	fi

	if [ "${folder}" == "controllers" ]
	then
		(umask 077 ; touch "${directory}/${vSingular}.php")
		(umask 077 ; touch "${directory}/${vPlural}.php")

		(write_singular_controller > "${directory}/${vSingular}.php")
		(write_plural_controller > "${directory}/${vPlural}.php")

		(file_created "${directory}/${vSingular}.php")
		(file_created "${directory}/${vPlural}.php")

	elif [ "${folder}" == "models" ]
	then
		mkdir "${directory}/forms"
		mkdir "${directory}/fields"

		(directory_created "${directory}/forms")
		(directory_created "${directory}/fields")

		(umask 077 ; touch "${directory}/${vSingular}.php")
		(umask 077 ; touch "${directory}/${vPlural}.php")

		(umask 077 ; touch "${directory}/forms/${vSingular}.xml")
		(umask 077 ; touch "${directory}/forms/filter_${vPlural}.xml")
		(write_singular_model > "${directory}/${vSingular}.php")
		(write_plural_model > "${directory}/${vPlural}.php")

		(write_form_xml > "${directory}/forms/${vSingular}.xml")
		(write_form_filter_xml > "${directory}/forms/filter_${vPlural}.xml")

		#creating file messages
		(file_created "${directory}/${vSingular}.php")
		(file_created "${directory}/${vPlural}.php")
		(file_created "${directory}/forms/${vSingular}.xml")
		(file_created "${directory}/forms/filter_${vPlural}.xml")
	elif [ "${folder}" == "tables" ]
	then
		(umask 077 ; touch "${directory}/${vSingular}.php")
		(write_table > "${directory}/${vSingular}.php")

		(file_created "${directory}/${vSingular}.php")
	elif [ "${folder}" == "views" ]
	then
		mkdir "${directory}/${vSingular}"
		mkdir "${directory}/${vPlural}"
		mkdir "${directory}/${vSingular}/tmpl"
		mkdir "${directory}/${vPlural}/tmpl"

		(directory_created "${directory}/${vSingular}")
		(directory_created "${directory}/${vPlural}")
		(directory_created "${directory}/${vSingular}/tmpl")
		(directory_created "${directory}/${vPlural}/tmpl")

		(umask 077 ; touch "${directory}/${vSingular}/tmpl/edit.php")
		(umask 077 ; touch "${directory}/${vSingular}/view.html.php")
		(umask 077 ; touch "${directory}/${vPlural}/tmpl/default.php")
		(umask 077 ; touch "${directory}/${vPlural}/view.html.php")

		(write_singular_view_dot_html > "${directory}/${vSingular}/view.html.php")
		(write_plural_view_dot_html > "${directory}/${vPlural}/view.html.php")
		(write_singular_edit_dot_php > "${directory}/${vSingular}/tmpl/edit.php")
		(write_plural_default_dot_php > "${directory}/${vPlural}/tmpl/default.php")

		(file_created "${directory}/${vSingular}/tmpl/edit.php")
		(file_created "${directory}/${vSingular}/view.html.php")
		(file_created "${directory}/${vPlural}/tmpl/default.php")
		(file_created "${directory}/${vPlural}/view.html.php")
	fi
done
