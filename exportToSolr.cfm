<script>
function sendData(name){
	var path = document.getElementById(name).value;
	var url = 'exportToSolr.cfm?name='+name+'&path='+path;
	window.location.href = url;
}
</script>


<cfdirectory action="list" directory="#expandpath('.')#/data"
    name="myDirectory" type="dir">
<html>
<head><link rel="stylesheet" type="text/css" href="style/mystyle.css" /></head>
<table width="100%" border="0" cellspacing="0" cellpadding="0">


<tbody><tr>
	<td><img src="images/contentframetopleft.png" alt="" height="23" width="16"></td><td background="images/contentframetopbackground.png"><img src="images/spacer.gif" alt="" height="23" width="540"></td><td><img src="images/contentframetopright.png" alt="" height="23" width="16"></td>
</tr>

  <tr>

    <td width="16" style="background:url('images/contentframeleftbackground.png') repeat-y;"><img src="images/spacer.gif" alt="" width="16" height="1"></td>

	<td>

		<table width="100%" border="0" cellspacing="0" cellpadding="0">
		  <tbody><tr>
		    <td width="10" bgcolor="#FFFFFF"><img src="images/spacer_10_x_10.gif" alt="" width="10" height="10"></td>
			<td bgcolor="#FFFFFF">

				<table width="100%" border="0" cellspacing="0" cellpadding="5">
				  <tbody><tr valign="top">
					<td valign="top">
<form action="importFromVerity.cfm">
<cfset issolrrunning = 0>
<cfset isverityrunning = 0>


<cfset strVersion = SERVER.ColdFusion.ProductVersion />
<cfset util = CreateObject("component","migrateUtils")>
<cftry>
<cfset st = util.getSearchServerStatus(strVersion)>
<!---
	st=0 -> Both Solr and Verity not running
	st=1 -> Only Verity is running
	st=10 -> Only Solr is running
	st=11-> Both Solr and Verity are running
	--->
<cfset state = util.getSearchServerState(strVersion)>

<cfcollection action="list" name="coll_list">
<cfcatch></cfcatch>
</cftry>
<cfset showtable=0>
<table >

<tbody><tr>
	<td>&nbsp;</td>
	<td><br>
<!-- margin top -->
<h2 class="pageHeader"> Verity  &gt; Solr Collection Migration tool - STEP 2</h2>
<br>

<p>
This page will allow you to export your Verity collections whose backup has been taken from step1. This step will use the intermediate data to create a solr collection.
If the same collection is already present here it will update the same.
</p>

<table border="0" cellpadding="5" cellspacing="0" width="100%">
<tbody><tr>
	<td scope="row" colspan="2" bgcolor="#E2E6E7" class="cellBlueTopAndBottom">
		<b> System Information </b>
	</td>
</tr>
<tr>
	<td scope="row">

		<table border="0" cellpadding="2" cellspacing="0" width="100%">
		<tbody><tr>
			<td scope="row" colspan="2" class="cellBlueTopAndBottom" bgcolor="#F3F7F7">
				<strong> Server Details</strong>
			</td>
		</tr>
		<tr>
			<td scope="row" nowrap="" class="cell3BlueSides">
				Product Name
			</td>
			<td scope="row" class="cellRightAndBottomBlueSide">
				<cfoutput>#SERVER.ColdFusion.Productname#</cfoutput>
			</td>
		</tr>

		<tr>
			<td scope="row" nowrap="" class="cell3BlueSides">
				Version
			</td>
			<td scope="row" class="cellRightAndBottomBlueSide">
				<cfoutput>#SERVER.ColdFusion.ProductVersion#</cfoutput>
			</td>
		</tr>
		<tr>
			<td scope="row" nowrap="" class="cell3BlueSides">
				Edition
			</td>
			<td scope="row" class="cellRightAndBottomBlueSide">
				Enterprise &nbsp;
			</td>
		</tr>

		<tr>
			<td scope="row" nowrap="" class="cell3BlueSides">
				Verity Server
			</td>
			<td scope="row" class="cellRightAndBottomBlueSide">
				<cfif (state equals 1) OR (state equals 3)>
					Not Applicable
				<cfelseif (st equals 1) OR (st equals 11)>
					Running
				<cfelse>
					Stopped, Please start Verity Server.
				</cfif>
			</td>
		</tr>

		<tr>
			<td scope="row" nowrap="" class="cell3BlueSides">
				Solr Server
			</td>
			<td scope="row" class="cellRightAndBottomBlueSide">
				<cfif (state equals 0) OR (state equals 3)>
					Not Applicable
				<cfelseif (st equals 10) OR (st equals 11)>
					Running
					<cfset showtable =1>
				<cfelse>
					Stopped, Please start Solr Server.
					<cfset showtable =1>
				</cfif> &nbsp;
			</td>
		</tr>
		</tbody></table>

	</td>
