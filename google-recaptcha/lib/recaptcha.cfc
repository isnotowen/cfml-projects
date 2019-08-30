component accessors="true" output="false" {
	/*
		Copyright (c) 2016 Owen Thomas Knapp

		Licensed under the Apache License, Version 2.0 (the "License");
		you may not use this file except in compliance with the License.
		You may obtain a copy of the License at

			http://www.apache.org/licenses/LICENSE-2.0

		Unless required by applicable law or agreed to in writing, software
		distributed under the License is distributed on an "AS IS" BASIS,
		WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
		See the License for the specific language governing permissions and
		limitations under the License.
	*/

	property string verificationURL;
	property string siteKey;
	property string secretKey;
	property boolean enableInvisible;

	variables.verificationURL = "https://www.google.com/recaptcha/api/siteverify";
	variables.siteKey = "";
	variables.secretKey = "";
	variables.enableInvisible = false;

	public function init(
		string verificationURL = variables.verificationURL,
		string siteKey = variables.siteKey,
		string secretKey = variables.secretKey,
		boolean enableInvisible = variables.enableInvisible
	) {
		variables.verificationURL = arguments.verificationURL;
		variables.siteKey = arguments.siteKey;
		variables.secretKey = arguments.secretKey;
		variables.enableInvisible = arguments.enableInvisible;

		return this;
	}

	/**
	* @hint Returns the HTML to display the recaptcha
	* @theme 'light' | 'dark'
	**/
	public string function getHTML(
		string theme = "light"
	) {
		local.html = "
			<script src=""https://www.google.com/recaptcha/api.js"" async defer></script>
			<div class=""g-recaptcha"" data-sitekey=""#this.getSiteKey()#"" data-theme=""#esapiEncode("html_attr", arguments.theme)#""></div>
		";

		return local.html.trim();
	}

	public string function getButton(
		string value = "Submit",
		string callback
	) {
		local.html = "
			<script src=""https://www.google.com/recaptcha/api.js"" async defer></script>
		";

		local.button = "<button data-sitekey=""#this.getSiteKey()#""";

		if (arguments.keyExists("class")) {
			arguments.class &= " g-recaptcha";
		} else {
			arguments.class = "g-recaptcha";
		}

		for (local.argument in arguments) {
			if (! local.argument.listFindNoCase("callback")) {
				local.button &= " " & local.argument & "=""" & encodeForHTMLAttribute(arguments[local.argument]) & """";
			}
		}

		if (arguments.keyExists("callback")) {
			local.button &= " data-callback=""" & encodeForHTMLAttribute(arguments.callback) & """";
		} else {
			local.html = "
				<script>
					var __recaptchaSubmit = function(o) {
						$('button.g-recaptcha').closest('form').trigger('submit');
					};
				</script>
			";

			local.button &= " data-callback=""__recaptchaSubmit""" ;
		}

		local.button &= ">" & arguments.value & "</button>";
		local.html &= local.button;

		return local.html.replace(chr(10), "", "all").trim();
	}

	public string function getFieldName() {
		return "g-recaptcha-response";
	}

	public struct function verifyAnswer(
		required string clientIPAddress,
		required string response
	) {
		local.response = {
			isValid: false,
			response: []
		};

		if (
			arguments.response.trim().len()
		) {
			try {
				http method="get" url=this.getVerificationURL() timeout=5 throwOnError=true result="local.rs" {
					httpparam type="url" name="secret" value=this.getSecretKey();
					httpparam type="url" name="remoteip" value=arguments.clientIPAddress;
					httpparam type="url" name="response" value=arguments.response;
				}

				local.rs = deserializeJSON(local.rs.fileContent);

				local.response.isValid = local.rs.success;
			} catch(e) {
				local.response.response.append("Failed to communicate with #this.getVerificationURL()#");
			}
		}

		return local.response;
	}

}