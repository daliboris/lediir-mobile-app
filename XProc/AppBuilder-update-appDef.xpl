<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:dlbab="https://www.daliboris.cz/ns/xproc/app-builder"
	name="mobile-app-updating"
	version="3.0">
   
   <p:import href="AppBuilder-Library.xpl" />
	
	<p:option name="platform" select="'android'" values="('android', 'ios')" static="true" />
	<p:option name="dictionary-acronym" select="'FACS'" static="true" />
	<p:option name="data-version" select="'2024-06-20'" static="true" />
   
  <p:input port="source" primary="true">
  	<p:document href="../dictionaries/{$dictionary-acronym}/{$dictionary-acronym}.appDef" content-type="application/xml" />
  </p:input>
   
	<p:output port="result" serialization="map{'indent' : true()}" />

	<p:group message="Updating application version in common repository" use-when="false()">
		<p:documentation>Zvýší číslo verze o 1 v hlavním definicčním souboru. Aplikuje se po otestování funčních verzí. Slouží k zachování verze v rámci repozitáře zdrojového kódu.</p:documentation>
	 
		<p:variable name="path" select="base-uri(/)" />
	
		<dlbab:update-version platform="android" p:message="updating app version for Android" />
		<dlbab:update-version platform="ios" method="copy" p:message="updating app version for iOS" />

		<p:store href="{$path}" message="Storing to {$path}" />
		
	</p:group>

	<p:group message="Updating application version for {$platform}, fo build" use-when="true()">

		<dlbab:replace-secrets platform="{$platform}">
			<p:with-input port="secrets" href="local.secrets.xml" />
		</dlbab:replace-secrets>
		
		<dlbab:update-version platform="{$platform}" p:message="updating app version" />
		
		<p:store href="../build/{$platform}/dictionaries/{$dictionary-acronym}/{$dictionary-acronym}.appDef" />
		
		<dlbab:copy-dictionary-data platform="{$platform}" dictionary-acronym="{$dictionary-acronym}" name="copying-data" p:message="copying dictionary data" />
		
		<dlbab:update-data-version data-version="{$data-version}" p:depends="copying-data" platform="{$platform}" dictionary-acronym="{$dictionary-acronym}" p:message="updating data version" />

	</p:group>

</p:declare-step>
