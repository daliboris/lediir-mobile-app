<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:dlbab="https://www.daliboris.cz/ns/xproc/app-builder"
	version="3.0">
   
  <p:input port="source" primary="true">
  	<p:document href="../local.FACS.appDef" content-type="application/xml" />
  </p:input>
   
	<p:output port="result" serialization="map{'indent' : true()}" />
	

	<p:xslt>
		<p:with-input port="stylesheet" href="../Xslt/appbuilder-for-mac.xsl" />
	</p:xslt>
	
	<p:store href="../local.FACS-mac.appDef" serialization="map{'indent' : true()}" message="Storing text to ../local.FACS-mac.appDef" />
	<p:store href="../../lediir/lift-to-tei/Dictionary/macOS/Dictionary/FACS.appDef" serialization="map{'indent' : true()}" message="Storing text to ../../lediir/lift-to-tei/Dictionary/macOS/Dictionary/FACS.appDef" />
	
	<p:file-copy href="../../lediir/lift-to-tei/Dictionary/resources/audio" target="../../lediir/lift-to-tei/Dictionary/macOS/Dictionary/resources/" />
	<p:file-copy href="../../lediir/lift-to-tei/Dictionary/resources/images/entries" target="../../lediir/lift-to-tei/Dictionary/macOS/Dictionary/resources/images/" />
	<p:file-copy href="../../lediir/lift-to-tei/Dictionary/LeDIIR-FACS-mobile.lift" target="../../lediir/lift-to-tei/Dictionary/macOS/Dictionary/LeDIIR-FACS-mobile.lift" />
	

</p:declare-step>
