<cfoutput>
<!DOCTYPE html>
<html>
	<head>
		<meta charset="utf-8">
		<meta name="generator" content="TestBox v#testbox.getVersion()#">
		<title>Pass: #results.getTotalPass()# Fail: #results.getTotalFail()# Errors: #results.getTotalError()#</title>
	</head>
	<body>
		<cfif len( sonarQubeResults ) >
			#sonarQubeResults#<br><br>
		</cfif>
		
		#statsResults#
		
		#nestedReporterResult#	
	</body>
</html>

</cfoutput>