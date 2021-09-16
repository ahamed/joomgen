#!/bin/bash
date=`date +%Y-%m-%d`

#functions
create_manifest_xml() {
    mName="$1"; cDate="$date"; author="$2"; aEmail="$3"; aUrl="$4"; copy="$5"; license="$6"; version="$7"; desc="$8";
    name_uca="$(tr a-z A-Z <<<${mName})"
    

    echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<extension version=\"3.3\" type=\"component\" method=\"upgrade\">
  <name>${mName}</name>
  <creationDate>${cDate}</creationDate>
  <author>${author}</author>
  <authorEmail>${aEmail}</authorEmail>
  <authorUrl>${aUrl}</authorUrl>
  <copyright>${copy}</copyright>
  <license>${license}</license>
  <version>${version}</version>
  <description>${desc}</description>

  <scriptfile>installer.script.php</scriptfile>
  
  <updateservers>
    <server type=\"extension\" priority=\"1\" name=\"${name}\"></server>
  </updateservers>

  <install>
    <sql>
      <file driver=\"mysql\" charset=\"utf8\">sql/install/mysql/install.sql</file>
      <file driver=\"mysql\">sql/install/mysql/install.sql</file>

      <file driver=\"mysqli\" charset=\"utf8\">sql/install/mysql/install.sql</file>
      <file driver=\"mysqli\">sql/install/mysql/install.sql</file>
    </sql>
  </install>

  <update>
		<schemas>
			<schemapath type=\"mysql\">sql/updates/mysql</schemapath>
			<schemapath type=\"mysqli\">sql/updates/mysql</schemapath>
		</schemas>
	</update>

  <uninstall>
    <sql>
      <file driver=\"mysql\" charset=\"utf8\">sql/uninstall/mysql/uninstall.sql</file>
    </sql>
  </uninstall>

  <files folder=\"site\">
    <filename>${mName}.php</filename>
    <filename>controller.php</filename>
    <filename>router.php</filename>
    
    <folder>assets</folder>
    <folder>controllers</folder>
    <folder>fields</folder>
    <folder>helpers</folder>
    <folder>layouts</folder>
    <folder>models</folder>
    <folder>views</folder>
  </files>

  <languages folder=\"language/site\">
    <language tag=\"en-GB\">en-GB/en-GB.com_${mName}.ini</language>
  </languages>

  <administration>
    <menu>COM_${name_uca}</menu>

    <files folder=\"admin\">
      <filename>access.xml</filename>
      <filename>config.xml</filename>
      <filename>${mName}.php</filename>
      <filename>controller.php</filename>

      <folder>assets</folder>
      <folder>sql</folder>
      <folder>tables</folder>
      <folder>views</folder>
      <folder>controllers</folder>
      <folder>models</folder>
      <folder>helpers</folder>
    </files>

    <languages folder=\"language/admin\">
      <language tag=\"en-GB\">en-GB/en-GB.com_${mName}.ini</language>
      <language tag=\"en-GB\">en-GB/en-GB.com_${mName}.sys.ini</language>
    </languages>
  </administration>
</extension>
    "
}
directory=$1
cName=$2
(umask 077 ; touch "${directory}/${cName}.xml")
(create_manifest_xml "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" > "${directory}/${cName}.xml")