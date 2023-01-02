<cfcomponent displayname="mailer" output="false" hint="Provides email functionality.">
<cfsilent>
<!----
==========================================================================================================
Filename:     mailer.cfc
Description:  Feedback mail handler for AFPcms 3.0
Date:         18/2/2006
Author:       Michael Kear

Notes:   Requires content to exist, in a query called ContentList

Revision history: 

==========================================================================================================
--->
</cfsilent>
<!--- Constructor --->
<cffunction name="init" access="Public" returntype="any" output="false" hint="Initialises the controller">
    <cfargument name="argsConfiguration" required="true" type="any" />
    		<cfset variables.config  = arguments.argsConfiguration />
			<cfset variables.dsn = variables.config.getDSN() />	
			<cfset variables.webmasteremail = variables.config.getwebmasteremail() /> 
			<cfset variables.sitename = variables.config.getsitename() />	
			<cfset variables.sitemailindex = variables.config.getsitemailindex() />	
            <cfset variables.mailserver = variables.config.getmailserver() />	
			<cfset variables.mailuser = variables.config.getmailuser() />	
			<cfset variables.mailpassword = variables.config.getmailpassword() />	
			<cfset variables.austime = variables.config.getAusTime() />
		<cfreturn this />
</cffunction>


<cffunction name="sendGenericEmail" returntype="void" access="public" output="false" hint="Sends an email to the Webmaster.">
	<cfargument name="form" type="struct" required="yes" />
    <cfargument name="cgi" type="struct" required="no" />
	<cfset var subject = "Email from #variables.sitename#" />
	<cfset var Name = "" />
	<cfset var Phone = "" />
	<cfset var Message = "" />
	<cfset var Header =  "" />
	<cfset var emailto = "" />
	<cfset var EmailFrom = arguments.form.EmailFrom />
    <cfset var remoteaddress = "" />
    
    <cfif structKeyExists(arguments, "cgi" )>
    	<cfset  remoteaddress =  arguments.cgi.REMOTE_ADDR  />
    </cfif>
    
    	
	<cfif structKeyExists(arguments.form, "emailto")>
		<cfset emailto = GetEmailAddress(arguments.form.emailto) />
	</cfif>
	<cfif structKeyExists(arguments.form, "emailtoUserID")>
		<cfset emailto = GetEmailAddress(arguments.form.emailtoUserID) />
	</cfif>
	<cfif isdefined("arguments.form.message")>
		<cfset message = arguments.form.message />
	</cfif>
	
	<cfif isdefined("arguments.form.subject")>
		<cfset subject = variables.sitemailindex & " " & arguments.form.subject />
	</cfif>
	<cfif isdefined("arguments.form.Name")>
		<cfset Name = arguments.form.Name />
	</cfif>
	<cfif isdefined("arguments.form.Phone")>
		<cfset Phone = arguments.form.Phone />
	</cfif>
	<cfset Header = Header & "At " & #lcase(timeformat(variables.austime, "hh:mmtt"))# & " on " & #dateformat(variables.austime, "d/mmm/yyyy")# & ", the following message was sent from the " & 	#variables.sitename# & " web site: "  /> 
		
<cfmail from="#EmailFrom#" to="#emailto#" replyto="#EmailFrom#" subject="#subject#" server="#variables.mailserver#" username="#variables.mailuser#" password="#variables.mailpassword#">
#Header#
Name: #name#
Email: #EmailFrom#
=====================================================================================
#message#

=====================================================================================
<cfif len(remoteaddress) GT 2 >Sent from #remoteaddress#</cfif> 
</cfmail>
</cffunction>

