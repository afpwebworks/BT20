<cfcomponent output="false" hint="
<pre>
DEVELOPER NOTES:

*******************************************************************************************************
This component is a CFC implementation of Jacob Munson's cffpVerify.cfm (part of CFFormProtect) written 
by Dave Shuck dshuck@gmail.com.  All calculations/algorithms are a direct port of Jacob's original code,
with exceptions noted in the NOTES section below.
*******************************************************************************************************

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
TEMPLATE    : cffpVerify.cfc

CREATED     : 23 Mar 2007

USAGE       : Perform various tests on a form submission to ensure that a human submitted it.

DEPENDANCY  : NONE

NOTES       : Dave Shuck - created 
			  Dave Shuck - 23 Mar 2007 - Added testTooManyUrls() method and call to the method in testSubmission()
			  Dave Shuck - 23 Mar 2007 - Removed the '0' padding in FormTime in testTimedSubmission() which was causing
			  								consistent failure on that test
			  Dave Shuck - 24 Mar 2007 - Added logFailure() method and the call to the method in testSubmission().  This
			  								code is still backwards compatable with older ini files that do not make use of
			  								the properties 'logFailedTests' and 'logFile'
			  Dave Shuck - 26 Mar 2007 - Altered the FormTime in testTimedSubmission() to use NumberFormat as the previous
			  								change caused exceptions before 10:00am.  (see comments in method)	
			  Mary Jo Sminkey - 18 July 2007 - Added new function 'testSpamStrings' which allows the user to configure a list
			  									of text strings to test the form against. Similar to using Akismet but with no
			  									cost involved for commercial use and can be configured as needed for the spam 
			  									received. Update Akismet function to log to same file and not log as passed if 
			  									the key validation failed.	
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
11/2/2008 - Mike Kear
	This CFC is a modified version of Dave Shuck's cffpVerify.cfc.  Mods as follows:
		<a> Component modified to take configuration from XML file instead of .ini file, so getProfileString() is not needed. (disabled in shared hosting)
		<b> Added new tests
</pre>
">

<cffunction name="init" access="Public" returntype="FormProtect" output="false" hint="Initialises the controller">
	<cfargument name="argsConfiguration" required="true" type="any" />
	<cfargument name="argsConfigXMLname" required="false" default="#ExpandPath("/cfformprotect")#" type="string" />
	<cfset var config  = arguments.argsConfiguration />
	<cfset variables.dsn = config.getDSN() />
	<cfset variables.bansdsn = config.getBansDSN() />
	
	<!---[   <cffile action="read" 
				file="#expandPath(arguments.argsConfigXMLname)#"	 
				variable="rawconfigXML"/>
		<cfset configXML = xmlparse(rawconfigXML) />	   ]---->
	
	<cfreturn this />
</cffunction>

<cffunction name="Test" access="public" returntype="boolean" output="no" hint="Master test method - assigns the various tests to the fields, and returns a boolean true if ok to proceed or false if the submission fails.">
	<cfargument name="argsFormfields" type="struct" required="yes" />
	<cfargument name="argsCGIVars" type="struct" required="yes" />
	<cfset var formfield = arguments.argsFormfields />
	<cfset var cgivars = arguments.argsCGIVars />
	<cfset var SubmissionOK = true />
	<!----[  if any test returns false, set result = false   ]---->
	
	<!----[  First check to see the user isnt already banned. IF so we dont want to hear from them.  ]---->
	<cfif testAlreadyBanned(cgivars.REMOTE_ADDR)>
		<cfset SubmissionOK = false />
	<cfelse>
		<!----[   do other tests  ]---->
		<cfif testmessage( formfield.message ) eq false ><cfset SubmissionOK = false /></cfif>
	</cfif>
	<cfreturn SubmissionOK />
</cffunction>

<cffunction name="testAlreadyBanned" access="public" output="no" returntype="boolean" hint="Tests to see if a user is already on the list of banned IPs">
	<cfargument name="argsAuthorsIP" type="string" required="yes" />
	<cfset var authorsIP = arguments.argsAuthorsIP />
	<cfset var banned = false />

	<cfquery name="qCheckIP" datasource="#variables.bansdsn#">
	SELECT AuthorsIP from guestbookbans where AuthorsIP = <cfqueryparam value="#authorsIP#" />
	</cfquery>
	<cfif qCheckIP.recordcount>
		<cfset banned = true />
	</cfif>
	<cfreturn banned />	
</cffunction>

<cffunction name="AddtoBans" access="public" output="no" returntype="void" hint="adds the ip address of the submitter to the banned ip table.">
	<cfargument name="argsAuthorsIP" type="string" required="yes" />
	<cfset var authorsIP = arguments.argsAuthorsIP />
	<cfquery name="qInsertIP" datasource="#variables.bansdsn#">
		INSERT into guestbookbans(AuthorsIP) VALUES (<cfqueryparam value="#authorsIP#" cfsqltype="cf_sql_varchar" /> )
	</cfquery>

</cffunction>

<cffunction name="testmessage" access="public" output="no" returntype="boolean" hint="tests a string against a series of tests to check for spam content">
<cfargument name="argsMessage" type="string" required="yes" />
<cfset var message = arguments.argsMessage />
<cfset var result = true />

	<cfif (message contains "<a href=") 
		OR ( message contains "[url=" ) 
		OR (   message contains "[link=" ) 
		OR (   message contains "??" )>
               
		<cfset result = false />
	</cfif>	 
	<cfif  testForSpamOK( message ) is false >
		<cfset result = false />		
	</cfif>
<cfreturn result />
</cffunction>

<cffunction name="testForSpamOK" access="public" output="false" returntype="boolean" hint="Tests a string for certain spam characters. ">
	<cfargument name="argsInputString" required="true" type="string" >
	<cfset var InputString = arguments.argsInputString />
	<cfset var resultOK = true />
	
	<cfif ( listlen(InputString, "|") GT "2" ) >
		<cfset resultOK = false>		
	</cfif>
	<cfreturn resultOK />
</cffunction>

</cfcomponent>

