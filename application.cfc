<cfcomponent name="Application" displayname="Application Component." hint="Main application file">
    <cfsilent>
    <!----
    ==========================================================================================================
    Filename:     application.cfc
    Client:       Bluegrass Today Top 20 Public Site
    Description:  Main application file
    Date:         2/Jan/2023, 11:50AM
    Author:       Michael Kear, AFP Webworks
    
    Revision history: 
  
    ==========================================================================================================
    --->
    
    <cfsetting showdebugoutput="no" />
        <!----[  Set up basic application settings, cross-version  ]---->
        <cfset this.name = "BT20 1.0-0000001">
        <cfset this.applicationTimeout = CreateTimeSpan(0,1,0,0)>
        <cfset this.sessionManagement = true>
        <cfset this.sessionTimeout = CreateTimeSpan(0,1,0,0)>
        <cfset this.clientManagement = true>
        <cfset this.clientStorage = "cookie">
        <cfset this.loginStorage = "session">
        <cfset this.setClientCookies = true>
        <cfset this.setDomainCookies = false>
        <cfset this.scriptProtect = false>
        
    <!----[     Determine the site version:   ]----MK ----> 
        
    <cfif cgi.HTTP_HOST contains "bttop20.com">
        <cfset this.siteVersion = "production">
    <cfelseif cgi.HTTP_HOST eq "http://127.0.0.1:59628/">
        <cfset this.siteVersion = "development">
    <cfelse>    
        <cfset this.siteVersion = "development">
    </cfif>	
     
    
           
    <!----[  
    ============================================================================================================
    Application start and end
    ============================================================================================================
     ]---->
    
        <cffunction name="onApplicationStart" returntype="boolean" output="true">
            <cfscript>
                Application.siteVersion = this.siteVersion;
                application.BeanFactory = createObject("component","coldspring.beans.DefaultXmlBeanFactory").init();
                application.BeanFactory.loadBeansFromXmlFile(expandPath("/core/config/Coldspring.xml"),true) ;
                application.beanfactory.getbean("configbean") ;    
               /*  //application.jarPath = ExpandPath( "/core/jars/" ); */                  
            </cfscript>
           
       <cfreturn true>
        </cffunction>
        
        <cffunction name="onApplicationEnd" returnType="void" output="false">
            
        </cffunction>
            
    
    <!----[  
    ============================================================================================================
    Session start and end
    ============================================================================================================
     ]---->	
     
         <cffunction name="onSessionStart" returnType="void" output="true">
            <!----[  Set up the default login bean for the guest user  ]---->
             <cfscript>
                session.User = application.beanfactory.getBean("User");	
                // temporary set user to be mkear so login isnt necessary all the time . 
                session.user.setuserid('2');	
                session.user.setuserFirstName('Mike');		
                session.user.setuserLastName('Kear');	
                //session.user = application.beanfactory.getbean("UserAccess").loginuser( 'mkear', 'k108w344', session.user );
            </cfscript>  
        </cffunction>
    
         <cffunction name="onSessionEnd" returnType="void" output="false">
            <cfargument name="sessionScope" type="struct" required="true">
            <cfargument name="appScope" type="struct" required="false">
            <cfset var dur = dateDiff("n", arguments.sessionScope.startup, now())>
            <!----Kill the cookies and CFID/CFTOKEN ---->
                  <cfcookie name="CFID"  expires="NOW">
                  <cfcookie name="CFTOKEN" expires="NOW">
            
        </cffunction>
        
     
         
    <!----[  
    ============================================================================================================
    Request start and end
    ============================================================================================================
     ]---->	
     
     
         <cffunction name="onRequestStart" returnType="boolean" output="true">
            <cfargument type="string" name="targetPage" required=true>
            <cfsetting showdebugoutput="no" />
                  
        
                    <!--- RENEW APPLICATION VARIABLES --->
            <cfif structKeyExists(URL, "reset") AND URL.reset IS "yes">
                   <cfset applicationstop() />
                   <cfset this.onApplicationStart() />
                   <!----[  <cfset this.onSessionEnd() />  ]----MK ---->
                   <cfset this.onSessionStart() /> 
            </cfif>
            <cfset request.austime = now() />
    
     
             
            <cfreturn true>
        </cffunction>
    
        
            
        <cffunction name="onRequestEnd" returntype="void" output="true">
            <cfargument name="targetPage" required="true">
        </cffunction>
        
        <!--- Begin OnRequest Method - Executes during the page request --->
    <cffunction name="onRequest" returnType="void">
        <cfargument name="thePage" type="string" required="true">
        <cfinclude template="#arguments.thePage#">
    
    </cffunction>
    
    
    
     
         
    <!----[  
    ============================================================================================================
    OnError method 
    ============================================================================================================
     ]---->	
     
     <cffunction name="onError" returnType="void" output="true">
            <cfargument name="Exception" required="true">
            <cfargument name="EventName" required="true">		
            <!----[  <cfset var errMsg = Application.utils.exceptions.GetExceptionMessage(arguments.Exception)>  ]----MK ---->
            <!--- <cfset Application.utils.exceptions.SendExceptionEmail(this.name, arguments.Exception)> --->
    
    
       <!--- The onError method gets two arguments:
                An exception structure, which is identical to a cfcatch variable.
                The name of the Application.cfc method, if any, in which the error
                happened.
        <cfargument name="Except" required=true/>
        <cfargument type="String" name = "EventName" required=true/>
        <!--- Log all errors in an application-specific log file. --->
        <cflog file="#This.Name#" type="error" text="Event Name: #Eventname#" >
        <cflog file="#This.Name#" type="error" text="Message: #except.message#">
        <!--- Throw validation errors to ColdFusion for handling. --->
        <cfif Find("coldfusion.filter.FormValidationException",
                         Arguments.Except.StackTrace)>
            <cfthrow object="#except#">
        <cfelse>
            <!--- You can replace this cfoutput tag with application-specific 
                    error-handling code. --->
            <cfoutput>
                <p>Error Event: #EventName#</p>
                <p>Error details:<br>
                <cfdump var=#except#></p>	
            </cfoutput>
        </cfif> ---->
        
    
            <h2>An error has occurred...</h2>
            <p>
            <cfdump var="#Exception#">
            </p>
        </cffunction> 
        
    
    <cffunction name="isLoggedIn" access="public">
            <cfreturn session.userbean.getIsloggedin() neq "No" />
    </cffunction> 
    
    </cfsilent>	
    </cfcomponent>
    