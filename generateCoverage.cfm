<cfscript>
	// Create XML generator
	coverageToXML = new coverageToXML();
	// Prettify output
	coverageToXML.setFormatXML( true );
	
	// Generate XML (writes file and returns string
	coverageXMLString = coverageToXML.generateXML(
		pathToCapture = expandPath( '/root' ),
		whitelist = '',
		blacklist = 'cfperformanceexplorer,/wirebox',
		XMLOutputPath = expandPath( '/root/code-coverage.xml' )
	);
	
</cfscript>
<cfoutput>
<code><pre>#encodeForHTML( coverageXMLString )#</pre></code>
</cfoutput>
