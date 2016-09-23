<cfoutput>
	<h1>#fileData.relativeFilePath#</h1>
	<h2>File coverage: fileData.percCoverage <span style="color:#percentToColor( fileData.percCoverage )#">#round( fileData.percCoverage*100 )#%</span></h2>
	
	<cfset lineData = fileData.lineData>
	<cfset counter = 0>
	<table border=0 cellspacing=0 cellpadding=0 style="font-family:Courier New; font-size:12px">
		<cfloop array="#fileLines#" index="line">
			<cfset counter++>
			<cfset covered = ( !structKeyExists( lineData, counter ) || lineData[ counter ] )>
			<tr style="color:<cfif covered>green<cfelse>red</cfif>">
				<td>#counter#:&nbsp;&nbsp;&nbsp;</td>
				<cfset line = replace( encodeForHTML( line ), ' ', '&nbsp;', 'all' )>
				<cfset line = replace( line, '&##x9;', '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;', 'all' )>
				<td>#line#</td>
			</tr>	
				
		</cfloop>
	</table>
</cfoutput>