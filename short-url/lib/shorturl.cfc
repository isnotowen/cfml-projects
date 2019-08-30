component hint="Helper functions related to urls" {

	variables.instance.base58 = "DcSusTpUkxNvFBo6b4QdRhWiZgPzAf7jqJCw2EV3LMyn1H8m5rXKGe9atY".toCharArray();

	public string function getShortID( required numeric id ) {
		var alpha = variables.instance.base58;
		var base = alpha.len();
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
		var base = alpha.len();
		var value = arguments.value.reverse().toCharArray();

		return value.reduce(
			function( decoeded = 0, value ) {
				var pos = alpha.find( value );

				if ( ! pos ) {
					throw( "The value '#arguments.value#' is not a valid short ID." );
				}

				return decoded += (
					( pos - 1 )
					*
					( base ^ ( x - 1 ) )
				);
			}
		);
	}

}