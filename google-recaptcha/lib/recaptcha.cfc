component accessors="true" output="false" {

	property string verificationURL;
	property string challengeURL;
	property string privateKey;
	property string publicKey;

	variables.verificationURL = "http://www.google.com/recaptcha/api/verify";
	variables.challengeURL = "http://www.google.com/recaptcha/api/challenge";
	variables.privateKey = "";
	variables.publicKey = "";

	public function init(
		string verificationURL = variables.verificationURL,
		string challengeURL = variables.challengeURL,
		string privateKey = variables.privateKey,
		string publicKey = variables.publicKey
	) {
		variables.verificationURL = arguments.verificationURL;
		variables.challengeURL = arguments.challengeURL;
		variables.privateKey = arguments.privateKey;
		variables.publicKey = arguments.publicKey;

		return this;
	}

	/**
	* @hint Returns the HTML to display the recaptcha
	* @theme 'red' | 'white' | 'blackglass' | 'clean' | 'custom'
	**/
	public string function getHTML(
		string theme = "clean",
		numeric tabIndex = 0,
		string lang = "en",
		string widget = "",
		string widgetID = "recaptcha_widget"
	) {
		local.html = "
			<script type=""text/javascript"">
				var RecaptchaOptions = {
					theme: '#esapiEncode("javascript", arguments.theme)#',
					custom_theme_widget: '#esapiEncode("javascript", arguments.widgetID)#',
					tabindex: #arguments.tabIndex#,
					lang: '#esapiEncode("javascript", arguments.lang)#'
				};
			</script>
			<script type=""text/javascript"" src=""#this.getChallengeURL()#?k=#this.getPublicKey()#""></script>
			#arguments.widget#
		";

		return local.html.trim();
	}

	public struct function verifyAnswer(
		required string clientIPAddress,
		required string challenge,
		required string response
	) {
		local.response = {
			isValid: false,
			response: []
		};

		if (
			arguments.challenge.trim().len() &&
			arguments.response.trim().len()
		) {
			try {
				http method="post" url=this.getVerificationURL() timeout=5 throwOnError=true result="local.rs" {
					httpparam type="form" name="privatekey" value=this.getPrivateKey();
					httpparam type="form" name="remoteip" value=arguments.clientIPAddress;
					httpparam type="form" name="challenge" value=arguments.challenge;
					httpparam type="form" name="response" value=arguments.response;
				}

				local.httpResponse = listToArray(local.rs.fileContent, chr(10));
				if (local.httpResponse.len() && isValid("boolean", local.httpResponse[1])) {
					local.response.isValid = local.httpResponse[1];
					local.httpResponse.deleteAt(1);
				}
				local.response.response = local.httpResponse;
			} catch(e) {
				local.response.response.append("Failed to communicate with #this.getVerificationURL()#");
			}
		}

		return local.response;
	}

}