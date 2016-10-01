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
	structLiteral = {
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
	myQry2 = queryExecute( '
		SELECT *
		FROM myQry
		WHERE 1 = 1', {}, { dbtype='query' } );
	writedump( myQry );
</cfscript>

<!--- tag-based component --->
<cfset taggy = new root.taggy()>
<cfset taggy.iGetCalled()>

<!--- script-based component --->
<cfset scripty = new root.scripty()>
<cfset scripty.iGetCalled()>

<cfset wirebox = new wirebox.system.ioc.injector()>
<cfset scripty = wirebox.getInstance( 'root.scripty' )>





