<cfsetting showDebugOutput="false">

<cfparam name="url.reporter" 			default="simple">
<cfparam name="url.directory" 		default="tests.specs">
<cfparam name="url.recurse" 			default="true" type="boolean">
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
	    		type='simple',
	    		option={}
	    	},
	    	sonarQube = {
				XMLOutputPath = expandpath( '/tests/sonarqube-codeCoverage.xml' )
	    	},
	    	browser = {
	    		OutputDir = expandPath( '/tests/CoverageBrowser' )
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
