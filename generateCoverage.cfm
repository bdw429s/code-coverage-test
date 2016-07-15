<cfscript>
	fragentClass = createObject( 'java', 'com.intergral.fusionreactor.agent.Agent' );
	pathToCapture = expandPath( '/root' );
	fileList = directoryList( pathToCapture, true, "path", "*.cf*");
	savecontent variable="local.coverageXML" {
		writeOutput( '<coverage version="1">
' );

		for( theFile in fileList ) {
			writeOutput( '	<file path="#encodeForXMLAttribute( theFile ) #">
' );
			fileContents = fileRead( theFile );
			// Replace Windows CRLF with CR
			fileContents = replaceNoCase( fileContents, chr( 13 ) & chr( 10 ), chr( 13 ), 'all' )
			// Replace lone LF with CR
			fileContents = replaceNoCase( fileContents, chr( 10 ), chr( 13 ), 'all' )
			// Break on CR, keeping empty lines 
			fileLines = fileContents.listToArray( chr( 13 ), true );
			lineMetricMap = fragentClass.getAgentInstrumentation().get("cflpi").getLineMetrics( theFile ) ?: {};
			currentLineNo=0;
			for( line in fileLines ) {
				currentLineNo++;
			if( structCount( lineMetricMap ) && lineMetricMap.containsKey( javaCast( 'int', currentLineNo ) ) ) {
				lineMetric = lineMetricMap.get(  javaCast( 'int', currentLineNo ) );
				lineRun = ( lineMetric.getCount() > 0 ? 'true' : 'false' );
				writeOutput( '		<lineToCover lineNumber="#currentLineNo#" covered="#lineRun#" />
' );
			} else {
				lineRun = false;				 
			}
				
			}
			
			writeOutput( '	</file>
' );
		}
		
		writeOutput( '
</coverage>' );
	}
	
	fileWrite( expandPath( 'code-coverage.xml' ), local.coverageXML );
	
</cfscript>
<!---<cfoutput>
<code><pre>
#encodeForHTML(local.coverageXML)#	
</pre></code>
</cfoutput>--->
