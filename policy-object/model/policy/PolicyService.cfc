component accessors="true" singleton="true" {

	property model.policy.PolicyDAO policyDAO;

	// Contructor
	public function init() {
		// Inject the PolicyDAO
		setPolicyDAO( new model.policy.PolicyDAO() );

		return this;
	}

	// Read a policy from the DAO
	public function get( required string policyNumber ) {
		return getPolicyDAO().read( policyNumber: arguments.policyNumber );
	}

}