<cfcomponent displayname="UserService" output="no" hint="Service facade for the User functions">
<cfsilent>
<!----
==========================================================================================================
Filename:     UserService.cfc
Description:  Service facade for the User functions for AFP Cms 3.5
Date:         19/1/2008
Author:       Michael Kear

Revision history: 

==========================================================================================================
--->
</cfsilent>
     
<cffunction name="IsLoggedIn" access="public" returntype="boolean" output="false" hint="Returns true if the user is logged in,  false if not.">
	 <cfset var UserIsLoggedIn = false />
	 <cfscript>
		UserIsLoggedIn =  session.User.getIsLoggedIn();
	 </cfscript>
	<cfreturn UserIsLoggedIn />	 
</cffunction>

<cffunction name="getUser" access="public" returntype="User" output="false" hint="Collects the current user's user bean from the session scope and returns it">
	<cfreturn session.User />
</cffunction>

	
</cfcomponent>