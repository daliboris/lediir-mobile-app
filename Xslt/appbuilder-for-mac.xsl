<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:math="http://www.w3.org/2005/xpath-functions/math"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  exclude-result-prefixes="xs math xd"
  version="3.0">
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> Feb 15, 2024</xd:p>
      <xd:p><xd:b>Author:</xd:b> Boris</xd:p>
      <xd:p></xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:output method="xml" indent="yes" />
  <xsl:mode on-no-match="shallow-copy"/>
  
  <xsl:template match="text()[contains(., 'lift-to-tei\Dictionary')]" priority="2">
    <xsl:value-of select="replace(., 'V:\\Projekty\\Github\\Daliboris\\lediir\\lift-to-tei\\Dictionary\\', '/Users/boris/Documents/Dictionary/') => translate('\', '/')"/>
  </xsl:template>

  <xsl:template match="text()[contains(., '\')]">
    <xsl:value-of select="translate(., '\', '/')"/>
  </xsl:template>
  
  
</xsl:stylesheet>