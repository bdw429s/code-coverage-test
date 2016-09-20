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
		try {
			variables.fragentClass = createObject( 'java', 'com.intergral.fusionreactor.agent.Agent' );
		} catch( Any e ) {
			throw( message='Error loading the FusionReactor agent class.  Please ensure FusionReactor is installed', detail=e.message );
		}
	
		//writeDump( fragentClass.getAgentInstrumentation().get("cflpi").getSourceFiles() ); //abort;
		//fragentClass.getAgentInstrumentation().get("cflpi").reset();
		//writeDump( fragentClass.getAgentInstrumentation().get("cflpi") ); abort;
		
		// This transformation will format an XML documente to be indented with line breaks for readability
		variables.xlt = '<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
						<xsl:output method="xml" encoding="utf-8" indent="yes" xslt:indent-amount="2" xmlns:xslt="http://xml.apache.org/xslt" />
						<xsl:strip-space elements="*"/>
						<xsl:template match="node() | @*"><xsl:copy><xsl:apply-templates select="node() | @*" /></xsl:copy></xsl:template>
						</xsl:stylesheet>';
						
		variables.CR = chr( 13 );
		variables.LF = chr( 10 );
		variables.CRLF = CR & LF;

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
			fileContents = replaceNoCase( fileContents, CRLF, CR, 'all' );
			// Replace lone LF with CR
			fileContents = replaceNoCase( fileContents, LF, CR, 'all' );
			// Break on CR, keeping empty lines 
			var fileLines = fileContents.listToArray( CR, true );
			
			var lineMetricMap = fragentClass.getAgentInstrumentation().get("cflpi").getLineMetrics( theFile ) ?: {};
			
			// Turn on line profiling
			fragentClass.getAgentInstrumentation().get("cflpi").setActive( true );
			
			
			// If we don't have any metrics for this file 
			if( !structCount( lineMetricMap ) ) {
				var PageSourceImpl = createObject( 'java', 'lucee.runtime.PageSourceImpl' );
				// Attempt to compile and load the class
				PageSourceImpl.best( getPageContext().getPageSources( makePathRelative( theFile ) ) ).loadPage( getPageContext(), true );
				// Check for metrics again 
				lineMetricMap = fragentClass.getAgentInstrumentation().get("cflpi").getLineMetrics( theFile ) ?: {};
			}
			
			var currentLineNo=0;
			var previousLineRan=false;
			
			for( var line in fileLines ) {
				currentLineNo++;
				if( structCount( lineMetricMap ) && lineMetricMap.containsKey( javaCast( 'int', currentLineNo ) ) ) {
					var lineMetric = lineMetricMap.get(  javaCast( 'int', currentLineNo ) );
					
					var lineNode = XMLElemNew( coverageXML, 'lineToCover' );
					var covered = ( lineMetric.getCount() > 0 ? 'true' : 'false' );
					
					// Overrides for bugginess ************************************************************************
					
					// Ignore any tag based comments.  Some are reporting as covered, others aren't.  They really all should be ignored.
					if( reFindNoCase( '^<!---.*--->$', trim( line) ) ) {
						continue;
					}
					
					// Ignore any CFscript tags.  They don't consistently report and they aren't really executable in themselves
					if( reFindNoCase( '<(\/)?cfscript>', trim( line) )) {
						continue;
					}
					
					// Count as covered any closing CF tags where the previous line ran.  Ending tags don't always seem to get picked up.
					if( !covered && reFindNoCase( '<\/cf.*>', trim( line) ) && previousLineRan ) {
						covered = true;
					}
										
					// Count as covered any cffunction or cfargument tag where the previous line ran.  
					if( !covered && reFindNoCase( '^<cf(function|argument)', trim( line) ) && previousLineRan ) {
						covered = true;
					}
					
					// Overrides for bugginess ************************************************************************
					
					lineNode.XMLAttributes[ 'lineNumber' ] = currentLineNo;
					lineNode.XMLAttributes[ 'covered' ] = covered;
					fileNode.XMLChildren.append( lineNode );
					
					var previousLineRan=covered;
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
	
	    
    /** 
    * Accepts an absolute path and returns a relative path
    * Does NOT apply any canonicalization 
    */
    string function makePathRelative( required string absolutePath ) {
    	if( !isWindows() ) { 
    		return arguments.absolutePath;
    	}
    	var driveLetter = listFirst( arguments.absolutePath, ':' );
    	var path = listRest( arguments.absolutePath, ':' );
    	var mapping = locateMapping( driveLetter );
    	return mapping & path;
    }
    
    /** 
    * Accepts a Windows drive letter and returns a CF Mapping
    * Creates the mapping if it doesn't exist
    */
    string function locateMapping( required string driveLetter  ) {
    	var mappingName = '/' & arguments.driveLetter & '_drive';
    	var mappingPath = arguments.driveLetter & ':/';
    	var mappings = getApplicationSettings().mappings;
    	if( !structKeyExists( mappings, mappingName ) ) {
    		mappings[ mappingName ] = mappingPath;
    		application action='update' mappings='#mappings#';
   		}
   		return mappingName;
    }
    
    /** 
    * Detect if OS is Windows
    */
	boolean function isWindows(){
		return createObject( "java", "java.lang.System" ).getProperty( "os.name" ).toLowerCase().contains( "win" );
	}
	
}