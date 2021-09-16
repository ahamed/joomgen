#!/bin/bash
date=`date`

#functions
create_access_xml() {
    cName="$1"
    echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>
    <access component=\"com_${cName}\">
        <section name=\"component\">
            <action name=\"core.admin\" title=\"JACTION_ADMIN\" description=\"JACTION_ADMIN_COMPONENT_DESC\" />
            <action name=\"core.manage\" title=\"JACTION_MANAGE\" description=\"JACTION_MANAGE_COMPONENT_DESC\" />
            <action name=\"core.create\" title=\"JACTION_CREATE\" description=\"JACTION_CREATE_COMPONENT_DESC\" />
            <action name=\"core.delete\" title=\"JACTION_DELETE\" description=\"JACTION_DELETE_COMPONENT_DESC\" />
            <action name=\"core.edit\" title=\"JACTION_EDIT\" description=\"JACTION_EDIT_COMPONENT_DESC\" />
            <action name=\"core.edit.own\" title=\"JACTION_EDITOWN\" description=\"JACTION_EDITOWN_COMPONENT_DESC\" />
            <action name=\"core.edit.state\" title=\"JACTION_EDITSTATE\" description=\"JACTION_EDITSTATE_COMPONENT_DESC\" />
        </section>

        <section name=\"unit\">
            <!-- Actions to be used in for unit -->
            <action name=\"core.delete\" title=\"JACTION_DELETE\" description=\"JACTION_DELETE_COMPONENT_DESC\" />
            <action name=\"core.edit\" title=\"JACTION_EDIT\" description=\"JACTION_EDIT_COMPONENT_DESC\" />
            <action name=\"core.edit.own\" title=\"JACTION_EDITOWN\" description=\"JACTION_EDITOWN_COMPONENT_DESC\" />
            <action name=\"core.edit.state\" title=\"JACTION_EDITSTATE\" description=\"JACTION_EDITSTATE_COMPONENT_DESC\" />
        </section>
    </access>
    "
}
directory=$1
cName=$2
(umask 077 ; touch "${directory}/access.xml")
(create_access_xml "$2" > "${directory}/access.xml")