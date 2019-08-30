component accessors="true" transient="true" {

	property string policyNumber;
	property model.policy.beans.policyType type;
	property date dateEffective;
	property date dateExpires;
	property array options;

	variables.type = new model.policy.beans.policyType();

	public boolean function isType( required string name ) {
		return getType().getName() == arguments.name;
	}

	public string function getFormattedDateEffective() {
		return dateFormat( getDateEffective(), "m/m/yyyy" );
	}

	public string function getFormattedDateExpires() {
		return dateFormat( getDateExpires(), "m/m/yyyy" );
	}

}