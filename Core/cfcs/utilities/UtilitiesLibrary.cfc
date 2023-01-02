<cfcomponent hint="Library of common routines">

<!--- Constructor --->
<cffunction name="init" access="Public" returntype="UtilitiesLibrary" output="false" hint="Initialises the controller">
<cfargument name="argsConfiguration" required="true" type="any" />
	<cfset var config  = arguments.argsConfiguration />
	<cfset variables.dsn = config.getDSN() />
	<cfset variables.austime = config.getAusTime() />
	<cfreturn this />
</cffunction>

  <cffunction name="IsEmail" access="public" returntype="boolean" hint="Tests to see if a string is an email address or not.">
<!-----[   * Tests passed value to see if it is a valid e-mail address (supports subdomain nesting and new top-level domains).
 * Update by David Kearns to support '
 * SBrown@xacting.com pointing out regex still wasn't accepting ' correctly.
 * 
 * @param str 	 The string to check. (Required)
 * @return Returns a boolean. 
 * @author Jeff Guillaume (jeff@kazoomis.com) 
 * @version 2, August 15, 2002  ]-----> 
 
    <cfargument name="Email" type="string" required="true">
    <cfset var Result = false>
    <cfif (REFindNoCase("^['_a-z0-9-]+(\.['_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*\.(([a-z]{2,3})|(aero|coop|info|museum|name))$",arguments.Email))>
      <CFSET result=true>
    </cfif>
    <cfreturn result>
  </cffunction>
  
  <cffunction name="SafeEmail" output="false" returntype="string" access="public" hint="Returns an email formatted to be safe from spam-spiders">
<cfargument name="emailaddress" required="yes" type="string" />
<cfargument name="mailto" required="no" type="boolean" default="no" />
<cfscript>
    var i = 1;
	var antiSpam = "";
	for (i=1; i LTE len(EmailAddress); i=i+1) {
		antiSpam = antiSpam & "&##" & asc(mid(EmailAddress,i,1)) & ";";
	}
	if ((ArrayLen(Arguments) eq 2) AND (Arguments[2] is "Yes")) return "<a href=" & "mailto:" & antiSpam & ">" & antiSpam & "</a>"; 
	else return antiSpam;
</cfscript>

<!-----[  /**
 * When given an email address this function will return the address in a format safe from email harvesters.
 * Minor edit by Rob Brooks-Bilson (rbils@amkor.com)
 * Update now converts all characters in the email address to unicode, not just the @ symbol. (by author)
 * 
 * @param EmailAddress 	 Email address you want to make safe. (Required)
 * @param Mailto 	 Boolean (Yes/No). Indicates whether to return formatted email address as a mailto link.  Default is No. (Optional)
 * @return Returns a string 
 * @author Seth Duffey (sduffey@ci.davis.ca.us) 
 * @version 2, May 2, 2002 
 */  ]----->
 
