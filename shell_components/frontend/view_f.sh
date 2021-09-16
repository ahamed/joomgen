#!/bin/bash

#constants
DIR=`pwd`
bash_dir="$(cd "$(dirname "$0")" && pwd -P)"

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


file_created(){
	tput setaf 7; echo "Created file: "$1; tput sgr0;
}

directory_created(){
	tput setaf 5; echo "Created directory: "$1; tput sgr0;
}

console_log() {
	tput setaf 4; echo $1; tput sgr0;
}

#creating controller files
controllerDir="${DIR}/components/com_${component_name}/controllers"
mkdir -p "${controllerDir}"
(directory_created "${controllerDir}")
bash ${bash_dir}/controller_f.sh "${controllerDir}" "${component_name}" "${vSingular}" "${vPlural}"

#creating model files
modelDir="${DIR}/components/com_${component_name}/models"
mkdir -p "${modelDir}"
(directory_created "${modelDir}")
bash ${bash_dir}/model_f.sh "${modelDir}" "${component_name}" "${vSingular}" "${vPlural}"

#creating view files
viewDir="${DIR}/components/com_${component_name}/views"
bash ${bash_dir}/view_html.sh "${viewDir}" "${component_name}" "${vSingular}" "${vPlural}"
bash ${bash_dir}/view_default.sh "${viewDir}" "${component_name}" "${vSingular}" "${vPlural}"