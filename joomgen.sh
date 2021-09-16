#!/bin/bash

DIR=`pwd`
year=`date +%Y`
date=`date`
root_dir="$(cd "$(dirname "$0")" && pwd -P)"

echo "
   __                                 _
   \\ \\   ___    ___   _ __ ___   ___ | |__    __ _  _ __    ___  _ __
    \\ \\ / _ \\  / _ \\ | '_ \` _ \\ / __|| '_ \\  / _\` || '_ \\  / _ \\| '__|
 /\\_/ /| (_) || (_) || | | | | |\\__ \\| | | || (_| || |_) ||  __/| |
 \\___/  \\___/  \\___/ |_| |_| |_||___/|_| |_| \\__,_|| .__/  \\___||_|
                                                   |_|
"

file_created(){
	tput setaf 7; echo "Created file: "$1; tput sgr0;
}

directory_created(){
	tput setaf 5; echo "Created directory: "$1; tput sgr0;
}

#handle parameters
option=$1
if [ -z $option ]; then option="-v"; fi;
option="$(tr A-Z a-z <<<${option})"
view_type=$2
if [ -z $view_type ]; then view_type="-b"; fi;
view_type="$(tr A-Z a-z <<<${view_type})"


#Generate component
if [ $option == "-c" ]
then
    echo "Creating component..."
    echo "Component name: (without com_)"
    read cName

    echo "Author: (JoomShaper) "
    read cAuthor

    echo "Author Email: (support@joomshaper.com) "
    read cEmail

    echo "Author Url: (https://www.joomshaper.com) "
    read cUrl

    echo "Copyright: (Copyright (c) 2010 - ${year} JoomShaper. All rights reserved.) "
    read cCopyright

    echo "Version:(1.0) "
    read cVersion

    echo "License:(GNU) "
    read cLicense
    
    echo "Description: "
    read cDesc

    #check if component name is provided or not
    if [ -z "$cName" ]; then echo "You must need to provide the component name."; exit; fi;
    
    if [ -z "$cAuthor" ]; then cAuthor="JoomShaper"; fi;
    if [ -z "$cEmail" ]; then cEmail="support@joomshaper.com"; fi;
    if [ -z "$cUrl" ]; then cUrl="https://www.joomshaper.com"; fi;
    if [ -z "$cCopyright" ]; then cCopyright="Copyright (c) 2010 - ${year} JoomShaper. All rights reserved."; fi;
    if [ -z "$cVersion" ]; then cVersion="1.0"; fi;
    if [ -z "$cLicense" ]; then cLicense="GNU General Public License version 2 or later"; fi;
    
    ################create administrator###############
    ###################################################
    
    #create administrator directory
    adminComponentDir="${DIR}/administrator/components/com_${cName}"
    
    #create admininistrator folders
    adminFolders=(assets sql tables views controllers models helpers)
    for folder in "${adminFolders[@]}"; do
        adminFolderDir="${adminComponentDir}/${folder}"
        if [ "${folder}" == "assets" ]; then
            mkdir -p "${adminFolderDir}/js"
            (directory_created "${adminFolderDir}/js")
            mkdir -p "${adminFolderDir}/css"
            (directory_created "${adminFolderDir}/css")
            bash ${root_dir}/shell_components/style_css_b.sh "${adminFolderDir}/css"
            (file_created "${adminFolderDir}/css/style.css")
        elif [ "${folder}" == "sql" ]; then
            mkdir -p "${adminFolderDir}/install/mysql"
            (umask 077 ; touch "${adminFolderDir}/install/mysql/install.sql")
            (file_created "${adminFolderDir}/install/mysql/install.sql")
            mkdir -p "${adminFolderDir}/uninstall/mysql"
            (umask 077 ; touch "${adminFolderDir}/uninstall/mysql/uninstall.sql")
            (file_created "${adminFolderDir}/uninstall/mysql/uninstall.sql")
            mkdir -p "${adminFolderDir}/updates/mysql"
            (umask 077 ; touch "${adminFolderDir}/updates/mysql/${cVersion}.${cName}.sql")
            (file_created "${adminFolderDir}/updates/mysql/${cVersion}.${cName}.sql")
        elif [ "${folder}" == "tables" ]; then
            mkdir -p "${adminFolderDir}"
            (directory_created "${adminFolderDir}")
        elif [ "${folder}" == "views" ]; then
            mkdir -p "${adminFolderDir}"
            (directory_created "${adminFolderDir}")
        elif [ "${folder}" == "controllers" ]; then
            mkdir -p "${adminFolderDir}"
            (directory_created "${adminFolderDir}")
        elif [ "${folder}" == "models" ]; then
            mkdir -p "${adminFolderDir}"
            (directory_created "${adminFolderDir}")
        elif [ "${folder}" == "helpers" ]; then
            mkdir -p "${adminFolderDir}"
            (directory_created "${adminFolderDir}")
            bash ${root_dir}/shell_components/helper_b_php.sh "${adminFolderDir}" "${cName}"
            (file_created "${adminFolderDir}/${cName}.php")
        fi
    done


    #creating manifest.xml file
    bash ${root_dir}/shell_components/manifest_xml.sh "$adminComponentDir" "$cName" "$cAuthor" "$cEmail" "$cUrl" "$cCopyright" "$cLicense" "$cVersion" "$cDesc"
    (file_created "${adminComponentDir}/${cName}.xml")

    #creating access.xml file
    bash ${root_dir}/shell_components/access_xml.sh "$adminComponentDir" "$cName"
    (file_created "${adminComponentDir}/access.xml")

    #creating config.xml file
    bash ${root_dir}/shell_components/config_xml.sh "$adminComponentDir" "$cName"
    (file_created "${adminComponentDir}/config.xml")

    #create component.php file
    bash ${root_dir}/shell_components/component_php.sh "$adminComponentDir" "$cName"
    (file_created "${adminComponentDir}/${cname}.php")

    #create controller.php file
    bash ${root_dir}/shell_components/controller_b_php.sh "$adminComponentDir" "$cName"
    (file_created "${adminComponentDir}/controller.php")

    #create installer.script.php file 
    bash ${root_dir}/shell_components/installer_script_php.sh "$adminComponentDir" "$cName"
    (file_created "${adminComponentDir}/installer.script.php")

    #admin language files
    #admin language directory
    adminLangDir="${DIR}/administrator/language/en-GB"
    mkdir -p "${adminLangDir}"
    bash ${root_dir}/shell_components/lang_sys_ini.sh "${adminLangDir}" "${cName}"
    (file_created "en-GB.com_${cName}.sys.ini")
    bash ${root_dir}/shell_components/lang_ini_b.sh "${adminLangDir}" "${cName}"
    (file_created "en-GB.com_${cName}.ini")
    

    ################create site########################
    ###################################################

    #site directory
    siteComponentDir="${DIR}/components/com_${cName}"
    #site folders
    siteFolders=(assets controllers fields helpers layouts models views)

    for sFolder in "${siteFolders[@]}"; do
        siteFolderDir="${siteComponentDir}/${sFolder}"
        if [ "${sFolder}" == "assets" ]; then
            mkdir -p "${siteFolderDir}/js"
            (directory_created "${siteFolderDir}/js")
            mkdir -p "${siteFolderDir}/css"
            (directory_created "${siteFolderDir}/css")
            mkdir -p "${siteFolderDir}/images"
            (umask 077 ; touch "${siteFolderDir}/css/style.css")
            (create_file "${siteFolderDir}/css/style.css")
        elif [ "${sFolder}" == "controllers" ]; then
            mkdir -p "${siteFolderDir}"
            (directory_created "${siteFolderDir}")
        elif [ "${sFolder}" == "fields" ]; then
            mkdir -p "${siteFolderDir}"
            (directory_created "${siteFolderDir}")
        elif [ "${sFolder}" == "helpers" ]; then
            mkdir -p "${siteFolderDir}"
            (directory_created "${siteFolderDir}")
            bash ${root_dir}/shell_components/helper_f_php.sh "${siteFolderDir}" "${cName}"
            (file_created "${siteFolderDir}/helper.php")
            bash ${root_dir}/shell_components/legacyrouter_php.sh "${siteFolderDir}" "${cName}"
            (file_created "${siteFolderDir}/legacyrouter.php")
        elif [ "${sFolder}" == "layouts" ]; then
            mkdir -p "${siteFolderDir}"
            (directory_created "${siteFolderDir}")
        elif [ "${sFolder}" == "modles" ]; then
            mkdir -p "${siteFolderDir}"
            (directory_created "${siteFolderDir}")
        elif [ "${sFolder}" == "views" ]; then
            mkdir -p "${siteFolderDir}"
            (directory_created "${siteFolderDir}")
        fi
    done

    #create site basic files
    #create componentName.php 
    bash ${root_dir}/shell_components/component_name_php.sh "${siteComponentDir}" "${cName}"
    (file_created "${siteComponentDir}/${cName}.php")
    
    #create controller.php 
    bash ${root_dir}/shell_components/controller_f_php.sh "${siteComponentDir}" "${cName}"
    (file_created "${siteComponentDir}/controller.php")

    #create router.php 
    bash ${root_dir}/shell_components/router_php.sh "${siteComponentDir}" "${cName}"
    (file_created "${siteComponentDir}/router.php")

    #site language files
    #site language directory
    siteLangDir="${DIR}/language/en-GB"
    mkdir -p "${siteLangDir}"
    (directory_created "${siteLangDir}")
    bash ${root_dir}/shell_components/lang_ini_f.sh "${siteLangDir}" "${cName}"
    (file_created "en-GB.com_${cName}.ini")

elif [ "${option}" == "-v" ]; then
    echo "Creating view..."
    echo "Component name: (without com_)"
    read cName

    if [ -d "${DIR}/administrator/components/com_${cName}" ]; then
        echo "Component found! Running view creation..";
    else 
        echo "No component found! First run \`joomgen -c\` for creating component";
        exit;
    fi

    #check if component name is provided or not
    if [ -z "$cName" ]; then echo "You must need to provide the component name."; exit; fi;

    if [ "${view_type}" == "-b" ]; then
        bash ${root_dir}/shell_components/view_b.sh "${cName}"
    elif [ "${view_type}" == "-f" ]; then
        bash ${root_dir}/shell_components/frontend/view_f.sh "${cName}"
    fi

fi