<cffunction name="SendUserEmail" access="public" output="false" returntype="void" hint="Sends a thank you to the user">
<cfargument name="form" type="struct" required="yes" />
	<cfset var subject = "Email from #variables.sitename#" />
	<cfset var Name = "" />
	<cfset var Phone = "" />
	<cfset var Message = "" />
	<cfset var Header =  "" />
	<cfset var emailto = "" />
	<cfset var EmailFrom = arguments.form.EmailFrom />
	
	<cfif structKeyExists(arguments.form, "emailto") >
		<cfset emailto = GetEmailAddress(arguments.form.mailto) />
	</cfif>
	<cfif structKeyExists(arguments.form, "emailtoUserID")>
		<cfset emailto = GetEmailAddress(arguments.form.emailtoUserID) />
	</cfif>
	
	<cfif isdefined("arguments.form.message")>
		<cfset message = arguments.form.message />
	</cfif>
	
	<cfif isdefined("arguments.form.subject")>
		<cfset subject = variables.sitemailindex & " " & arguments.form.subject />
	</cfif>
	<cfif isdefined("arguments.form.Name")>
		<cfset Name = arguments.form.Name />
	</cfif>
	<cfif isdefined("arguments.form.Phone")>
		<cfset Phone = arguments.form.Phone />
	</cfif>
	<cfset Header = Header & "Thank you for coming to the " & 	#variables.sitename# & " web site and sending a message.   Your message has been forwarded and no doubt will be replied to in due course.  You message was timed at " & #lcase(timeformat(variables.austime, "hh:mmtt"))# & " on " & #dateformat(variables.austime, "d/mmm/yyyy")# & ", and for your records, your message was as follows: "  /> 
		
<cfmail from="#emailto#" to="#emailfrom#" replyto="#emailto#" subject="#subject#" server="#variables.mailserver#" username="#variables.mailuser#" password="#variables.mailpassword#">
#Header#
=====================================================================================
#message#</cfmail>
</cffunction>

<cffunction name="GetEmailAddress" access="public" output="false" returntype="string" hint="Looks up the user's email address from the User table, given the UserID" >
<cfargument name="UserID" type="string" required="yes"  />
<cfset var UserEmail = "" />
<cfset var qUserEmail = 0 />
	<cfquery name="qUserEmail" datasource="#variables.dsn#">
		Select UserEmail from Users where Userid = <cfqueryparam value="#arguments.UserID#" cfsqltype="cf_sql_integer" />
	</cfquery>

	<cfif qUserEmail.recordcount GT 0 >
		<cfreturn valuelist(qUseremail.UserEMail) />
	</cfif>
</cffunction>

<cffunction name="sendNoticeboardEmail" returntype="void" access="public" output="false" hint="Sends an email to the noticeboard administrator.">
	<cfargument name="form" type="struct" required="yes" />
	<cfset var subject = "" />
	<cfset var Name = "" />
	<cfset var Phone = "" />
	<cfset var Message = "" />
	<cfset var Header =  "" />
	<cfset var emailto = "" />
	<cfset var EmailFrom = trim(arguments.form.EmailFrom) />
    <cfset var EventDate = "" />
    <cfset var ContactPhone = "" />
    <cfset var EventName = "" />
    <cfset var EventLocation = "" /> 
    
  	
	<cfif structKeyExists(arguments.form, "emailto")>
		<cfset emailto = GetEmailAddress(arguments.form.emailto) />
	</cfif>
	<cfif structKeyExists(arguments.form, "emailtoUserID")>
		<cfset emailto = GetEmailAddress(arguments.form.emailtoUserID) />
	</cfif>
	<cfif isdefined("arguments.form.message")>
		<cfset message = trim(arguments.form.message) />
	</cfif>
	
	<cfif isdefined("arguments.form.subject")>
		<cfset subject = variables.sitemailindex & " " & trim(arguments.form.subject) />
	</cfif>
	<cfif isdefined("arguments.form.Name")>
		<cfset Name = trim(arguments.form.Name) />
	</cfif>
	<cfif isdefined("arguments.form.Phone")>
		<cfset Phone = trim(arguments.form.Phone) />
	</cfif>
	<cfset Header = Header & "At " & #lcase(timeformat(variables.austime, "hh:mmtt"))# & " on " & #dateformat(variables.austime, "d/mmm/yyyy")# & ", the following message was sent from the " & 	#variables.sitename# & " web site for the community noticeboard: "  /> 
<cfmail from="#trim(EmailFrom)#" to="#emailto#" replyto="#trim(EmailFrom)#" cc="#application.webmasteremail#" subject="#subject#" server="#variables.mailserver#" username="#variables.mailuser#" password="#variables.mailpassword#">	
#Header#
=====================================================================================
Event name: #trim(arguments.form.EventName)#		
Event Date: #trim(arguments.form.EventDate)#
Contact Phone Number: #trim(arguments.form.ContactPhone)#
Event Location: #trim(arguments.form.EventLocation)#
Event description: #trim(arguments.form.Message)#
</cfmail>
</cffunction>



</cfcomponent>
