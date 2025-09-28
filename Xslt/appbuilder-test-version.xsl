<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:math="http://www.w3.org/2005/xpath-functions/math"
 xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
 exclude-result-prefixes="xs math xd"
 version="3.0">
 <xd:doc scope="stylesheet">
  <xd:desc>
   <xd:p><xd:b>Created on:</xd:b> Feb 21, 2025</xd:p>
   <xd:p><xd:b>Author:</xd:b> Boris</xd:p>
   <xd:p></xd:p>
  </xd:desc>
 </xd:doc>
 
 <xsl:mode on-no-match="shallow-copy"/>
 
 <xsl:param name="project-name" as="xs:string" />
 <xsl:param name="project-description" as="xs:string" />
 <xsl:param name="app-name-cs" as="xs:string" />
 <xsl:param name="app-name-en" as="xs:string" />
 <xsl:param name="package" as="xs:string" />
 <xsl:param name="filename" as="xs:string" />
 <xsl:param name="target-level" as="xs:string" />
 
 <xsl:template match="ipa-filename | ipa-asset-filename | apk-filename">
  <xsl:copy>
   <xsl:copy-of select="@*" />
   <xsl:value-of select="$filename || '.' || substring-after(., '.')"/>
  </xsl:copy>
 </xsl:template>
 
 <xsl:template match="package">
  <xsl:copy>
   <xsl:copy-of select="@*" />
   <xsl:value-of select="$package"/>
  </xsl:copy>
 </xsl:template>
 
 <xsl:template match="app-name[@lang='default']">
  <xsl:copy>
   <xsl:copy-of select="@*" />
   <xsl:value-of select="$app-name-cs"/>
  </xsl:copy>
 </xsl:template>
 
 <xsl:template match="app-name[@lang='en']">
  <xsl:copy>
   <xsl:copy-of select="@*" />
   <xsl:value-of select="$app-name-en"/>
  </xsl:copy>
 </xsl:template>
 
 <xsl:template match="project-name">
  <xsl:copy>
   <xsl:copy-of select="@*" />
   <xsl:value-of select="$project-name"/>
  </xsl:copy>
 </xsl:template>
 <xsl:template match="project-description">
  <xsl:copy>
   <xsl:copy-of select="@*" />
   <xsl:value-of select="$project-description"/>
  </xsl:copy>
 </xsl:template>
 
 <xsl:template match="feature[@name='replace-underscore-space']">
  <xsl:if test="ends-with($package, 'underscore')">
   <feature name="replace-underscore-space" value="false"/> 
  </xsl:if>
 </xsl:template>
 
 <xsl:template match="field[@name='Frequency']">
  <xsl:copy-of select="." />
  <field  type="field" name="Speech" show="true">
   <label show="false">
    <translation lang="default">Speech:</translation>
    <translation lang="cs">Speech:</translation>
   </label>
   <field-feature name="before-item" value="["/>
   <field-feature name="after-item" value="]"/>
   <field-feature name="label-position" value="beside"/>
  </field>
 </xsl:template>
 
 <xsl:template match="app-definition/lexicon-db[@type='lift'][ends-with(., '.lift')] | app-definition/source">
  <xsl:copy>
   <xsl:copy-of select="@*" />
   <xsl:value-of select="replace(., '\.lift', '_' || $target-level || '.lift')"/>
  </xsl:copy>
 </xsl:template>
 
</xsl:stylesheet>