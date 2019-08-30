<cfset shortURLUtil = new lib.shorturl()>

<cfset id = 3843824>

<cfset shortID = shortURLUtil.getShortID( id )>

<cfdump var="#shortID#">

<!--- this should output the same value as 'id' --->
<cfdump var="#shortURLUtil.readShortID( shortID )#">