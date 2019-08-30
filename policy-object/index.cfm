<cfset policyService = new model.policy.PolicyService()>
<cfset policies = [ "000123-01", "000230-01" ]>

<cfoutput>
	<cfloop array="#policies#" item="policyNumber">
		<cfset policy = policyService.get( policyNumber: policyNumber )>

		<h1>Policy Info</h1>

		<dl>
			<dt>Policy Number</dt>
			<dd>#policy.getPolicyNumber().encodeForHTML()#</dd>
		</dl>
		<dl>
			<dt>Policy Type</dt>
			<dd>#policy.getType().getName().encodeForHTML()#</dd>
		</dl>
		<dl>
			<dt>Effective Date</dt>
			<dd>#policy.getFormattedDateEffective().encodeForHTML()#</dd>
		</dl>
		<dl>
			<dt>Expiration Date</dt>
			<dd>#policy.getFormattedDateExpires().encodeForHTML()#</dd>
		</dl>
		<cfloop array="#policy.getOptions()#" item="option">
			<dl>
				<dt>#option.getName().encodeForHTML()#</dt>
				<dd>#option.getFormattedValue()#</dd>
			</dl>
		</cfloop>

		<h1>Is Policy Type</h1>

		<dl>
			<dt>Is Homeowner Policy?</dt>
			<dd>#yesNoFormat( policy.isType( "Homeowner Policy" ) )#</dd>
		</dl>

		<dl>
			<dt>Is Auto Policy?</dt>
			<dd>#yesNoFormat( policy.isType( "Auto Policy" ) )#</dd>
		</dl>

		<hr />
	</cfloop>
</cfoutput>