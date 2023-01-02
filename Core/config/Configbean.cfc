<cfcomponent displayname="ConfigBean" output="false"  hint="A configuration bean that reads XML config file and sets the Application scope.">
    <cfsilent>
    <!----
    ================================================================================================================
    Filename:        ConfigBean.cfc
    Description:     A configuration bean that reads XML config file and sets the Application scope.
    Client:          Bluegrass Today Top 20 Public Site
    Author:          Michael Kear, AFP Webworks 
    Date:            02/01/2023, 12:05PM
    ================================================================================================================
    This bean was generated with the following template:
    Bean Name: ConfigBean.cfc
    Extends: false
    Create getSnapshot method: y
    Create validate method: n
    Date Format: DD/MM/YYYY
    
    Global variables:
    PageIncrement | numeric | 7    ; 
    AddNewContentAt| string |    Bottom  ; 
    AddNewPageAt| string |  Top   ; 
    hometimezone| string |   Australia/Sydney  ;
    MonthsBeforeArchive| numeric | 2    ;
    settingsTablename |  string | BT20Settings ;
    
    
    Bean Template Development:
    approotABS  | string |   D:\Sites\Mysites\BT20\BT20   ; 
    cmsrootABS  | string |   D:\Sites\Mysites\BT20\BT20CMS  ; 
    approotURL  | string |  http://127.0.0.1:59628/   ; 
    cmsrootURL  | string |  http://127.0.0.1:59852/   ; 
    sitename   | string |  BT20 Development   ; 
    dsn   | string |   atalkingdog2018  ; 
    bansdsn   | string |  AFPWebworksNet2020   ;
    
    
    Bean Template Production:
    approotABS  | string |   D:\Sites\Mysites\BT20\BT20   ; 
    cmsrootABS  | string |   D:\Sites\Mysites\BT20\BT20CMS  ; 
    approotURL  | string |  http://127.0.0.1:59628/   ; 
    cmsrootURL  | string |  http://127.0.0.1:59852/   ; 
    sitename   | string |  BT20 Development   ; 
    dsn   | string |   atalkingdog2018  ; 
    bansdsn   | string |  AFPWebworksNet2020   ;
    
    ================================================================================================================
    
    --->
    </cfsilent>
    
    <!---[	PROPERTIES	]--->
        <cfset variables.instance = StructNew() />
        
    <!---[	INITIALIZATION / CONFIGURATION	]--->
    <cffunction name="init" access="public" returntype="ConfigBean" output="false">
        <cfargument name="argsConfigXMLname" type="string" required="yes" />
    <!---[	Global variable arguments 	]--->
    
    
        <cfargument name="PageIncrement" type="numeric" required="false" default="7" />
        <cfargument name="AddNewContentAt" type="string" required="false" default="Bottom" />
        <cfargument name="AddNewPageAt" type="string" required="false" default="Top" />
        <cfargument name="hometimezone" type="string" required="false" default="Australia/Sydney" />
        <cfargument name="MonthsBeforeArchive" type="numeric" required="false" default="2" />
        <cfargument name="settingsTablename" type="string" required="false" default="BT20Settings" />
      
        
        <!---[	Siteversion-specific variable arguments and default - Development]---> 
            
        <cfargument name="approotABS" type="string" required="false" default="D:\Sites\Mysites\BT20\BT20" />
        <cfargument name="cmsrootABS" type="string" required="false" default="D:\Sites\Mysites\BT20\BT20CMS" />
        <cfargument name="approotURL" type="string" required="false" default="http://127.0.0.1:59628/" />
        <cfargument name="cmsrootURL" type="string" required="false" default="http://127.0.0.1:59852/" />
        <cfargument name="sitename" type="string" required="false" default="BT20 Development" />
        <cfargument name="dsn" type="string" required="false" default="atalkingdog2018" />
        <cfargument name="bansdsn" type="string" required="false" default="AFPWebworksNet2020" />
        <cfset var siteversion = application.siteversion />
        <cffile action="read" 
            file="#expandPath(arguments.argsConfigXMLname)#"	
            variable="rawconfigXML"/>
        <cfset configXML = xmlparse(rawconfigXML) />
        
        <cfscript>
            // set the base paths and ABS paths 
            variables.elements.approotABS = "#ExpandPath( "/" )#"; 
            thisapprootABS = variables.elements.approotABS;
            // Remove the trailing slash from the ABS paths  
            variables.elements.approotABS = left(thisapprootABS, (len(thisapprootABS)-1) );
            // set base paths
            variables.elements.ApprootURL = ("http://" &  cgi.http_host  );
            setApprootURL(variables.elements.ApprootURL );
            setApprootABS(variables.elements.approotABS);
        // run globals setters
    
        setPageIncrement(configXML.settings.globals.PageIncrement.xmltext);
        setAddNewContentAt(configXML.settings.globals.AddNewContentAt.xmltext);
        setAddNewPageAt(configXML.settings.globals.AddNewPageAt.xmltext);
        sethometimezone(configXML.settings.globals.hometimezone.xmltext);
        setMonthsBeforeArchive(configXML.settings.globals.MonthsBeforeArchive.xmltext);
        setsettingsTablename(configXML.settings.globals.settingsTablename.xmltext);
        // run site version setters 
        
        setapprootABS(configXML.settings[#siteversion#].approotABS.xmltext);
        setcmsrootABS(configXML.settings[#siteversion#].cmsrootABS.xmltext);
        setapprootURL(configXML.settings[#siteversion#].approotURL.xmltext);
        setcmsrootURL(configXML.settings[#siteversion#].cmsrootURL.xmltext);
        setsitename(configXML.settings[#siteversion#].sitename.xmltext);
        setdsn(configXML.settings[#siteversion#].dsn.xmltext);
        setbansdsn(configXML.settings[#siteversion#].bansdsn.xmltext);

        SetfromDSN() ;
            return this;
            </cfscript>
         </cffunction>
        <!---[ 	PUBLIC FUNCTIONS 	]--->
        <cffunction name="getSnapshot" access="public"returntype="struct" output="false" >
            <cfreturn variables.instance />
        </cffunction>
        <!-----[ 	ACCESSORS 	  ] ----> 

        
        <!-----[   Global accessors   ] ---->	
        
        
        
        <cffunction name="setPageIncrement" access="public" returntype="void" output="false">
            <cfargument name="PageIncrement" type="numeric" required="true" />
            <cfset variables.instance.PageIncrement = arguments.PageIncrement />
            <cfset application.PageIncrement = arguments.PageIncrement />
        </cffunction>
    
        <cffunction name="getPageIncrement" access="public" returntype="numeric" output="false">
            <cfreturn variables.instance.PageIncrement />
        </cffunction>	
        
        <cffunction name="setAddNewContentAt" access="public" returntype="void" output="false">
            <cfargument name="AddNewContentAt" type="string" required="true" />
            <cfset variables.instance.AddNewContentAt = arguments.AddNewContentAt />
            <cfset application.AddNewContentAt = arguments.AddNewContentAt />
        </cffunction>
    
        <cffunction name="getAddNewContentAt" access="public" returntype="string" output="false">
            <cfreturn variables.instance.AddNewContentAt />
        </cffunction>	
        
        <cffunction name="setAddNewPageAt" access="public" returntype="void" output="false">
            <cfargument name="AddNewPageAt" type="string" required="true" />
            <cfset variables.instance.AddNewPageAt = arguments.AddNewPageAt />
            <cfset application.AddNewPageAt = arguments.AddNewPageAt />
        </cffunction>
    
        <cffunction name="getAddNewPageAt" access="public" returntype="string" output="false">
            <cfreturn variables.instance.AddNewPageAt />
        </cffunction>	
        
        <cffunction name="sethometimezone" access="public" returntype="void" output="false">
            <cfargument name="hometimezone" type="string" required="true" />
            <cfset variables.instance.hometimezone = arguments.hometimezone />
            <cfset application.hometimezone = arguments.hometimezone />
        </cffunction>
    
        <cffunction name="gethometimezone" access="public" returntype="string" output="false">
            <cfreturn variables.instance.hometimezone />
        </cffunction>	
        
        <cffunction name="setMonthsBeforeArchive" access="public" returntype="void" output="false">
            <cfargument name="MonthsBeforeArchive" type="numeric" required="true" />
            <cfset variables.instance.MonthsBeforeArchive = arguments.MonthsBeforeArchive />
            <cfset application.MonthsBeforeArchive = arguments.MonthsBeforeArchive />
        </cffunction>
    
        <cffunction name="getMonthsBeforeArchive" access="public" returntype="numeric" output="false">
            <cfreturn variables.instance.MonthsBeforeArchive />
        </cffunction>
        
        <cffunction name="setsettingsTablename" access="public" returntype="void" output="false">
            <cfargument name="settingsTablename" type="string" required="true" />
            <cfset variables.instance.settingsTablename = arguments.settingsTablename />
            <cfset application.settingsTablename = arguments.settingsTablename />
        </cffunction>
    
        <cffunction name="getsettingsTablename" access="public" returntype="string" output="false">
            <cfreturn variables.instance.settingsTablename />
        </cffunction>


           <!-----[   Siteversion specific accessors   ] ---->
    
           
    
           <cffunction name="setapprootABS" access="public" returntype="void" output="false">
            <cfargument name="approotABS" type="string" required="true" />
            <cfset variables.instance.approotABS = arguments.approotABS />
            <cfset application.approotABS = arguments.approotABS />
        </cffunction>
        
        <cffunction name="getapprootABS" access="public" returntype="string" output="false">
            <cfreturn variables.instance.approotABS />
        </cffunction>
    
           <cffunction name="setcmsrootABS" access="public" returntype="void" output="false">
            <cfargument name="cmsrootABS" type="string" required="true" />
            <cfset variables.instance.cmsrootABS = arguments.cmsrootABS />
            <cfset application.cmsrootABS = arguments.cmsrootABS />
        </cffunction>
        
        <cffunction name="getcmsrootABS" access="public" returntype="string" output="false">
            <cfreturn variables.instance.cmsrootABS />
        </cffunction>
    
           <cffunction name="setapprootURL" access="public" returntype="void" output="false">
            <cfargument name="approotURL" type="string" required="true" />
            <cfset variables.instance.approotURL = arguments.approotURL />
            <cfset application.approotURL = arguments.approotURL />
        </cffunction>
        
        <cffunction name="getapprootURL" access="public" returntype="string" output="false">
            <cfreturn variables.instance.approotURL />
        </cffunction>
    
           <cffunction name="setcmsrootURL" access="public" returntype="void" output="false">
            <cfargument name="cmsrootURL" type="string" required="true" />
            <cfset variables.instance.cmsrootURL = arguments.cmsrootURL />
            <cfset application.cmsrootURL = arguments.cmsrootURL />
        </cffunction>
        
        <cffunction name="getcmsrootURL" access="public" returntype="string" output="false">
            <cfreturn variables.instance.cmsrootURL />
        </cffunction>
    
           <cffunction name="setsitename" access="public" returntype="void" output="false">
            <cfargument name="sitename" type="string" required="true" />
            <cfset variables.instance.sitename = arguments.sitename />
            <cfset application.sitename = arguments.sitename />
        </cffunction>
        
        <cffunction name="getsitename" access="public" returntype="string" output="false">
            <cfreturn variables.instance.sitename />
        </cffunction>
    
           <cffunction name="setdsn" access="public" returntype="void" output="false">
            <cfargument name="dsn" type="string" required="true" />
            <cfset variables.instance.dsn = arguments.dsn />
            <cfset application.dsn = arguments.dsn />
        </cffunction>
        
        <cffunction name="getdsn" access="public" returntype="string" output="false">
            <cfreturn variables.instance.dsn />
        </cffunction>
    
           <cffunction name="setbansdsn" access="public" returntype="void" output="false">
            <cfargument name="bansdsn" type="string" required="true" />
            <cfset variables.instance.bansdsn = arguments.bansdsn />
            <cfset application.bansdsn = arguments.bansdsn />
        </cffunction>
        
        <cffunction name="getbansdsn" access="public" returntype="string" output="false">
            <cfreturn variables.instance.bansdsn />
        </cffunction>
           <!-----[   Paths getters and setters accessors   ] ---->
    
        <cffunction name="setApprootURL" access="public" returntype="void" output="false">
            <cfargument name="ApprootURL" type="string" required="true" default="#variables.elements.approotURL#"/>
            <cfargument name="ApprootABS" type="string" required="true" default="#variables.elements.ApprootABS#"/>
            <cfset variables.instance.ApprootURL = #trim(arguments.ApprootURL)#/>
            <cfset application.ApprootURL = #trim(arguments.ApprootURL)# />
        </cffunction>
        
        <cffunction name="getApprootURL" access="public" returntype="string" output="false">
            <cfreturn variables.instance.ApprootURL />
        </cffunction>
    
        <cffunction name="setApprootABS" access="public" returntype="void" output="false">
            <cfargument name="ApprootABS" type="string" required="true" default="#variables.elements.ApprootABS#"/>
            <cfargument name="ApprootABS" type="string" required="true" default="#variables.elements.ApprootABS#"/>
            <cfset variables.instance.ApprootABS = #trim(arguments.ApprootABS)#/>
            <cfset application.ApprootABS = #trim(arguments.ApprootABS)#/>
        </cffunction>
        
        <cffunction name="getApprootABS" access="public" returntype="string" output="false">
            <cfreturn variables.instance.ApprootABS />
        </cffunction>

        <cffunction name="SetfromDSN"  access="public" returntype="ANY" output="false">

      <!--- Now query the settings table in the datasource and set the application variables from that. ---->
        <cfquery name="qAppSettings" datasource="#application.dsn#">
           SELECT Setting, Value  
            FROM #application.SETTINGSTABLENAME#
            WHERE ToDelete = '0' 
            ORDER by setting ASC  
        </cfquery>
          <cfif qAppSettings.recordcount GT 0 >
            <cfloop query="qAppSettings">
                <cfset #application[qAppSettings.setting]# = #qAppSettings.Value# />	
            </cfloop>
        </cfif> 
    </cffunction>
    
    </cfcomponent>

   



