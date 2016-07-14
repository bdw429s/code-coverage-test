<!--- 
	test
	comment
--->
<cfcomponent>

	<!---
	 test
	 comment
	--->
	<cffunction name="iGetCalled">
		<!--- single line comment--->
		<!---  multi
			line
			comment --->
		
		<cfset var variableDeclaration = 'foo'>
		<cfif true >
			<cfset var firstHalf = 0>
		<cfelse>
			var firstHalf = 0>			
		</cfif>
		<cfset anotherMethodCall()>
		<cfreturn>
	</cffunction>


	<!---
	 test
	 comment
	--->
	<cffunction name="iDoNotGetCalled">
		<cfset var variableDeclaration = 'foo'>
		<cfreturn false>
	</cffunction>

	<!---
	 test
	 comment
	--->
	<cffunction name="anotherMethodCall">
		<cfset var result = [
			'a',
			'b',
			'c',
			'd'
		]>
		<cfreturn result>
	</cffunction>
		
</cfcomponent>