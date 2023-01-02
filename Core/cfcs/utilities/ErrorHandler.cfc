<cfcomponent displayname="ErrorHandler" output="false" hint="A collection of property validation errors">
<cfsilent>
<!----
==========================================================================================================
Filename:     ErrorHandler.cfc
Description:  Error Handler for validation errors
Date:         22/2/2007
Author:       Michael Kear
Reference:   With help from  Peter J Farrell http://blog.maestropublishing.com

Revision history: 

==========================================================================================================
--->
</cfsilent>
<cffunction name="Init" returntype="ErrorHandler" access="public" output="false" hint="I build a new Errors Collection.">
  <cfset variables.instance.errors = structNew() />
  <cfreturn this />
</cffunction>

<cffunction name="setError" returntype="void" access="public" output="false" hint="Adds to the Error collection.">
  <cfargument name="PropertyName" type="string" required="true" hint="I am the property in an error state.">
  <cfargument name="ErrorMessage" type="any" required="true" hint="I am a friendly error message - I can also be complex.">
	  <cfif not structKeyExists(variables.instance.errors, arguments.PropertyName)>
		<cfset variables.instance.errors[arguments.PropertyName] = arrayNew(1) />
	  </cfif>  
  <cfset arrayAppend(variables.instance.errors[arguments.PropertyName], arguments.ErrorMessage) />
</cffunction>


<cffunction name="GetErrors" returntype="struct" access="public" output="false" hint="I get the Error collection.">
  <cfreturn variables.instance.Errors />
</cffunction>

<cffunction name="HasErrors" returntype="boolean" access="public" output="false" hint="I let you know if there are errors.">
  <cfargument name="PropertyName" type="string" required="false" default="" hint="You can check for errors on a specific property by passing me.">

  <cfif len(arguments.propertyName)>
    <cfif StructKeyExists(variables.instance.errors, arguments.propertyName) AND arrayLen(variables.instance.errors[arguments.propertyName]) gt 0>
      <cfreturn true />
    <cfelse>
      <cfreturn false />
    </cfif>
  <cfelse>
    <cfif structCount(variables.instance.Errors) gt 0>
      <cfreturn true />
    <cfelse>
      <cfreturn false />
    </cfif>
  </cfif>
</cffunction>

<cffunction name="Merge" returntype="void" access="public" output="false" hint="I merge another collection's errors into this one.">
  <cfargument name="Col" type="ErrorHandler" required="true" hint="I am the collection to merge.">
  
  <cfset var i = "" />
  <cfset var j = "" />
  <cfset var err = col.getErrors() />
  
  <cfloop collection="#err#" item="i">
    <cfloop from="1" to="#arrayLen(err[i])#" index="j">
      <cfset addError(i, err[i][j]) />
    </cfloop>
  </cfloop>
</cffunction>

<cffunction name="MakeErrorDisplay" returntype="string" access="public" output="false" hint="Takes the error struct and converts it to a string with nested unordered list">
<cfargument name="eH" type="ErrorHandler" required="yes" />
<cfset var errorstruct = arguments.eh.geterrors() />
<cfset var errorstring = "<p>There are errors as follows: <ul>" />

<cfloop list="#arraytolist(StructKeyArray(errorstruct))#" index="i"><cfoutput>
<cfset thiserrorarray = #evaluate("errorstruct." & i)# />
<cfset errorstring = errorstring & "<li>" /><!----[   & #i# & ": " />   ]---->
<cfif arraylen(thiserrorarray) eq "1">
	<cfset errorstring = errorstring & #thiserrorarray[1]#  />
<cfelse>
	<cfset errorstring = errorstring & "<ol>" />
	<cfloop list="#arraytolist(thiserrorarray)#" index="j"><cfoutput>
		<cfset errorstring = errorstring & "<li>" & #j# & "</li>" />
	</cfoutput></cfloop>
	<cfset errorstring = errorstring & "</ol>" />
</cfif>
<cfset errorstring = errorstring & "</li>" />
</cfoutput></cfloop>
<cfset errorstring = errorstring & "</ul>" />
<cfreturn errorstring />
</cffunction>
</cfcomponent>