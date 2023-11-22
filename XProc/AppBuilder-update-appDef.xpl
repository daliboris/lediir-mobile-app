<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:dlbab="https://www.daliboris.cz/ns/xproc/app-builder"
	version="3.0">
   
  <p:input port="source" primary="true">
  	<p:document href="../Persian-Czech%20Dictionary/Persian-Czech%20Dictionary.appDef" content-type="xml" />
  </p:input>
   
	<p:output port="result" serialization="map{'indent' : true()}" />
	
	<p:declare-step type="dlbab:rename-files" name="renaming-files">
		<p:input port="source" sequence="true"/>
		<p:output port="result" sequence="true"/>
		<p:option name="input-directory" required="true"/>
		
		<p:directory-list path="{$input-directory}" />
		
		<p:for-each name="loop">
			<p:with-input select="//c:file"/>
			<p:variable name="filename" select="/*/@name"/>
			<!--<p:load href="{p:urify(concat($input-directory, '/', $filename))}"/>-->
			<p:load href="{concat($input-directory, '/', $filename)}"/>
			<p:variable name="content-type" select="p:document-property(., 'content-type')"/>
			<p:sink message="{$content-type}" />
		</p:for-each>
		
		<!--<p:count />-->
	</p:declare-step>
	
	<p:declare-step type="dlbab:rename-all-files" name="renaming-all-files">
		<p:input port="source" sequence="true"/>
		<p:output port="result" sequence="true"/>
		<dlbab:rename-files input-directory="../../lift-to-tei/Dictionary/resources/images/entries" />
		<dlbab:rename-files input-directory="../../lift-to-tei/Dictionary/resources/audio" />
	</p:declare-step>

	<dlbab:rename-all-files>
		<p:with-input port="source">
			<p:empty />
		</p:with-input>
	</dlbab:rename-all-files>

<!--	<p:variable name="source" select="p:urify(/app-definition/source)" />
	
	<p:load href="{$source}" />

	<p:xquery name="illustations">
		<p:with-input port="query" href="../XProc/get-media.xquery" />
	</p:xquery>
	
	
	<p:store href="../Temp/?.xml" serialization="map{'indent' : true()}" message="Storing text to ../Temp/?.xml" />
-->	

</p:declare-step>
