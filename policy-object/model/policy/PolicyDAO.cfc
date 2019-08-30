component accessors="true" singleton="true" {

	property array data; // fake property to hold data instead of hitting a database or cache server

	// Constructor
	public function init() {
		// Read in the fake data from JSON & convert to native cfml
		setData( deserializeJSON( fileRead( expandPath( "data/policies.json" ) ) ) );

		return this;
	}

	package function read( required string policyNumber ) {
		// Filter our data down to the policy in question and reduce it to a struct
		var policyData = getData()
			.filter(
				function( policy ) {
					return policy.policyNumber == policyNumber;
				}
			)
			.reduce(
				function( policyData = {}, policy ) {
					return policy;
				}
			)
		;

		// If policyData is NULL then there was no matching policy. For demo, lets throw an error
		if ( isNull( policyData ) ) {
			throw( "No matching policy for policy number: " & arguments.policyNumber );
		}

		// Set our policy bean
		var policy = new model.policy.beans.policy(
			policyNumber: policyData.policyNumber,
			dateEffective: policyData.dateEffective,
			dateExpires: policyData.dateExpires,
			type: new model.policy.beans.policyType(
				name: policyData.type.name,
				description: policyData.type.description,
				availableOptions: [] // this would come from some other set of data not represented here
			),
			// Map our options to the policyOption bean
			options: policyData.options.map(
				function( option ) {
					return new model.policy.beans.policyOption( option );
				}
			)
		);

		return policy;
	}

}