</tr>
</tbody></table>

<br><br>
<cfif showtable>
<table border="0" cellpadding="5" cellspacing="0" width="100%">
<tbody><tr>
	<td bgcolor="#E2E6E7" class="cellBlueTopAndBottom">
		<b><label for="dsn"> Verity Collections</label></b>
	</td>
</tr>
<tr>
	<td>

		<table border="0" cellpadding="2" cellspacing="0" width="100%">
		<tbody><tr>
			<th scope="col" nowrap="" bgcolor="#F3F7F7" class="cellBlueTopAndBottom">
				<a class="tableHeader" href=""> Action
			</a></th>
			<th scope="col" nowrap="" bgcolor="#F3F7F7" class="cellBlueTopAndBottom">
				<a class="tableHeader" href=""> Collection Name</a>
			</th>

			<th scope="col" nowrap="" bgcolor="#F3F7F7" class="cellBlueTopAndBottom">
				<a class="tableHeader" href="">New Collection Path</a>
			</th>
			<th scope="col" nowrap="" bgcolor="#F3F7F7" class="cellBlueTopAndBottom">
							<a class="tableHeader" href=""> Status</a>
			</th>

		</tr>
		<cfoutput>
    	<cfloop query="myDirectory">
    	<cfset d =  directoryexists("#expandpath('.')#/#name#")>
		<tr>
			<td nowrap="" class="cell3BlueSides">

				<table border="0" cellpadding="0" cellspacing="0">
				<tbody><tr >
				        <td  >
				        <a onclick="sendData('#name#');return false;" href="##">
						<b>&nbsp;&nbsp;&nbsp;Import collection to Solr</b></a>
					</td>

				</tr>
				</tbody></table>

			</td>
			<td align="center" nowrap="" class="cellRightAndBottomBlueSide">
				<a href="">
				#name#</a>
			</td>

			<td align="center" nowrap="" class="cellRightAndBottomBlueSide">
				<input type="text" id="#name#" value="#expandpath('.')#/#name#" size="50">
			</td>
			<td align="center" nowrap="" class="cellRightAndBottomBlueSide">
            <div id="#name#">
			<cfif FileExists("#expandpath('.')#/migrated/#name#.txt")>Collection Migrated</cfif> &nbsp;
			</div>
			</td>

		</tr>
		</cfloop>
    </cfoutput>
		</table>

	</td>
</tr>
</tbody></table>

<cfelse>
<p>
This version <cfoutput>(#strVersion#)</cfoutput> of ColdFusion does not support Solr. <a href="importFromVerity.cfm"><b><u>Export from Verity</u></b></a>.
</p>
</cfif>

</form>
<br><br>

<!-- margin bottom -->
		<br>
	</td>
	<td>&nbsp;</td>
</tr>

</tbody></table>

</form>
</td>
				  </tr>
				</tbody></table>

			</td>
		    <td width="10" bgcolor="#FFFFFF"><img src="images/spacer_10_x_10.gif" alt="" width="10" height="10"></td>
		  </tr>
		</tbody></table>


		</td><td width="10" style="background:url('images/contentframerightbackground.png') repeat-y;"><img src="spacer.gif" alt="" width="16" height="1"></td>

  </tr>
  <tr>
	<td><img src="images/contentframebottomleft.png" height="23" alt="" width="16"></td><td background="images/contentframebottombackground.png"><img src="images/spacer.gif" alt="" height="23" width="540"></td><td>
	<img src="images/contentframebottomright.png" alt="" height="23" width="16"></td>
	</tr>
</tbody></table>

</html>


<cfif isDefined("URL.name")>

<cfset spreadsheetutil = CreateObject("component","spreadsheetutil")>
<cfset spreadsheetutil.indexImportedCollections("#URL.name#")>
<cfif showtable>
    	<script>
			var txt=document.getElementById("#URL.name#");
			alert("Collection Migrated");
			txt.innerHTML= "Collection Migrated";
		</script>
	</cfif>

</cfif>