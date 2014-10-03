google-recaptcha
=========================

https://www.google.com/recaptcha/intro/index.html

You'll need to obtain a private and public key.

```coldfusion
recaptchaLib = new lib.recaptcha(
	privateKey: "YOUR PRIVATE KEY",
	publicKey: "YOUR PUBLIC KEY"
);

<!--- output the captcha form --->
<cfoutput>#recaptchaLib.getHTML()#</cfoutput>

<!--- verify answer --->
<cfset result = recaptchaLib.verifyAnswer(
	clientIPAddress: "127.0.0.1",
	challenge: "CHALLENGE TEXT",
	response: "RESPONSE TEXT"
)>

<cfif result.isValid>
	<!--- valid captcha response --->
</cfif>
```
