<cfcomponent>

<cffunction name="getIndexableColumns">
<cfargument name="fullList" type="Array" required="true">

	<!--- Converting Arry to list---->
	<cfset columns = #ArrayToList(fullList)#>
	<cfset listOfIndexableColumns = "SUMMARY,CATEGORY,CATEGORYTREE,[KEY],URL,TITLE">

	<!---- Check for Custom fields CUSTOM1,CUSTOM2,CUSTOM3,CUSTOM4---->
		<cfif columns contains "CUSTOM1" >
			<cfset listOfIndexableColumns = listOfIndexableColumns & ",CUSTOM1" >
		</cfif>
		<cfif columns contains "CUSTOM2" >
					<cfset listOfIndexableColumns = listOfIndexableColumns & ",CUSTOM2" >
		</cfif>
		<cfif columns contains "CUSTOM3" >
					<cfset listOfIndexableColumns = listOfIndexableColumns & ",CUSTOM3" >
		</cfif>
		<cfif columns contains "CUSTOM4" >
					<cfset listOfIndexableColumns = listOfIndexableColumns & ",CUSTOM4" >
		</cfif>

<cfreturn listOfIndexableColumns >


</cffunction>


<cffunction name="ConvertToCSV">
<cfargument name="collname" type="String" required="true">
<cfargument name="colltype" type="String" required="true">
<cfargument name="CollNonQuery" type="query" required="true">
<cfargument name="language" type="String" default="english" required="no">

<cfset ln="">
<cfoutput query="CollNonQuery">
<!--------Comumn names
1. CATEGORY
2. CATEGORYTREE
3. KEY
3a.SUMMARY[OPTIONAL only for custom type]
4. TITLE
5. URL
6. CUSTOM1
7. CUSTOM2
8. CUSTOM3
9. CUSTOM4
----------->
<cfset CrLf = Chr(13) & Chr(1)>

<cfset header = "CATEGORY,CATEGORYTREE,KEY,TITLE,URL,CUSTOM1,CUSTOM2,CUSTOM3,CUSTOM4,LANGUAGE,SUMMARY" &  Chr( 10 )  >

<!----<cfset ln = ln & #CollNonQuery.category# & "," & #CollNonQuery.CATEGORYTREE# & "," & #CollNonQuery.key# & ",'" & #CollNonQuery.summary# & "'," & #CollNonQuery.title# & "," & #CollNonQuery.url# & "," >---->
<cfset ln = ln & #CollNonQuery.category# & "," & #CollNonQuery.CATEGORYTREE# & "," & #CollNonQuery.key# & ","  & #CollNonQuery.title# & "," & #CollNonQuery.url# & "," >
<cfif columns contains "custom1">
	<cfset ln = ln & #CollNonQuery.custom1# & ",">
<cfelse>
    <cfset ln = ln & ",">
</cfif>
<cfif columns contains "custom2">
	<cfset ln = ln & #CollNonQuery.custom2# & ",">
<cfelse>
    <cfset ln = ln & ",">
</cfif>
<cfif columns contains "custom3">
	<cfset ln = ln & #CollNonQuery.custom3# & ",">
<cfelse>
    <cfset ln = ln & ",">
</cfif>

<cfif columns contains "custom4">
	<cfset ln = ln & #CollNonQuery.custom4# & "," >
<cfelse>
    <cfset ln = ln & "," >
</cfif>

 <cfset ln = ln & #language# & "," >
 <!--- putting summary in the last as it can contain , or " which can change--->
 <cfset ln = ln & #CollNonQuery.summary# & "," & Chr( 10 )>
</cfoutput>



<cffile action = "write"
    file = "#expandpath('.')#/data/#collname#/#collname#_#colltype#.csv"
    output = "#header##ln#"
    fixnewline ="yes">

</cffunction>


<cffunction name="migrateCollection">
<cfargument name="collname" type="String" required="true">
<cfargument name="language" type="String" default="english" required="no">


<cfsearch collection="#collname#" name="x" >
<cfset columns = "#x.getColumnList()#">

<cfset selectedColumns = #getIndexableColumns(columns)#>

