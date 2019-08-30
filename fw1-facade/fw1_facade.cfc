component accessors="true" output="false" scope="singleton" hint="Provides a facade on top of existing framework that behaves like fw/1." {

	property string environment;
	property struct cache;

	public fw1_facade function init(
		required string environment,
		struct cache = {}
	) {
		setEnvironment(arguments.environment);
		setCache(arguments.cache);

		return this;
	}

	public string function execController(
		required string action hint="action to run controller item.",
		required struct scope hint="scope containing all the controller methods/items and needed variables."
	) hint="Executes Controller allowing views to be called with url/form.action." {
		// Copy variables in arguments scope to unscoped variables (allows to bleed through to includes)
		for (local.var in arguments.scope) {
			variables[local.var] = arguments.scope[local.var];
		}

		// Set default method
		local.method = arguments.scope.keyExists("defaultView")? arguments.scope.defaultView:"";

		// Set the view name
		request.fw_facade.view = arguments.action;

		// If we can _loosely_ determine the function exists (or a var with the same name), update the local method.
		if (variables.keyExists(arguments.action)) {
			local.method = variables[arguments.action];
		}

		// Get 'request context' facade
		var rc = getRC(action: arguments.action);

		// Call controller before method(s)
		this.before(rc: rc, scope: arguments.scope);

		// Attempt to execute controller method
		local.controllerMethodExecuted = this.execControllerMethod(
			method: local.method,
			rc: rc
		);

		// Get the filepath to the view/layout
		local.templatePath = getDirectoryFromPath(getBaseTemplatePath());

		// Set the 'body' for view/layout
		local.body = "";

		// Get body from view
		local.viewFilename = local.templatePath & request.fw_facade.view & ".cfm";
		if (this.fileExists(local.viewFilename)) {
			savecontent variable="local.body" {
				include getRelativePath(local.viewFilename);
			}
		} else {
			// If Controller method & view do not exist. Execute default method.
			if (
				! local.controllerMethodExecuted &&
				arguments.scope.keyExists("itemNotFound") &&
				isCustomFunction(arguments.scope.itemNotFound)
			) {
				arguments.scope.itemNotFound(rc: rc);
			}
		}

		// Include layout which can inject the 'body' from the view
		if (arguments.scope.keyExists("layout")) {
			local.layoutFilename = local.templatePath & arguments.scope.layout;
			if (this.fileExists(local.layoutFilename)) {
				savecontent variable="local.body" {
					include getRelativePath(local.layoutFilename);
				}
			}
		}

		return local.body;
	}

	public boolean function execControllerMethod(
		required any method,
		required struct rc
	) {
		if (isCustomFunction(arguments.method)) {
			local.metaData = getMetadata(arguments.method);

			// Exclude if private function
			if (
				local.metaData.keyExists("access") &&
				local.metaData.access == "private"
			) {
				return false;
			}

			request.fw_facade.view = local.metaData.name;

			try {
				arguments.method(rc: arguments.rc);
			} catch (FW.AbortControllerException e) {
				// Do nothing and let the controller method life cycle end
			} catch(any e) {
				rethrow;
			}

			return true;
		}

		return false;
	}

	public void function setView(required string view) {
		// hacked in for compat. needs work.
		request.fw_facade.view = arguments.view.listLast(".");
	}

	public void function abortController() {
		request.fw_facade.abortController = true;
		throw(
			type: "FW.AbortControllerException",
			message: "abortController() called"
		);
	}

	public void function renderData(
		string type = "",
		any data = "",
		numeric statusCode = 200
	) {
		// hacked in for compat. needs work.

		if (arguments.type == "json") {
			local.data = {
				contentType: "application/json; charset=utf-8",
				output: serializeJSON(arguments.data)
			};
		}

		if (local.keyExists("data")) {
			local.response = getPageContext().getResponse();
			local.response.setContentType(local.data.contentType);

			writeOutput(local.data.output);
			abort;
		}
	}

	package function before(
		required struct rc,
		required struct scope hint="scope containing all the controller methods/items and needed variables."
	) hint="Determines what before() methods to call, if any." {
		if (arguments.scope.keyExists("before") && isCustomFunction(arguments.scope.before)) {
			arguments.scope.before(rc: arguments.rc);
		}
	}

	private struct function getRC() hint="Fakes the 'request.context' scope for the purposes of this fw facade." {
		local.rc = {
			controller: getBaseTemplatePath()
		};

		for (local.scope in [ARGUMENTS, FORM, URL]) {
			for (local.key in local.scope) {
				if (! local.rc.keyExists(local.key)) {
					local.rc[local.key] = local.scope[local.key];
				}
			}
		}

		request.fw_facade.context = local.rc;

		return local.rc;
	}

	package boolean function fileExists(required string file hint="path to file") hint="Caches fileExists calls to componenent to ease disk reading." {
		local.cache = getCache();

		// Create file cache if it doesn't exist
		if (! local.cache.keyExists("file")) {
			lock scope="Application" timeout="5" {
				if (! local.cache.keyExists("file")) {
					local.cache.file = {};
				}
			}
		}

		// Get cacheName based on file
		local.cacheName = hash(arguments.file, "md5");

		// Add fileExists return value to cache for this file
		if (! local.cache.file.keyExists(local.cacheName)) {
			local.cache.file[local.cacheName] = fileExists(arguments.file);
		}

		return local.cache.file[local.cacheName];
	}

	/**
	 * Returns a relative path from the current template to an absolute file path.
	 * v2 fix by Tony Monast
	 * v2.1 fix by Tony Monast to deal with situations in which the specified path was the same as the current path, resulting in an error
	 * Modified to use current template path to return from page invoking this cfc
	 *
	 * @param abspath 	 Absolute path. (Required)
	 * @return Returns a string.
	 * @author Isaac Dealey (info@turnkey.to)
	 * @version 2, August 30, 2012
	 */
	private function getRelativePath(abspath) {
		var currentPath = ListToArray(GetDirectoryFromPath(getCurrentTemplatePath()),"\/");
		var filePath = ListToArray(abspath,"\/");
		var relativePath = ArrayNew(1);
		var pathStart = 0;
		var i = 0;

		/* Define the starting path (path in common) */
		for (i = 1; i LTE ArrayLen(currentPath); i = i + 1) {

				if (currentPath[i] NEQ filePath[i]) {
						pathStart = i;
						break;
				}
		}

		if (pathStart GT 0) {
				/* Build the prefix for the relative path (../../etc.) */
				for (i = ArrayLen(currentPath) - pathStart ; i GTE 0 ; i = i - 1) {
						ArrayAppend(relativePath,"..");
				}

				/* Build the relative path */
				for (i = pathStart; i LTE ArrayLen(filePath) ; i = i + 1) {
						ArrayAppend(relativePath,filePath[i]);
				}
		}

		/* Same level */
		else
				ArrayAppend(relativePath,filePath[ArrayLen(filePath)]);

		/* Return the relative path */
		return ArrayToList(relativePath,"/");
	}

}