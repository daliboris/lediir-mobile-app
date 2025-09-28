<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:dlbab="https://www.daliboris.cz/ns/xproc/app-builder"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	name="mobile-app-updating"
	version="3.0">
   
   <p:import href="AppBuilder-Library.xpl" />
	
	<p:option name="platform" select="'android'" values="('android', 'ios')" /> <!-- static="true"  -->
	<p:option name="project-acronym" select="'LeDIIR'" /> <!-- static="true"  -->
	<p:option name="dictionary-acronym" select="'FACS'" /> <!-- static="true"  -->
	<p:option name="data-version" select="'2025-05-29'" /> <!-- static="true"  -->
<!--	<p:option name="test-version" select="'-sample'" static="true" />-->
<!--	<p:option name="test-version" select="'-nonbreak'" static="true" />-->
<!--	<p:option name="test-version" select="'-underscore'" static="true" /> -->
<!--	<p:option name="test-version" select="'-ABC'" static="true" /> -->
	<p:option name="test-version" select="'-pronunciation'" /> <!-- static="true"  --> 
	<p:option name="target-level" as="xs:string*" select="('Basic', 'Medium', 'Large')" values="('Basic', 'Medium', 'Large')" />
 

   
  <p:input port="source" primary="true" use-when="false()" />

	<p:output port="result" serialization="map{'indent' : true()}" sequence="true" />
	
	<!-- PIPELINE STEP -->
	<p:declare-step type="dlbab:build-appdef" name="building-appdef">
		
		<p:documentation>
			<xhtml:section xml:lang="en">
				<xhtml:h2></xhtml:h2>
				<xhtml:p></xhtml:p>
			</xhtml:section>
			<xhtml:section xml:lang="cs">
				<xhtml:h2></xhtml:h2>
				<xhtml:p></xhtml:p>
			</xhtml:section>
		</p:documentation>
		
		<p:input port="source" primary="true" />
		
		<p:output port="result" primary="true" />
		
		<p:option name="platform" as="xs:string" values="('android', 'ios')" required="true" />
		<p:option name="project-acronym" as="xs:string" required="true" />
		<p:option name="dictionary-acronym" as="xs:string" required="true" />
		<p:option name="data-version" as="xs:string" required="true"/>
		
		<p:option name="target-level" as="xs:string" values="('Basic', 'Medium', 'Large')" required="true" />
		
		<!-- PIPILINE BODY -->
		
		<p:variable name="target-file-path" select="'../build/' || $platform || '/dictionaries/' || $dictionary-acronym || '/' || $dictionary-acronym || '-' || $target-level || '.appDef'" />
		
		<p:file-info href="{$target-file-path}" fail-on-error="false"/>
		
		<p:choose>
			<p:when test="/c:error">
				<p:identity>
					<p:with-input port="source" pipe="source@building-appdef" />
				</p:identity>
			</p:when>
			<p:otherwise>
				<p:load href="{$target-file-path}" content-type="application/xml" message="... loading latest version {$target-file-path}" />
			</p:otherwise>
		</p:choose>
		
		<p:variable name="current-version" select="//version" />
		
		<p:identity>
			<p:with-input port="source" pipe="source@building-appdef" />
		</p:identity>
		
		<dlbab:replace-secrets platform="{$platform}">
			<p:with-input port="secrets" href="local.secrets.xml" />
		</dlbab:replace-secrets>
		
		<dlbab:update-version platform="all" p:message="... updating app version (latest: {$current-version/@code}); {base-uri(/)}">
			<p:with-option name="current-version" select="$current-version" />
		</dlbab:update-version>
		
		<p:if test="$platform = ('ios')">
			<p:xslt>
				<p:with-input port="stylesheet" href="../Xslt/appbuilder-for-mac.xsl" />
			</p:xslt>
		</p:if>
		
		<p:xslt message="... updating for target level: {$target-level}">
			<p:with-input port="stylesheet" href="../Xslt/appbuilder-test-version.xsl" />
			<p:with-option name="parameters" select="map {
				'project-name' : 'Persian-Czech Dictionary (' || $target-level || ')',
				'project-description' : 'Persko-český slovník, mobilní aplikace (' || $target-level || ')',
				'app-name-cs' : 'Persko-český mobilní slovník (' || $target-level || ')' ,
				'app-name-en' : 'Persian-Czech Mobile Dictionary (' || $target-level || ')',
				'package' : 'cz.cas.soc.eldi.dictionary.facs.' || lower-case($target-level),
				'filename' : 'Persian-Czech_Dictionary-' || $target-level,
				'target-level' : $target-level
				}" />
		</p:xslt>
		
		<p:store href="{$target-file-path}" message="... Storing {$target-file-path}" />
		
		<dlbab:copy-dictionary-data platform="{$platform}" project-acronym="{$project-acronym}" dictionary-acronym="{$dictionary-acronym}" target-level="{$target-level}" name="copying-data" p:message="... copying dictionary data ({$platform}): {$dictionary-acronym}-{$target-level}" />
		
		<dlbab:update-data-version platform="{$platform}" dictionary-acronym="{$dictionary-acronym}" target-level="{$target-level}" data-version="{$data-version}" p:depends="copying-data" p:message="... updating data version: ({$platform}): {$dictionary-acronym}-{$target-level}, version: {$data-version}" />
		
		<p:group message="Copying data for cloud" use-when="true()">
			<dlbab:copy-data-for-aap platform="android" dictionary-acronym="{$dictionary-acronym}" target-level="{$target-level}" project-acronym="{$project-acronym}" target-folder="../build/cloud/android/dictionaries" />
			<dlbab:remove-secrets platform="android" dictionary-acronym="{$dictionary-acronym}" root-folder="../build/cloud" />
			
			<!-- TODO -->
			<p:group use-when="false()">
				<dlbab:copy-data-for-aap platform="ios" dictionary-acronym="{$dictionary-acronym}" target-level="{$target-level}" project-acronym="{$project-acronym}" target-folder="../build/cloud/ios/dictionaries" />
				<dlbab:remove-secrets platform="ios" dictionary-acronym="{$dictionary-acronym}" root-folder="../build/cloud" />
			</p:group>

			<p:identity>
				<p:with-input port="source"><c:result>Copying data for cloud finished.</c:result></p:with-input>
			</p:identity>
			
		</p:group>
		
	</p:declare-step>
	
	<!-- VARIABLES -->
	<p:variable name="target-file-path" select="'../build/' || $platform || '/dictionaries/' || $dictionary-acronym || '/' || $dictionary-acronym || $test-version || '.appDef'" />

	<p:load href="../dictionaries/{$dictionary-acronym}/{$dictionary-acronym}.appDef" content-type="application/xml" name="default-appdef" />
	
	
	<p:for-each>
		<p:with-input select="$target-level"/>
		<p:variable name="target" select="." />
		<dlbab:build-appdef
			project-acronym="{$project-acronym}"
			dictionary-acronym="{$dictionary-acronym}"
			data-version="{$data-version}"
			target-level="{$target}"
			>
			<p:with-input port="source" pipe="result@default-appdef" />
			<p:with-option name="platform" select="$platform"/>
			
		</dlbab:build-appdef>
	</p:for-each>
	
	
	
	<!-- PIPILINE BODY -->
	<p:group use-when="false()">
		
		<p:file-info href="{$target-file-path}" fail-on-error="false"/>
		
		<p:choose>
			<p:when test="/c:error">
				<p:identity>
					<p:with-input port="source" pipe="source@mobile-app-updating" />
				</p:identity>
			</p:when>
			<p:otherwise>
				<p:load href="{$target-file-path}" content-type="application/xml" message="... loading latest version {$target-file-path}" />
			</p:otherwise>
		</p:choose>
		
		
		<p:variable name="current-version" select="//version" />
		
		<p:identity>
			<p:with-input port="source" pipe="source@mobile-app-updating" />
		</p:identity>
		
		
		<p:group message="Updating application version in common repository (for GitHub)" use-when="false()">
			<p:documentation>Zvýší číslo verze o 1 v hlavním definičním souboru. Aplikuje se po otestování funkčních verzí. Slouží k zachování verze v rámci repozitáře zdrojového kódu.</p:documentation>
			
			<p:variable name="path" select="base-uri(/)" />
			
			<dlbab:update-version platform="android" p:message="updating app version for Android" />
			<dlbab:update-version platform="ios" method="copy" p:message="updating app version for iOS" />
			
			<p:store href="{$path}" message="Storing to {$path}" />
			
		</p:group>
		
		<p:group message="Updating application version for {$platform}, for build only" use-when="true()">
			
			<dlbab:replace-secrets platform="{$platform}">
				<p:with-input port="secrets" href="local.secrets.xml" />
			</dlbab:replace-secrets>
			
			<dlbab:update-version platform="all" p:message="... updating app version (latest: {$current-version/@code}); {base-uri(/)}">
				<p:with-option name="current-version" select="$current-version" />
			</dlbab:update-version>
			
			<p:if test="$platform = ('ios')">
				<p:xslt>
					<p:with-input port="stylesheet" href="../Xslt/appbuilder-for-mac.xsl" />
				</p:xslt>
			</p:if>
			
			<p:choose>
				<p:when test="$test-version = '-pronunciation'">
					<p:xslt message="... updating for test version: {$test-version}">
						<p:with-input port="stylesheet" href="../Xslt/appbuilder-test-version.xsl" />
						<p:with-option name="parameters" select="map {
							'project-name' : 'Persian-Czech Dictionary (pronunciation)',
							'project-description' : 'Persko-český slovník, mobilní aplikace (výslovnost)',
							'app-name-cs' : 'Persko-český mobilní slovník (výslovnost)' ,
							'app-name-en' : 'Persian-Czech Mobile Dictionary (pronunciation)',
							'package' : 'cz.cas.soc.eldi.dictionary.facs.pronunciation',
							'filename' : 'Persian-Czech_Dictionary-pronunciation' 
							}" />
					</p:xslt>
				</p:when>
				<p:when test="$test-version = '-Basic'">
					<p:xslt message="... updating for test version: {$test-version}">
						<p:with-input port="stylesheet" href="../Xslt/appbuilder-test-version.xsl" />
						<p:with-option name="parameters" select="map {
							'project-name' : 'Persian-Czech Dictionary (Basic)',
							'project-description' : 'Persko-český slovník, mobilní aplikace (Basic)',
							'app-name-cs' : 'Persko-český mobilní slovník (Basic)' ,
							'app-name-en' : 'Persian-Czech Mobile Dictionary (Basic)',
							'package' : 'cz.cas.soc.eldi.dictionary.facs.basic',
							'filename' : 'Persian-Czech_Dictionary-Basic' 
							}" />
					</p:xslt>
				</p:when>
				<p:when test="$test-version = '-Medium'">
					<p:xslt message="... updating for test version: {$test-version}">
						<p:with-input port="stylesheet" href="../Xslt/appbuilder-test-version.xsl" />
						<p:with-option name="parameters" select="map {
							'project-name' : 'Persian-Czech Dictionary (Medium)',
							'project-description' : 'Persko-český slovník, mobilní aplikace (Medium)',
							'app-name-cs' : 'Persko-český mobilní slovník (Medium)' ,
							'app-name-en' : 'Persian-Czech Mobile Dictionary (Medium)',
							'package' : 'cz.cas.soc.eldi.dictionary.facs.medium',
							'filename' : 'Persian-Czech_Dictionary-Medium' 
							}" />
					</p:xslt>
				</p:when>
				<p:when test="$test-version = '-Large'">
					<p:xslt message="... updating for test version: {$test-version}">
						<p:with-input port="stylesheet" href="../Xslt/appbuilder-test-version.xsl" />
						<p:with-option name="parameters" select="map {
							'project-name' : 'Persian-Czech Dictionary (Large)',
							'project-description' : 'Persko-český slovník, mobilní aplikace (Large)',
							'app-name-cs' : 'Persko-český mobilní slovník (Large)' ,
							'app-name-en' : 'Persian-Czech Mobile Dictionary (Large)',
							'package' : 'cz.cas.soc.eldi.dictionary.facs.large',
							'filename' : 'Persian-Czech_Dictionary-Large' 
							}" />
					</p:xslt>
				</p:when>
				<p:when test="$test-version = '-sample'">
					<p:xslt message="... updating for test version: {$test-version}">
						<p:with-input port="stylesheet" href="../Xslt/appbuilder-test-version.xsl" />
						<p:with-option name="parameters" select="map {
							'project-name' : 'Persian-Czech Dictionary (phrases: sample)',
							'project-description' : 'Persko-český slovník, mobilní aplikace (frazémy: výběr)',
							'app-name-cs' : 'Persko-český mobilní slovník (frazémy: výběr)' ,
							'app-name-en' : 'Persian-Czech Mobile Dictionary (phrases: sample)',
							'package' : 'cz.cas.soc.eldi.dictionary.facs.sample',
							'filename' : 'Persian-Czech_Dictionary-sample' 
							}" />
					</p:xslt>
				</p:when>
				<p:when test="$test-version = '-underscore'">
					<p:xslt message="... updating for test version: {$test-version}">
						<p:with-input port="stylesheet" href="../Xslt/appbuilder-test-version.xsl" />
						<p:with-option name="parameters" select="map {
							'project-name' : 'Persian-Czech Dictionary (phrases: underscore)',
							'project-description' : 'Persko-český slovník, mobilní aplikace (frazémy: podtržítka)',
							'app-name-cs' : 'Persko-český mobilní slovník (frazémy: podtržítka)' ,
							'app-name-en' : 'Persian-Czech Mobile Dictionary (phrases: underscore)',
							'package' : 'cz.cas.soc.eldi.dictionary.facs.underscore',
							'filename' : 'Persian-Czech_Dictionary-underscore' 
							}" />
					</p:xslt>
				</p:when>
				<p:when test="$test-version = '-nonbreak'">
					<p:xslt message="... updating for test version: {$test-version}">
						<p:with-input port="stylesheet" href="../Xslt/appbuilder-test-version.xsl" />
						<p:with-option name="parameters" select="map {
							'project-name' : 'Persian-Czech Dictionary (phrases: nonbreak spaces)',
							'project-description' : 'Persko-český slovník, mobilní aplikace (frazémy: pevné mezery)',
							'app-name-cs' : 'Persko-český mobilní slovník (frazémy: pevné mezery)' ,
							'app-name-en' : 'Persian-Czech Mobile Dictionary (phrases: nonbreak spaces)',
							'package' : 'cz.cas.soc.eldi.dictionary.facs.nonbreak',
							'filename' : 'Persian-Czech_Dictionary-nonbreak' 
							}" />
					</p:xslt>
				</p:when>
			</p:choose>
			
			
			
			<p:store href="{$target-file-path}" message="... Storing {$target-file-path}" />
			
			<dlbab:copy-dictionary-data platform="{$platform}" dictionary-acronym="{$dictionary-acronym}" test-version="{$test-version}" name="copying-data" p:message="... copying dictionary data" />
			
			<dlbab:update-data-version data-version="{$data-version}" p:depends="copying-data" platform="{$platform}" dictionary-acronym="{$dictionary-acronym}" p:message="... updating data version" />
			
		</p:group>
		
		<p:group message="Copying data for cloud" use-when="true()">
			<dlbab:copy-data-for-aap platform="android" dictionary-acronym="{$dictionary-acronym}" target-folder="../build/cloud/android/dictionaries" />
			<dlbab:remove-secrets platform="android" dictionary-acronym="{$dictionary-acronym}" root-folder="../build/cloud" />
			
			<dlbab:copy-data-for-aap platform="ios" dictionary-acronym="{$dictionary-acronym}" target-folder="../build/cloud/ios/dictionaries" />
			<dlbab:remove-secrets platform="ios" dictionary-acronym="{$dictionary-acronym}" root-folder="../build/cloud" />
			
			<p:identity>
				<p:with-input port="source"><c:result>Copying data for cloud finished.</c:result></p:with-input>
			</p:identity>
			
		</p:group>
	</p:group>
	

</p:declare-step>
