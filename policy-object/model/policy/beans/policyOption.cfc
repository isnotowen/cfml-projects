component accessors="true" transient="true" {

	property string name;
	property string dataType;
	property any value;

	public any function getFormattedValue() {
		switch( getDataType() ) {
			case "boolean": {
				return isBoolean( value ) ? yesNoFormat( value ) : value;
			}
			case "numeric": {
				return isNumeric( value ) ?  numberFormat( value ) : value;
			}
			case "array": {
				return isArray( value ) ? numberFormat( value.len() ) : value;
			}
		}

		// Return orginal value by default
		return getValue();
	}

}