<cfreturn antispam />
</cffunction>
  
  <cffunction name="cleanstory" access="public" returntype="string" output="false" hint="Cleans up the content of a story, removing surplus tags, paragraph markers etc">
		<cfargument name="story" type="string" required="true">
		
		<cfscript>
			story =  arguments.story;
			story =   REReplaceNoCase(story,"<font[^>]*>","","ALL");
			story =   REReplaceNoCase(story,"</font[^>]*>","","ALL");
			story =   replace(story, "</div><div>", "<br /><br />", "ALL");
			story =   replace(story, "</DIV><DIV>", "<br /><br />", "ALL");
			story =   replace(story, "</div> <div>", "<br /><br />", "ALL");
            story =   replace(story, "</DIV> <DIV>", "<br /><br />", "ALL");
			story =   replace(story, "<div>", "", "ALL");
			story =   replace(story, "<DIV>", "", "ALL");
			story =   replace(story, "</div>", "", "ALL");
			story =   replace(story, "</DIV>", "", "ALL");
			story =   replace(story, "<p>", "", "ONE");
			story =   replace(story, "<P>", "", "ONE");
			story =   reverse(replace(reverse(story), "</p>", "", "ONE"));
			story =   reverse(replace(reverse(story), "</P>", "", "ONE"));
		</cfscript>
		<cfreturn story>
	</cffunction>
	
  
  <cffunction name="capFirstTitle" access="public" returntype="string" hint="Converts a text string to Title Caps and lower case">
    <cfargument name="inputString" type="string" required="true" />
    <cfset var Result = false>
    <cfset var initText = "#arguments.inputString#">
    <cfscript>
		var Words = "";
		var j = 1; var m = 1;
		var doCap = "";
		var thisWord = "";
		var excludeWords = ArrayNew(1);
		var outputString = "";
		
		initText = LCASE(initText);
		
		//Words to never capitalize
		excludeWords[1] = "an";
		excludeWords[2] = "the";
		excludeWords[3] = "at";
		excludeWords[4] = "by";
		excludeWords[5] = "for";
		excludeWords[6] = "of";
		excludeWords[7] = "in";
		excludeWords[8] = "up";
		excludeWords[9] = "on";
		excludeWords[10] = "to";
		excludeWords[11] = "and";
		excludeWords[12] = "as";
		excludeWords[13] = "but";
		excludeWords[14] = "if";
		excludeWords[15] = "or";
		excludeWords[16] = "nor";
		excludeWords[17] = "a";
	
		//Make each word in text an array variable
		Words = ListToArray(initText, " ");
		//Check words against exclude list
		for(j=1; j LTE (ArrayLen(Words)); j = j+1){
			doCap = true;
			//Word must be less that four characters to be in the list of excluded words
			if(LEN(Words[j]) LT 4 ){
				if(ListFind(ArrayToList(excludeWords,","),Words[j])){
					doCap = false;
				}
			}
			//Capitalize hyphenated words		
			if(ListLen(Words[j],"-") GT 1){
				for(m=2; m LTE ListLen(Words[j], "-"); m=m+1){
					thisWord = ListGetAt(Words[j], m, "-");
					thisWord = UCase(Mid(thisWord,1, 1)) & Mid(thisWord,2, LEN(thisWord)-1);
					Words[j] = ListSetAt(Words[j], m, thisWord, "-");
				}
			}
			//Automatically capitalize first and last words
			if(j eq 1 or j eq ArrayLen(Words)){
				doCap = true;
			}
			//Capitalize qualifying words
			if(doCap){
				Words[j] = UCase(Mid(Words[j],1, 1)) & Mid(Words[j],2, LEN(Words[j])-1);
			}
		}
		outputString = ArrayToList(Words, " ");
		return outputString;
		</cfscript>
    <cfreturn outputString>
  </cffunction>
  
  <cffunction name="IsSQLInject" access="public" returntype="string" hint=" Tests a string, one-dimensional array, or simple struct for possible SQL injection">
		<cfargument name="inputString" type="string" required="true" />
		<cfset var Result = false>
		<cfset var initText = "#arguments.inputString#">
			<cfscript>
				var listSQLInject = "select,insert,update,delete,drop,--,'";
				var arraySQLInject = ListToArray(listSQLInject);
				var i = 1;
				
				for(i=1; i lte arrayLen(arraySQLInject); i=i+1) {
					if(findNoCase(arraySQLInject[i], initText)) return true;
				}
				
				return false;
		</cfscript>
</cffunction>

<cffunction name="StripHTML" access="public" returntype="string" hint="Removes HTML from the string.">
		<cfargument name="inputString" type="string" required="true" />
		<cfset var Result = false>
		<cfset var initText = "#arguments.inputString#">
			<cfscript>
			return REReplaceNoCase(initText,"<[^>]*>","","ALL");
			</cfscript>
</cffunction>


<cffunction name="FullLeft" access="public" returntype="string" output="false" hint="Returns the leftmost characters of a string but without cutting words up.">
	<cfargument name="InputString" required="yes" type="string" />
	<cfargument name="Count" required="yes" type="numeric" default="250" />
	<cfset var str = "#arguments.InputString#">
	<cfscript>
	/**
	 * An enhanced version of left() that doesn't cut words off in the middle.
	 * Minor edits by Rob Brooks-Bilson (rbils@amkor.com) and Raymond Camden (ray@camdenfamily.com)
	 * 
	 * Updates for version 2 include fixes where count was very short, and when count+1 was a space. Done by RCamden.
	 * 
	 * @param str 	 String to be checked. 
	 * @param count 	 Number of characters from the left to return. 
	 * @return Returns a string. 
	 * @author Marc Esher (jonnycattt@aol.com) 
	 * @version 2, April 16, 2002 
	 */
		if (not refind("[[:space:]]", str) or (count gte len(str)))
			return Left(str, count);
		else if(reFind("[[:space:]]",mid(str,count+1,1))) {
			return left(str,count);
		} else { 
			if(count-refind("[[:space:]]", reverse(mid(str,1,count)))) return Left(str, (count-refind("[[:space:]]", reverse(mid(str,1,count))))); 
			else return(left(str,1));
		}
	
	</cfscript>
