/**
* ********************************************************************************
* Copyright Ortus Solutions, Corp
* www.ortussolutions.com
* ********************************************************************************
*
* I am a custom TestBox repoter that captures line coverage data.  Use me like so:
*
* testbox = new testbox.system.TestBox(
*	directory={
*		mapping = url.directory,
*		recurse = url.recurse
*	},
*	reporter={
*	    type = "tests.reporters.CodeCoverage.CoverageReporter",
*	    options = {
*		  	pathToCapture = expandPath( '/root' ),
*			whitelist = '/models,/handlers,/modules_app',
*			blacklist = '/tests,/temp',
*	    	passThruReporter={
*	    		type='simple',
*	    		option={}
*	    	},
*	    	sonarQube = {
*				XMLOutputPath = expandpath( '/tests/sonarqube-codeCoverage.xml' )
*	    	}
*	    }
*	} );
*
*/
component {

	/**
	* Get the name of the reporter
	*/
	function getName(){
		return "Code Coverage";
	}

	/**
	* Do the reporting thing here using the incoming test results
	* The report should return back in whatever format they desire and should set any
	* Specifc browser types if needed.
	* @results.hint The instance of the TestBox TestResult object to build a report on
	* @testbox.hint The TestBox core object
	* @options.hint A structure of options this reporter needs to build the report with
	*/
	any function runReport(
		required testbox.system.TestResult results,
		required testbox.system.TestBox testbox,
		struct options
	){
	  	// *************** Default options ***************
	  	var opts = arguments.options ?: {};
	  	opts.passThruReporter = opts.passThruReporter ?: {
  			type = 'simple',
  			options = {}
	  	};
	  	opts.sonarQube = opts.sonarQube ?: {};
		opts.sonarQube.XMLOutputPath = opts.sonarQube.XMLOutputPath ?: '';		
	  	opts.pathToCapture = opts.pathToCapture ?: '';
		opts.whitelist = opts.whitelist ?: '';
		opts.blacklist = opts.blacklist ?: '';
	  	
	  	// validate path to capture
	  	if( !len( opts.pathToCapture ) ) {
	  		throw( message='Please provide [options.pathToCapture] to the reporter.', detail='The [pathToCapture] option should be an absolute path that points to a directory of CFML code executed by your tests.' );
	  	}	  	
	  	if( !directoryExists( opts.pathToCapture ) ) {
	  		throw( message='Reporter option [pathToCapture] does not point to a real and absolute directory path.', detail=opts.pathToCapture );
	  	}
	  	
	  	// *************** Prepare coverage data ***************
		var coverageGenerator = new data.coverageGenerator();
		var qryCoverageData = coverageGenerator.generateData( 
				opts.pathToCapture,
				opts.whitelist,
				opts.blacklist
			);
			
	  	// *************** SonarQube Integration ***************
	  	var sonarQubeResults = '';
	  	if( len( opts.sonarQube.XMLOutputPath ) ) {
			// Create XML generator
			var sonarQube = new sonarqube.SonarQube();
			// Prettify output
			sonarQube.setFormatXML( true );
			
			// Generate XML (writes file and returns string
			var coverageXMLString = sonarQube.generateXML( qryCoverageData, opts.sonarQube.XMLOutputPath );
	  		sonarQubeResults = 'SonarQube code coverage XML file generated at #opts.sonarQube.XMLOutputPath#';
	  	}
	  		  	
	  	// ***************  Generate Stats ***************
	  	var coverageStats = new stats.CoverageStats();
	  	var stats = coverageStats.generateStats( qryCoverageData );
		savecontent variable="local.statsResults"{
			include "stats/CoverageStats.cfm";
		}
	  	
	  	// *************** Execute pass-through reporter ***************
	  	var nestedReporterResult = '';
	  	if( len( arguments.options.passThruReporter.type ) ) {
			testbox.exposeBuildReporter = variables.exposeBuildReporter;
			testbox.exposeBuildReporter();
			
			var nestedReporter = testbox.buildReporter( 
				arguments.options.passThruReporter.type,
				arguments.options.passThruReporter.options ?: {}
			);
			
			nestedReporterResult = nestedReporter.runReport( arguments.results, arguments.testbox, {} );	  		
	  	}
		
		// prepare the wrapper report
		savecontent variable="local.report"{
			include "CoverageReportWrapper.cfm";
		}

		return local.report;
	}

	// This is a mixin that will expose the buildReporter() method in the TestBox component
	private function exposeBuildReporter() {
		this.buildReporter = variables.buildReporter;
	}

}