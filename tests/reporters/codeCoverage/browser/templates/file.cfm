<cfoutput>
	<h1>#fileData.relativeFilePath#</h1>
	<h2>File coverage: fileData.percCoverage <span style="color:#percentToColor( fileData.percCoverage )#">#round( fileData.percCoverage*100 )#%</span></h2>
	<a href="javascript:history.back()"><< Back <<</a>	
	<hr width="100%">
		
	<cfset lineData = fileData.lineData>
	<cfset counter = 0>
	<table border=0 cellspacing=0 cellpadding=0 style="font-family:Courier New; font-size:12px">
		<cfloop array="#fileLines#" index="line">
			<cfset counter++>
			<cfset covered = ( structKeyExists( lineData, counter ) && lineData[ counter ] )>
			<tr style="color:<cfif covered>green<cfelseif structKeyExists( lineData, counter )>red<cfelse>gray</cfif>">
				<td>#counter#:&nbsp;&nbsp;&nbsp;</td>
				<!--- Replace space with non-breaking space --->
				<cfset line = replace( encodeForHTML( line ), ' ', '&nbsp;', 'all' )>
				<!--- Replace tabs (encoded by now) with 5 non-breaking spaces --->
				<cfset line = replace( line, '&##x9;', '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;', 'all' )>
				<td>#line#</td>
			</tr>	
				
		</cfloop>
	</table>
</cfoutput>