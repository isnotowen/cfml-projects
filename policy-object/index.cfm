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
				<dt>#option.getFormattedValue()#</dt>
			</dl>
		</cfloop>

		<h1>Is Policy Type</h1>

		<dl>
			<dt>Is Homeowner Policy?</dt>
			<dd>#policy.isType( "Homeowner Policy" ).yesNoFormat()#</dd>
		</dl>

		<dl>
			<dt>Is Auto Policy?</dt>
			<dd>#policy.isType( "Auto Policy" ).yesNoFormat()#</dd>
		</dl>

		<hr />
	</cfloop>
</cfoutput>