<!---- Get all results----->


<cfquery dbtype="query" name="CollNonQuery">
select * from x Order By CATEGORYTREE,CATEGORY
</cfquery>

<cfif ! DirectoryExists("#expandpath('.')#/data/#collname#")>
    
    <cfdirectory action = "create" directory = "#expandpath('.')#/data/#collname#" >
    
</cfif>

<cfif #x.recordssearched# GT 0>

<cfset ConvertToCSV("#collname#","file",CollNonQuery,language)>
</cfif>

</cffunction>


<cffunction name="collectionexists" access="public" returntype="boolean" displayname="collectionExists" hint="Pass in the name of a Solr collection (string) to see if it has already been created">
	<cfargument name="collection" type="string" required="yes">
        <cfargument name="engine" type="string" required="no" default="">
        <cftry>
        <cfcollection name="qcoll" action="list" >	
                <cfcollection name="qcoll" action="list" >          
		<cfset collectionlist=valuelist(qcoll.name)>
		<cfset csuccess="no">
		<cfif listlen(collectionlist) gt 0>
			<cfloop from=1 to=#listlen(collectionlist)# index=i>
				<cfif listgetat(collectionlist,i) is arguments.collection>
					<cfset csuccess="yes">
					<cfbreak>
				</cfif>
			</cfloop>
		</cfif>
	<cfcatch><cfreturn 0></cfcatch>
	</cftry>
		<cfreturn #csuccess#>	
</cffunction>

<cffunction name="getSearchServerState" access="public" returntype="numeric" hint="Provides information about solr and verity server state. ">
	<cfargument name="version" type="string" required="yes">
	<!---
	return 0 ->Solr Not Applicable
	return 1 -> Verity Not Applicable
	return 2 -> Both Solr and Verity are Applicable
	return 3 -> Invalid Version
	--->
	<!---- For CF8 no solr ---->
	<cfif version contains "8,">
	 	<cfreturn 0>
	</cfif>
	<!---- For CF10 and CF902 no Verity ---->
	<cfif (version contains "10,") OR (version contains "9,0,2")>
	 	<cfreturn 1>
	</cfif>
	
	<!--- For CF9 and CF901 both Solr and verity is available ---->
	<cfif (version contains "9,0") OR (version contains "9,0,1")>
	 	<cfreturn 2>
	</cfif>
	<cfreturn 3>

</cffunction>

<cffunction name="getSearchServerStatus" access="public" returntype="numeric" hint="Provides information if Solr/Verity servers are up and running">
	<cfargument name="version" type="string" required="yes">
	<cfset status = #getSearchServerState(version)#>
	
	<cfset isVerityEnabled = false>
	<cfset isSolrEnabled = false>
	<cfset toreturn =0>
	
	<cfif (status equals 0) or (status equals 2)>
		<cftry>
			<cfset isVerityEnabled =  createObject("java", "coldfusion.tagext.search.Utils").IsVerityRunning()>
		<cfcatch><cfset isVerityEnabled= "NO"></cfcatch>
		</cftry>
		<cfif isVerityEnabled>
			<cfset toreturn = toreturn +1>
		</cfif>
	</cfif>
	
	<cfif (status equals 1) or (status equals 2)>
	    <cftry>
		<cfset solrService = createObject("java","coldfusion.server.ServiceFactory").getSolrService()>
		<cfset solrurl = createObject("java","coldfusion.tagext.search.SolrUtils").getSolrUrl(solrService)>
		<cfset isSolrEnabled =  createObject("java", "coldfusion.tagext.search.SolrUtils").IsSolrRunning(solrurl)>
	    <cfcatch><cfset isSolrEnabled= "NO"></cfcatch>
	    </cftry>
		
		<cfif isSolrEnabled>
			<cfset toreturn = toreturn +10>
		</cfif>
	</cfif>
	
	<!---
	toreturn=0 -> Both Solr and Verity not running
	toreturn=1 -> Only Verity is running
	toreturn=10 -> Only Solr is running
	toreturn=11-> Both Solr and Verity are running
	--->
	<cfreturn toreturn>
	
</cffunction>




</cfcomponent>