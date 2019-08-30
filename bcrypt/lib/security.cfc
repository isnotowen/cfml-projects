component {

	property bCrypt; // requires http://bcrypt.sourceforge.net/

	public string function getSalt(numeric strength = 12) {
		return bCrypt.gensalt(arguments.strength);
	}

	public string function hashString(
		required string string,
		string salt = getSalt()
	) {
		return bCrypt.hashpw(arguments.string, arguments.salt);
	}

	public boolean function isValidStringAndHash(
		required string string,
		required string hash
	) {
		return bCrypt.checkpw(arguments.string, arguments.hash);
	}

	public string function generatePassword(
		numeric length = 8
	) hint="creates a simple alphanumeric password; will return 3 alpha chars and pad with numbers" {

		try {

			if(arguments.length < 6) {
				throw(type="InsufficientLength", message="This method will only generate passwords of 6 characters or greater")
			}

			password = "";
			alphabet = "abcdefghijkmnpqrstuvwxyz"; // excludes l and o

			// double up the alphabet list to get a fairer random distribution
			alphabet = alphabet & alphabet;

			for(i = 1; i lte 3; i++) {
				rnd = randrange(1,len(alphabet));
				password = password & mid(alphabet,rnd,1);
			}

			// get a number value and pad with zeroes as required
			rnd = randrange(9999,999999);

			password = password & right(repeatstring("0",arguments.length) & rnd,(arguments.length - len(password)));

			return password;

		}
		catch (any e) {
			rethrow;
		}

	}

}