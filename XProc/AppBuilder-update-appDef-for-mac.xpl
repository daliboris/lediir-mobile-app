<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:dlbab="https://www.daliboris.cz/ns/xproc/app-builder"
	version="3.0">
   
	<p:import href="AppBuilder-Library.xpl" />
	
	<p:option name="platform" select="'ios'" />
	<p:option name="dictionary-acronym" select="'FACS'" />
	
  <p:input port="source" primary="true">
  	<p:document href="../dictionaries/FACS/FACS.appDef" content-type="application/xml" />
  </p:input>
   
	<p:output port="result" serialization="map{'indent' : true()}" />

	<dlbab:replace-secrets platform="{$platform}">
		<p:with-input port="secrets" href="local.secrets.xml" />
	</dlbab:replace-secrets>
	
	<dlbab:update-version platform="{$platform}" />

	<p:xslt>
		<p:with-input port="stylesheet" href="../Xslt/appbuilder-for-mac.xsl" />
	</p:xslt>
	
	<p:store href="../build/{$platform}/dictionaries/{$dictionary-acronym}/{$dictionary-acronym}.appDef" serialization="map{'indent' : true()}" message="Storing text to ../build/{$platform}/dictionaries/{$dictionary-acronym}/{$dictionary-acronym}.appDef" />
	
	<dlbab:copy-dictionary-data platform="{$platform}" dictionary-acronym="FACS" />

</p:declare-step>
