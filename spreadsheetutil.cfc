<cfcomponent>

<cffunction name="indexImportedCollections">
<cfargument name="name" type="string" required="yes">

<cfset util = CreateObject("component","migrateUtils")>

     <cfset collname = "#name#">
	<cfset solrdirectory = "#expandpath('.')#/#collname#">
	
	<cfif ! #util.collectionexists(collname)#>
				<cfcollection action="CREATE" collection="#collname#"  path="#solrdirectory#"  >
	<cfelse>
				<cfindex collection="#collname#" action="purge">
	</cfif>
         
	<cfif FileExists("#expandpath('.')#/data/#name#/#name#_file.csv")>

		<cfindex collection="#collname#" action="purge">
		<cfset sleep(500)>
		<cffile action="read" file="#expandpath('.')#/data/#name#/#name#_file.csv" variable="csvvar1">
		<cfspreadsheet action="write" filename="#expandpath('.')#/temp.xls" format="csv" name="csvvar1" overwrite="true" >
		<cfspreadsheet action = "read" format="csv" src="#expandpath('.')#/temp.xls"   name="csvvar1"  >
                <cfspreadsheet action = "read"  headerrow="1"  src="#expandpath('.')#/temp.xls"   query="queryData" excludeHeaderRow="yes" columns="1-11">
                
                <!---- queryData may contains both file and custom type of data. Creating 2 queries one only have only files and othe have only custom---->
                
                <cfscript>
		// query for file
		qfile = QueryNew("KEYCOL,CATEGORY,CATEGORYTREE,TITLE,URL,CUSTOM1,CUSTOM2,CUSTOM3,CUSTOM4,SUMMARY,LANGUAGE");
		
		// Query for custom
		qcustom = QueryNew("KEYCOL,CATEGORY,CATEGORYTREE,TITLE,URL,CUSTOM1,CUSTOM2,CUSTOM3,CUSTOM4,SUMMARY,LANGUAGE");
				  
		
				  
              </cfscript>
                <cfloop query="queryData">
                   <cfif FileExists("#key#")>
			<cfset QueryAddRow(qfile)>
			<cfset QuerySetCell(qfile, "KEYCOL", "#key#")>
			<cfset QuerySetCell(qfile, "CATEGORY", "#CATEGORY#")>
			<cfset QuerySetCell(qfile, "CATEGORYTREE", "#CATEGORYTREE#")>
			<cfset QuerySetCell(qfile, "URL", "#URL#")>
			<cfset QuerySetCell(qfile, "TITLE", "#TITLE#")>
			<cfset QuerySetCell(qfile, "CUSTOM1", "#CUSTOM1#")>
			<cfset QuerySetCell(qfile, "CUSTOM2", "#CUSTOM2#")>
			<cfset QuerySetCell(qfile, "CUSTOM3", "#CUSTOM3#")>
			<cfset QuerySetCell(qfile, "CUSTOM4", "#CUSTOM4#")>
			<cfset QuerySetCell(qfile, "LANGUAGE", "#LANGUAGE#")> 
			<cfset QuerySetCell(qfile, "SUMMARY", "#SUMMARY#")>                	
			
		   <cfelse>
			<cfset QueryAddRow(qcustom)>
			<cfset QuerySetCell(qcustom, "KEYCOL", "#key#")>
			<cfset QuerySetCell(qcustom, "CATEGORY", "#CATEGORY#")>
			<cfset QuerySetCell(qcustom, "CATEGORYTREE", "#CATEGORYTREE#")>
			<cfset QuerySetCell(qcustom, "URL", "#URL#")>
			<cfset QuerySetCell(qcustom, "TITLE", "#TITLE#")>
			<cfset QuerySetCell(qcustom, "CUSTOM1", "#CUSTOM1#")>
			<cfset QuerySetCell(qcustom, "CUSTOM2", "#CUSTOM2#")>
			<cfset QuerySetCell(qcustom, "CUSTOM3", "#CUSTOM3#")>
			<cfset QuerySetCell(qcustom, "CUSTOM4", "#CUSTOM4#")>
			<cfset QuerySetCell(qcustom, "LANGUAGE", "#LANGUAGE#")> 
			<cfset QuerySetCell(qcustom, "SUMMARY", "#SUMMARY#")> 
			
		   </cfif>
                </cfloop>
                
          <!--- Step 1 indexing custom type data with query qcustom---->
          <cfindex action="update" collection="#collname#" query="qcustom" type="custom"
	  						                     key="KEYCOL" title="title" body="summary"
	  											 URLpath ="url"
	  											 custom1="custom1"
	  											 custom2="custom2"
	  											 custom3="custom3"
	  											 custom4="custom4"
	  											 category ="category"
											 categoryTree="categoryTree" >
		
          <!--- Step 2 Indexing file type data.---->
        <cfloop query="qfile">
      
        	<cfif FileExists("#KEYCOL#")>
        	
        	 <cfindex collection="#collname#" type="file" key="#KEYCOL#" action="update" category =#category# 
        	 	categoryTree=#categoryTree#
        	 	custom1=#custom1#
        	 	custom2=#custom2#
        	 	custom3=#custom3#
        	 	custom4=#custom4#
        	 	URLpath=#url#
        	 	>
	    	
	    	</cfif>
	    </cfloop>
	 
    <!--- Now put a dummy file in folder migrated to mark migration complete---->
    	<cffile action = "write"
	    file = "#expandpath('.')#/migrated/#collname#.txt"
	    output = "Migrated..."
    	    fixnewline ="yes">

   </cfif>

  
</cffunction>
</cfcomponent>