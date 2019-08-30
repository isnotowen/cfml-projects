component accessors="true" {

	property environment;
	property netAddress type="java.net.InetAddress";
	property runtime type="java.lang.Runtime";
	property system type="java.lang.System";

	public server function init( required string environment ) {
		variables.environment = arguments.environment;
		variables.netAddress = createObject("java", "java.net.InetAddress");
		variables.runtime = createObject("java","java.lang.Runtime").getRuntime();
		variables.system = createObject("java","java.lang.System");

		return this;
	}

	public string function getServerName() {
		return netAddress.getLocalHost().getHostName();
	}

	public string function getServerIPAddress() {
		return netAddress.getLocalHost().getHostAddress();
	}

	public string function getIPAddress(
		required string host
	) {
		return netAddress.getByName(host).getHostAddress();
	}


	public string function getClientIPAddress(
		struct httpRequestData = getHttpRequestData()
	) {
		if (
			httpRequestData.keyExists("headers") &&
			httpRequestData.headers.keyExists("X-Forwarded-For")
		) {
			return listFirst(httpRequestData.headers["X-Forwarded-For"], ",");
		}

		return cgi.remote_addr;
	}

	public boolean function isSSLConnection(
		struct httpRequestData = getHttpRequestData()
	) {
		if (
			httpRequestData.keyExists("headers") &&
			httpRequestData.headers.keyExists("https") &&
			isBoolean(httpRequestData.headers.https) &&
			httpRequestData.headers.https
		) {
			return true;
		}

		if (
			cgi.keyExists("https") &&
			isBoolean(cgi.https) &&
			cgi.https
		) {
			return true;
		}

		if (
			cgi.keyExists("server_port_secure") &&
			isBoolean(cgi.server_port_secure) &&
			cgi.server_port_secure
		) {
			return true;
		}

		return false;
	}

	public string function getHTTPHostName() {
		return cgi.http_host;
	}

	public string function getHTTPURI(
		boolean includeQueryString = false
	) {
		return cgi.path_info & ((includeQueryString && getHTTPQueryString().len())? "?" & getHTTPQueryString() : "");
	}

	public string function getHTTPURL(
		boolean includeProtocol = true
	) {
		return (includeProtocol? "http" & (isSSLConnection()? "s" : "") & "://" : "") & getHTTPHostName() & getHTTPURI(includeQueryString: true);
	}

	public string function getHTTPQueryString() {
		return cgi.query_string;
	}
}