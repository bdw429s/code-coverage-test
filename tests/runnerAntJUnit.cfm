<cfsetting showDebugOutput="false">

<cfparam name="url.reporter"	default="simple">
<cfparam name="url.directory"	default="tests.specs">
<cfparam name="url.recurse"		default="true" type="boolean">
<cfparam name="url.reportpath"	default="">
<cfscript>

coverageGenerator = new tests.reporters.CodeCoverage.data.coverageGenerator();
testbox = new testbox.system.TestBox(
	directory={
		mapping = url.directory,
		recurse = url.recurse
	},
	reporter={
	    type = "tests.reporters.CodeCoverage.CoverageReporter",
	    options = {
		  	pathToCapture = expandPath( '/root' ),
			whitelist = '',
			blacklist = 'cfperformanceexplorer,/testbox,/tests,/index.cfm,/Application.cfc',
	    	passThroughReporter={
	    		type='ANTJunit',
	    		option={},
	    		// This closure will be run against the results from the passthroguh reporter.
	    		resultsUDF=function( reporterData ) {
	    			// Produce individual test files due to how ANT JUnit report parses these.
				    var xmlReport = xmlParse( reporterData.results );
				    for( var thisSuite in xmlReport.testsuites.XMLChildren ){
				        fileWrite( url.reportpath & "/TEST-" & thisSuite.XMLAttributes.package & ".xml", toString( thisSuite ) );
				    }
				    // format results so they display nice in the coverage output (optional)
				    reporterData.results = '<pre>' & encodeForHTML( reporterData.results ) & '<pre>';
	    		}
	    	},
	    	sonarQube = {
				XMLOutputPath = expandpath( '/tests/sonarqube-codeCoverage.xml' )
	    	}
	    }
	} );

// Clear stats before running tests
coverageGenerator.beginCapture();

results = testbox.run();

// Clean up after
coverageGenerator.endCapture( true );

writeoutput( results );
</cfscript>
