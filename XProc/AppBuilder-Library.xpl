<p:library  xmlns:p="http://www.w3.org/ns/xproc" 
 xmlns:xs="http://www.w3.org/2001/XMLSchema" 
 xmlns:dlbab="https://www.daliboris.cz/ns/xproc/app-builder"
 version="3.0">
 
 <p:documentation>
  <section></section>
 </p:documentation>
 
 <p:declare-step type="dlbab:replace-secrets" name="replacing-secrets">
  <p:option name="platform" as="xs:string" values="('android', 'ios')" required="true" />
  <p:input port="source" primary="true" />
  <p:input port="secrets" primary="false" />
  <p:output port="result" primary="true" />
  
  <p:if test="$platform = 'android'">
   <p:output primary="true" />
   <p:replace match="signing">
    <p:with-input port="replacement" select="//signing" pipe="secrets@replacing-secrets" />
   </p:replace>		
  </p:if>
  
  <p:if test="$platform = 'ios'">
   <p:output primary="true" />
   <p:replace match="signing-identity">
    <p:with-input port="replacement" select="//signing-identity" pipe="secrets@replacing-secrets" />
   </p:replace>		
   <p:replace match="provisioning-profile">
    <p:with-input port="replacement" select="//provisioning-profile" pipe="secrets@replacing-secrets" />
   </p:replace>		
  </p:if>
  
 </p:declare-step>
 
 <p:declare-step type="dlbab:update-version">
  <p:option name="platform" as="xs:string" values="('android', 'ios')" required="true" />
  <p:option name="method" as="xs:string" values="('compute', 'copy')" select="'compute'" />

  <p:input port="source" primary="true" />
  <p:output port="result" primary="true" />
  
  <p:if test="$platform = 'android'">
   <p:output primary="true" />
   <p:variable name="version" select="//version" />
   <p:variable name="new-version" select="$version/@code + 1" />

   <p:add-attribute match="version" attribute-name="name" attribute-value="{$new-version}.0" />
   <p:add-attribute match="version" attribute-name="code" attribute-value="{$new-version}" />
   
  </p:if>
  
  <p:if test="$platform = 'ios'">
   <p:output primary="true" />
   <p:variable name="version" select="//version" />
   <p:variable name="new-version" select="if($method = 'compute') then $version/@code + 1 else $version/@code" />
   
   <p:add-attribute match="ipa-version" attribute-name="name" attribute-value="{$new-version}.0" />
   <p:add-attribute match="ipa-version" attribute-name="build" attribute-value="{$new-version}" />

  </p:if>
  
 </p:declare-step>
 
 <p:declare-step type="dlbab:copy-dictionary-data">
  <p:option name="platform" as="xs:string" values="('android', 'ios')" required="true" />
  <p:option name="dictionary-acronym" as="xs:string" required="true" />
  <p:output port="result" primary="true" />
  
  <p:file-copy href="../dictionaries/{$dictionary-acronym}/{$dictionary-acronym}_data/about" target="../build/{$platform}/dictionaries/{$dictionary-acronym}/{$dictionary-acronym}_data/" />
  <p:file-copy href="../dictionaries/{$dictionary-acronym}/{$dictionary-acronym}_data/fonts" target="../build/{$platform}/dictionaries/{$dictionary-acronym}/{$dictionary-acronym}_data/" />
  <p:file-copy href="../dictionaries/{$dictionary-acronym}/{$dictionary-acronym}_data/images" target="../build/{$platform}/dictionaries/{$dictionary-acronym}/{$dictionary-acronym}_data/" />
  <p:file-copy href="../dictionaries/{$dictionary-acronym}/{$dictionary-acronym}_data/lexicon" target="../build/{$platform}/dictionaries/{$dictionary-acronym}/{$dictionary-acronym}_data/" />
  
  <p:if test="$platform = 'ios'">
   <p:output primary="true" />
   <p:file-copy href="../../lediir/lift-to-tei/Dictionary/resources/audio" target="../build/{$platform}/dictionaries/{$dictionary-acronym}/resources/" />
   <p:file-copy href="../../lediir/lift-to-tei/Dictionary/resources/images/entries" target="../build/{$platform}/dictionaries/{$dictionary-acronym}/resources/images/" />
   <p:file-copy href="../../lediir/lift-to-tei/Dictionary/LeDIIR-{$dictionary-acronym}-mobile.lift" target="../build/{$platform}/dictionaries/LeDIIR-{$dictionary-acronym}-mobile.lift" />
  </p:if>
  
 </p:declare-step>
 
 <p:declare-step type="dlbab:update-data-version">
  <!--<p:input port="source" primary="true"/>-->
  <p:output port="result" primary="true" pipe="result-uri"/>
  <p:option name="data-version" as="xs:string" required="true" />
  <p:option name="platform" as="xs:string" values="('android', 'ios')" required="true" />
  <p:option name="dictionary-acronym" as="xs:string" required="true" />

  <p:variable name="path" select="concat('../build/', $platform, '/dictionaries/', $dictionary-acronym, '/', $dictionary-acronym, '_data/about/about.txt')" />
  
  <p:load href="{$path}" />
  
  <p:text-replace pattern="%data-version%"  replacement="{$data-version}" />
  
  <p:store href="{$path}" />
  
 </p:declare-step>
 
</p:library>