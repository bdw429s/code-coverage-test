<cfoutput>
<h1>Code Coverage Browser</h1> 

<h2>Total Files Processed: #stats.numFiles#</h2>
<h2>Total project coverage: <span style="color:#percentToColor( stats.percTotalCoverage )#">#round( stats.percTotalCoverage*100 )#%</span></h2>

<cfquery name="qryCoverageDataSorted" dbtype="query">
	SELECT filePath, relativeFilePath, numLines, numCoveredLines, numExecutableLines, percCoverage
	from qryCoverageData
	order by percCoverage
</cfquery>

	<table border="1">
		<tr>
			<td>Path</td>
			<td>Coverage</td>
		</tr>
		<cfloop query="qryCoverageDataSorted">
		<tr>
			<td>#relativeFilePath#</td>
			<td bgcolor="#percentToColor( percCoverage )#">#round( percCoverage*100 )#%</td>
		</tr>
		</cfloop>
	</table>
	
</cfoutput>

<cfscript>
	// visually reward or shame the user
	// TODO: add more variations of color
	function percentToColor( required number percentage ) {
		percentage = round( percentage*100 );
		if( percentage >=85 ) {
			return 'green';
		} else if( percentage >=50 ) {
			return 'orange';
		} else {
			return 'red';
		}
	}
</cfscript>