<cfreturn str />
</cffunction>

<cffunction name="GetCountries" output="false" returntype="query" access="public" hint="Returns a list of countries for drop down list">
<cfquery name="QGetCountries" datasource="#variables.dsn#">
SELECT CountryName as Country, a3 as CountryABR FROM Countries order by Countryname
</cfquery>

<cfreturn QGetCountries />
</cffunction>

<cffunction name="GetStates" output="false" returntype="query" access="public" hint="Returns a list of states for drop down list">
<cfquery name="QGetStates" datasource="#variables.dsn#">
SELECT StateName as State FROM States order by SortCode
</cfquery>
<cfreturn QGetStates />
</cffunction>


<cffunction name="checkdate" access="public" returntype="boolean" output="false" hint="Checks to see if a year,month and day is a valid date" >
	<cfargument name="month" required="yes" default="1" type="numeric">
	<cfargument name="day" required="yes" default="1" type="numeric">
	<cfargument name="year" required="yes" default="2005" type="numeric">
		<cfset result="0" >
		<cfset testdate = #arguments.month#  & "/" &  #arguments.Day#  & "/" & #arguments.year# >
		<cfset result  = #isdate(testdate)#>
	<cfreturn result>
</cffunction>

<cffunction name="stripNonAlphaNum" access="public" output="false" returntype="string" hint="Strips all spaces, punctuation from the given string">
	<cfargument name="inputstring" required="yes" type="string" />
		<cfset var outputstring = "" />
		<cfscript>
			outputstring = REReplaceNoCase(arguments.inputstring,"\W","","ALL");
		</cfscript>
	<cfreturn outputstring />
</cffunction>

<cffunction name="parseDate" access="public" output="no" returntype="date" hint="Parses a date of the form dd/mm/yyyy into a CF date object">
	<cfargument name="argsInputdate" type="string" required="yes" />
    <cfset inputdate = arguments.argsInputdate />
   <cfscript> 
    //Location of the first '/' character.  ]----MK ---->
	firstslash = listfind(inputdate, '/' );
	day = listfirst(inputdate, '/' );
	year = listlast(inputdate, '/');
	month = ListGetAt(inputdate, 2, '/' );
	Outputdate = createdate(year, month, day ) ; 
   </cfscript>
   <cfreturn outputdate />
       
</cffunction>

<cffunction name="parseDateTime" access="public" output="no" returntype="date" hint="Parses a date of the form dd/mm/yyyy into a CF date object">
	<cfargument name="argsInputdate" type="string" required="yes" />
    <cfargument name="argsInputTime" type="string" default="00:00" />
    <cfset inputdate = arguments.argsInputdate />
    <cfset inputtime = arguments.argsInputTime />
   <cfscript> 
    //Location of the first '/' character.  ]----MK ---->
	firstslash = listfind(inputdate, '/' );
	day = listfirst(inputdate, '/' );
	year = listlast(inputdate, '/');
	month = ListGetAt(inputdate, 2, '/' );
	hour = listfirst(inputtime, ':');
	minute = listlast( inputtime, ':');
	Outputdate = createdatetime(year, month, day, hour, minute, '00' ) ; 
   </cfscript>
   <cfreturn outputdate />
       
</cffunction>


<cffunction name="getRandomImage" access="public" output="false" returntype="string" hint="Takes a list of imagesnames, and returns a random image name">
<cfargument name="ImageList" required="yes" type="string" />
	<cfset var imagetouse = "" />
	<!----[  Now we can pick a random id from the list with the RandRange function.  ]---->
	<cfset RandomImageID = RandRange(1,ListLen(arguments.imagelist))>
	<!----[  Now select the image from the list based on the random position  ]---->
	<cfset ImageToUse = ListGetAt(Imagelist,RandomImageID) />
	<cfif (right(ImageToUse,"4") eq ".gif") or (right(ImageToUse,"4") eq ".jpg") or (right(ImageToUse,"4") eq ".png")>
		<cfreturn ImageToUse />
	<cfelse>
		<cfreturn "HeaderImage.gif" />
	</cfif>

</cffunction>




</cfcomponent>