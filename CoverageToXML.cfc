/**
* ********************************************************************************
* Copyright Ortus Solutions, Corp
* www.ortussolutions.com
* ********************************************************************************
* I collect code coverage data for a directory of files and generate
* an XML document for import into SonarQube's Generic Code Coverage plugin.
*/
component accessors=true {
	
	/**
	* If set to true, the XML document will be formatted for human readability
	*/
	property name="formatXML" default="false";
	
	function init() {
		// Classes needed to work.
		variables.pathPatternMatcher = new PathPatternMatcher();
		variables.fragentClass = createObject( 'java', 'com.intergral.fusionreactor.agent.Agent' );
		
		// This transformation will format an XML documente to be indented with line breaks for readability
		variables.xlt = '<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
						<xsl:output method="xml" encoding="utf-8" indent="yes" xslt:indent-amount="2" xmlns:xslt="http://xml.apache.org/xslt" />
						<xsl:strip-space elements="*"/>
						<xsl:template match="node() | @*"><xsl:copy><xsl:apply-templates select="node() | @*" /></xsl:copy></xsl:template>
						</xsl:stylesheet>';

		return this;
	}
	
	/**
	* @pathToCapture The full path to a folder of code.  Searched recursivley
	* @whitelist Comma-delimeted list or array of file paths to include
	* @blacklist Comma-delimeted list or array of file paths to exclude
	* @XMLOutputPath Full path to write XML file to
	*
	* @Returns generated XML string
	*/
	string function generateXML(
		required string pathToCapture = expandPath( '/root' ),
		any whitelist='',		
		any blacklist='',
		string XMLOutputPath=''
	) {
		// Convert lists to an array.
		if( isSimpleValue( arguments.whitelist ) ) { arguments.whitelist = arguments.whitelist.listToArray(); }
		if( isSimpleValue( arguments.blacklist ) ) { arguments.blacklist = arguments.blacklist.listToArray(); }

		
		// Get a recursive list of all CFM and CFC files in project root.
		var fileList = directoryList( arguments.pathToCapture, true, "path", "*.cf*");
		
		var coverageXML = XMLNew();
		var rootNode = XMLElemNew( coverageXML, 'coverage' );
		rootNode.XMLAttributes[ 'version' ] = 1;
	
		for( var theFile in fileList ) {
			
			// Skip this file if it doesn't match our patterns
			// Pass a path relative to our root folder
			if( !isPathAllowed( replaceNoCase( theFile, arguments.pathToCapture, '' ), arguments.whitelist, arguments.blacklist ) ) {
				continue;
			}
			
			var fileNode = XMLElemNew( coverageXML, 'file' );
			fileNode.XMLAttributes[ 'path' ] = theFile;
			
			var fileContents = fileRead( theFile );
			// Replace Windows CRLF with CR
			fileContents = replaceNoCase( fileContents, chr( 13 ) & chr( 10 ), chr( 13 ), 'all' )
			// Replace lone LF with CR
			fileContents = replaceNoCase( fileContents, chr( 10 ), chr( 13 ), 'all' )
			// Break on CR, keeping empty lines 
			var fileLines = fileContents.listToArray( chr( 13 ), true );
			var lineMetricMap = fragentClass.getAgentInstrumentation().get("cflpi").getLineMetrics( theFile ) ?: {};
			var currentLineNo=0;
			for( var line in fileLines ) {
				currentLineNo++;
				if( structCount( lineMetricMap ) && lineMetricMap.containsKey( javaCast( 'int', currentLineNo ) ) ) {
					var lineMetric = lineMetricMap.get(  javaCast( 'int', currentLineNo ) );
					
					var lineNode = XMLElemNew( coverageXML, 'lineToCover' );
					lineNode.XMLAttributes[ 'lineNumber' ] = currentLineNo;
					lineNode.XMLAttributes[ 'covered' ] = ( lineMetric.getCount() > 0 ? 'true' : 'false' );
					fileNode.XMLChildren.append( lineNode );
				}
				
			}
			
			rootNode.XMLChildren.append( fileNode );
		
		}
			
		coverageXML.XMLChildren.append( rootNode );
		
		if( getFormatXML() ) {
			// Clean up formatting on XML doc and convert to string
			coverageXML = XmlTransform( coverageXML, variables.xlt );			
		}		
				
		// Convert to string
		var coverageXMLString = toString( coverageXML ); 
		
		// If there is an output path, write it to a file
		if( len( XMLOutputPath ) ) {
			fileWrite( arguments.XMLOutputPath, coverageXMLString );
		}
		
		// Return the XML string
		return coverageXMLString;

	}
	
	/**
	* Determines if a path is valid given the whitelist and black list.  White and black lists
	* use standard file globbing patterns.
	*
	* @path The relative path to check.
	* @whitelist paths to allow
	* @blacklist paths to exclude
	*/
	function isPathAllowed(
		required string path,
		required array whitelist,
		required array blacklist
	) {
			// Check whitelist
			if( arraylen( arguments.whitelist ) && !pathPatternMatcher.matchPatterns( arguments.whitelist, arguments.path ) ) {
				return false;
			}
			// Check blacklist
			if( arraylen( arguments.blacklist ) && pathPatternMatcher.matchPatterns( arguments.blacklist, arguments.path ) ) {
				return false;
			}
			
			// We passed all the checks
			return true;					
	}
}