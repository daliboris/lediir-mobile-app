<p:library  xmlns:p="http://www.w3.org/ns/xproc" 
 xmlns:xs="http://www.w3.org/2001/XMLSchema" 
 xmlns:dlbab="https://www.daliboris.cz/ns/xproc/app-builder"
 version="3.0">
 
 <p:documentation>
  <section></section>
 </p:documentation>
 
 <p:declare-step type="dlbab:remove-secrets" name="removing-secrets">
  <p:option name="platform" as="xs:string" values="('android', 'ios')" required="true" />
  <p:option name="dictionary-acronym" as="xs:string" required="true" />
  <p:option name="root-folder" as="xs:string" required="true" />
  
  <p:load href="{$root-folder}/{$platform}/dictionaries/{$dictionary-acronym}/{$dictionary-acronym}.appDef" content-type="application/xml" />
  
  <p:replace match="signing">
   <p:with-input port="replacement">
    <signing>
     <keystore/>
     <keystore-password/>
     <alias/>
     <alias-password/>
    </signing>
   </p:with-input>
  </p:replace>
  
  <p:replace match="resigning">
   <p:with-input port="replacement">
    <resigning>
     <signing-identity hash=""/>
     <provisioning-profile/>
    </resigning>
   </p:with-input>
  </p:replace>
  
  <p:store href="{base-uri()}" />
  
 </p:declare-step>
 
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
  <p:option name="platform" as="xs:string*" values="('android', 'ios', 'all')" required="true" />
  <p:option name="method" as="xs:string" values="('compute', 'copy')" select="'compute'" />
  <p:option name="current-version" as="element(version)?" required="false" />

  <p:input port="source" primary="true" />
  <p:output port="result" primary="true" />
  
  <p:variable name="version" select="if($current-version) then $current-version else //version" />
  <p:variable name="new-version" select="if($method = 'compute') then $version/@code + 1 else $version/@code" />
  
  <p:identity message="... ... current: {$current-version/@code}; version: {$version/@code}; new: {$new-version}"></p:identity>
  
  <p:if test="$platform = ('android', 'all')">
   <p:output primary="true" />

   <p:add-attribute match="version" attribute-name="name" attribute-value="{$new-version}.0" message="... ... ... setting version/@name to {$new-version}.0" />
   <p:add-attribute match="version" attribute-name="code" attribute-value="{$new-version}" />
   
  </p:if>
  
  <p:if test="$platform = ('ios', 'all')">
   <p:output primary="true" />
  <!-- <p:variable name="version" select="//version" />
   <p:variable name="new-version" select="if($method = 'compute') then $version/@code + 1 else $version/@code" />-->
   
   <p:add-attribute match="ipa-version" attribute-name="name" attribute-value="{$new-version}.0" />
   <p:add-attribute match="ipa-version" attribute-name="build" attribute-value="{$new-version}" />

  </p:if>
  
 </p:declare-step>
 
 <p:declare-step type="dlbab:copy-dictionary-data">
  <p:option name="platform" as="xs:string" values="('android', 'ios')" required="true" />
  <p:option name="project-acronym" as="xs:string" required="true" />
  <p:option name="dictionary-acronym" as="xs:string" required="true" />
  <p:option name="target-folder" as="xs:string?" />
  <!--<p:option name="test-version" as="xs:string?" />-->
  <p:option name="target-level" as="xs:string" values="('Basic', 'Medium', 'Large')" required="true" />
  <p:output port="result" primary="true" />
  
  <!-- ../build/android/dictionaries -->
  <p:variable name="target-path" select="if(empty($target-folder)) 
   then
   concat('../build/', $platform, '/dictionaries') 
   else $target-folder" />
  
  <!-- ../build/android/dictionaries/FACS -->
  <p:variable name="target-root" select="concat($target-path, '/', $dictionary-acronym)" />
  
  <!-- ../build/android/dictionaries/FACS/FACS_data -->
  <p:variable name="target-data" select="concat($target-root, '/', $dictionary-acronym, '-', $target-level, '_data')" />
  
  <!-- ../build/android/dictionaries/FACS/resources -->
  <p:variable name="target-resources" select="concat($target-root, '/resources')" />
  
  <p:variable name="lift-name" select="concat($project-acronym, '-', $dictionary-acronym, '-mobile', '_', $target-level, '.lift')" />
  
  <!-- ../build/android/dictionaries/FACS/LeDIIR-FACS-mobile.lift -->
  <p:variable name="target-lift" select="concat($target-path, '/', $lift-name)" />
  
  <p:file-copy href="../dictionaries/{$dictionary-acronym}/{$dictionary-acronym}_data/about" target="{$target-data}/" />
  <p:file-copy href="../dictionaries/{$dictionary-acronym}/{$dictionary-acronym}_data/fonts" target="{$target-data}/" />
  <p:file-copy href="../dictionaries/{$dictionary-acronym}/{$dictionary-acronym}_data/images" target="{$target-data}/" />
  <p:file-copy href="../dictionaries/{$dictionary-acronym}/{$dictionary-acronym}_data/lexicon/{$lift-name}" target="{$target-data}/lexicon/{$lift-name}" />
  
  <p:if test="$platform = 'ios'">
   <p:output primary="true" />
   <p:file-copy href="../../lediir/lift-to-tei/Dictionary/resources/audio" target="{$target-resources}/" />
   <p:file-copy href="../../lediir/lift-to-tei/Dictionary/resources/images/entries" target="{$target-resources}/images/" />
   <p:file-copy href="../../lediir/lift-to-tei/Dictionary/{$lift-name}" target="{$target-lift}" />
  </p:if>
  
 </p:declare-step>
 
 <p:declare-step type="dlbab:update-data-version">
  <p:output port="result" primary="true" pipe="result-uri"/>
  <p:option name="data-version" as="xs:string" required="true" />
  <p:option name="platform" as="xs:string" values="('android', 'ios')" required="true" />
  <p:option name="dictionary-acronym" as="xs:string" required="true" />
  <p:option name="target-level" as="xs:string" values="('Basic', 'Medium', 'Large')" required="true" />
  <p:option name="target-folder" as="xs:string?" />

  <p:variable name="year" select="if(matches($data-version, '\d{4}-\d{2}\d{2}')) then substring-before($data-version, '-') else year-from-date(current-date())"></p:variable>

  <p:variable name="path" select="if(not(empty($target-folder))) 
   then 
   concat($target-folder, '/',  $dictionary-acronym, '/', $dictionary-acronym, '-', $target-level, '_data/about/about.txt')
   else
   concat('../build/', $platform, '/dictionaries/', $dictionary-acronym, '/', $dictionary-acronym, '-', $target-level, '_data/about/about.txt')" />
  
  <p:load href="{$path}" message="   ... updating data version in {$path}"/>
  
  <p:text-replace pattern="%data-version%"  replacement="{$data-version}" />
  <p:text-replace pattern="Copyright\s©\s\d+" replacement="Copyright © {$year}" />
  <p:text-replace pattern="Praha\s\d+" replacement="Praha {$year}" />
  <p:text-replace pattern="\s?%target-level%" replacement=" ({$target-level})" />
  <p:text-replace pattern="eldi\.dictionary\.facs" replacement="eldi.dictionary.facs.{lower-case($target-level)}" />
  
  <p:store href="{$path}" />
  
 </p:declare-step>
 
 <p:declare-step type="dlbab:copy-data-for-aap">
  <p:option name="platform" as="xs:string" values="('android', 'ios')" required="true" />
  <p:option name="project-acronym" as="xs:string" required="true" />
  <p:option name="dictionary-acronym" as="xs:string" required="true" />
  <p:option name="target-folder" as="xs:string" required="true" />
  <p:option name="target-level" as="xs:string" values="('Basic', 'Medium', 'Large')" required="true" />
  
  <p:variable name="href" select="concat('../build/', $platform, '/dictionaries/', $dictionary-acronym)" />
  <p:variable name="target" select="if(starts-with($target-folder, '..')) then $target-folder else p:urify($target-folder)" />
  
  <p:file-copy href="{$href}" target="{$target}/" message="copying from {$href} to {$target}/" />
  
  <p:file-delete href="{$target}/{$dictionary-acronym}_data/lexicon" recursive="true" />
  
  <p:file-copy href="{$href}/{$dictionary-acronym}-{$target-level}_data/lexicon/{$project-acronym}-{$dictionary-acronym}-mobile_{$target-level}.lift" target="{$target}/{$dictionary-acronym}_data/lexicon/" message="copying from {$href} to {$target}/" />
  
 </p:declare-step>
 
</p:library>