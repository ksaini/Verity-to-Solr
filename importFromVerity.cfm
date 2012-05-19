
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
<table>

<tbody><tr>
	<td>&nbsp;</td>
	<td><br>
<!-- margin top -->
<h2 class="pageHeader"> Verity  &gt; Solr Collection Migration tool - STEP 1</h2>
<br>

<p>
This tool allows you to migrate your Verity collections created in CF8/CF9 to CF902 and CF10. This page is the first step to migrate. Following is the list of the available Verity collection. Take a back up of the collection you want to migrate to Solr.
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
				<cfset showtable =1>
				<cfelse>
					Stopped, Please start Verity Server.
					<cfset showtable =1>
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
				<cfelse>
					Stopped, Please start Solr Server.
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
				<a class="tableHeader" href=""> Actions
			</a></th>
			<th scope="col" nowrap="" bgcolor="#F3F7F7" class="cellBlueTopAndBottom">
				<a class="tableHeader" href=""> Name</a>
			</th>
			<th scope="col" nowrap="" bgcolor="#F3F7F7" class="cellBlueTopAndBottom">
				<a class="tableHeader" href=""> Documents </a>
			</th>
			<th scope="col" nowrap="" bgcolor="#F3F7F7" class="cellBlueTopAndBottom">
				<a class="tableHeader" href=""> Size (Kb)</a>
			</th>
			<th scope="col" nowrap="" bgcolor="#F3F7F7" class="cellBlueTopAndBottom">
				<a class="tableHeader" href=""> Language (Kb)</a>
			</th>
			<th scope="col" nowrap="" bgcolor="#F3F7F7" class="cellBlueTopAndBottom">
				<a class="tableHeader" href=""> Path</a>
			</th>
			<th scope="col" nowrap="" bgcolor="#F3F7F7" class="cellBlueTopAndBottom">
				<a class="tableHeader" href=""> Status</a>
			</th>

		</tr>
		<cfoutput>
        <cfif isDefined("coll_list")>
    	<cfloop query="coll_list">
    	<cfset d =  directoryexists("#expandpath('.')#/#name#")>
		<tr>
			<td nowrap="" class="cell3BlueSides">

				<table border="0" cellpadding="0" cellspacing="0">
				<tbody><tr >
				        <td text-align="center">
						<a href="importFromVerity.cfm?id=#name#&language=#language#">
						Export Collection</a>
					</td>

				</tr>
				</tbody></table>

			</td>
			<td align="center" nowrap="" class="cellRightAndBottomBlueSide">
				<a href="">
				#name#</a>
			</td>
			<td align="center" nowrap="" class="cellRightAndBottomBlueSide">
				#doccount#
			</td>
			<td align="center" nowrap="" class="cellRightAndBottomBlueSide">
				#size#
			</td>
			<td align="center" nowrap="" class="cellRightAndBottomBlueSide">
				#language#
			</td>
			<td align="center" nowrap="" class="cellRightAndBottomBlueSide">
				#path#
			</td>
			<td align="center" nowrap="" class="cellRightAndBottomBlueSide">
			<a href="importFromVerity.cfm"><div id="#name#"><cfif d>Exported</cfif>&nbsp;</div></a>
			</td>

		</tr>
		</cfloop>
	</cfif>
    </cfoutput>
		</table>

	</td>
</tr>
</tbody></table>
<p>
<br>
Once you have taken backup of Verity collections that you want to migrate. Copy this folder <cfoutput>#expandpath('.')#</cfoutput> to other CF version's webroot.
<br><a href="exportToSolr.cfm"><b><u>Import to Solr</u></b></a>
</p>
<cfelse>
<p>
This version <cfoutput>(#strVersion#)</cfoutput> of ColdFusion does not support Verity. If you have already taken the backup of Verity collections previously, <a href="exportToSolr.cfm"><b><u>Import them to Solr</u></b></a>.
</p>
</cfif>
</div>

<cfif isDefined("URL.id")>
	<cfif isDefined("URL.language")>
	    <cfset lan = #URL.language#>
	 <cfelse>
		   <cfset lan = "english">
	 </cfif>

	<cfset util.migrateCollection("#URL.id#",lan)>
	<cfoutput>
	<cfif showtable>
    	<script>
			var txt=document.getElementById("#URL.id#");
			alert("Exported Collection #URL.id#");
			txt.innerHTML= "Exported";
		</script>
	</cfif>
    </cfoutput>
</cfif>

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






