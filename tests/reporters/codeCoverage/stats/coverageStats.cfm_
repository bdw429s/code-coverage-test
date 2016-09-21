<!--- 
	Template for outputting overview stats about the line coverage details that were captured.
 --->
<cfoutput>
	<cfif isDefined( 'stats' )>
		<ul>
			<li><strong>Total Files Processed:</strong> #stats.numFiles#</li>
			<li><strong>Total project coverage:</strong> #round( stats.percTotalCoverage*100 )#%</li>
			<li>
				<strong>Files with best coverage:</strong>
				<ol>
					<cfoutput query="stats.qryFilesBestCoverage">
						<li>#filePath# - #round( percCoverage*100 )#%</li>
					</cfoutput>
				</ol>
			</li>
			<li>
				<strong>Files with worst coverage:</strong>
				<ol>
					<cfoutput query="stats.qryFilesWorstCoverage">
						<li>#filePath# - #round( percCoverage*100 )#%</li>
					</cfoutput>
				</ol>
			</li>		
		</ul>
	</cfif>
</cfoutput>