component hint="Helper functions related to urls" {

	variables.instance.base58 = "DcSusTpUkxNvFBo6b4QdRhWiZgPzAf7jqJCw2EV3LMyn1H8m5rXKGe9atY".toCharArray();

	public string function getShortID( required numeric id ) {
		var alpha = variables.instance.base58;
		var base = arrayLen( alpha );
		var id = arguments.id;
		var encoded = "";
		var remainder = "";

		while ( id ) {
			remainder = id - ( base * int( id / base ) );
			id = int( id / base );
			encoded = alpha[ remainder + 1 ] & encoded;
		}

		return encoded;
	}

	public numeric function readShortID( required string value ) {
		var alpha = variables.instance.base58;
		var base = arrayLen( alpha );
		var decoded = 0;
		var value = arguments.value.reverse().toCharArray();
		var pos = 0;

		for ( var x = 1; x <= arrayLen( value ); x++ ) {
			pos = arrayFind( alpha, value[x] );

			if ( ! pos ) {
				throw( "The value '#arguments.value#' is not a valid short ID." );
			}

			decoded += (
				(
					pos - 1
				)
				*
				(
					base ^ ( x - 1 )
				)
			);
		}

		return decoded;
	}

}