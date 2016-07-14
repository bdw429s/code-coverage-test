<!--- HTML --->
<h1>Coverage Tester App</h1>

<!---White space --->





   
  
     
      
     				
     			
     									
     									 	 	  
     									 	 	 	 	 	
     									 	 	 	 	  	 	
     									 	 	 	 	  	  	
     									 	 	 	 	  	   
     									 	 	 	 	  	  

<!--- Comments --->
<!--- More 
comments
here
 --->

<!--- Random CF tags --->
<cfset myFlag = true>
<cfset structLiteral = {
	foo : 'bar',
	baz : 'bum',
	whoo : 'hoo'
}>
<cfif myFlag>
	<cfset message = "first half">
<cfelse>
	<cfset message = "second half">
</cfif>
<cfoutput>
	#message#
</cfoutput>
<cfset myQry = queryNew( 'col1' )>
<cfquery name="myQry2" dbtype="query">
	SELECT *
	FROM myQry
	WHERE 1 = 1
</cfquery>
<cfdump var="#myQry#">

<!--- cfscript block --->
<cfscript>
	myFlag = true;
	anotherFlag = structLiteral = {
		foo : 'bar',
		baz : 'bum',
		whoo : 'hoo'
	};
	if( myFlag ) {
		message = 'first half';
	} else {
		message = 'second half';
	}
	writeOutput( message );
	myQry = queryNew( 'col1' );
	query name="myQry2" dbtype="query" { echo( '
		SELECT *
		FROM myQry
		WHERE 1 = 1
	' ) }
	writedump( myQry );
</cfscript>

<!--- tag-based component --->
<cfset taggy = new taggy()>
<cfset taggy.iGetCalled()>

<!--- script-based component --->
<cfset scripty = new scripty()>
<cfset scripty.iGetCalled()>)>

<!--- generage coverage --->
<cfinclude template="generateCoverage.cfm">





