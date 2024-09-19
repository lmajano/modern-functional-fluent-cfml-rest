/**
 * My RESTFul Rants Event Handler which inherits from the module `api`
 * Since we inherit from the RestHandler we get lots of goodies like automatic HTTP method protection,
 * missing routes, invalid routes, and much more.
 *
 * @see https://coldbox.ortusbooks.com/digging-deeper/rest-handler
 * @see https://coldbox.ortusbooks.com/digging-deeper/rest-handler#rest-handler-security
 */
component extends="coldbox.system.RestHandler" {

	// DI
	property name="rantService" inject="RantService@v3";
	property name="userService" inject="UserService@v3";

	/**
	 * Returns a list of Rants
	 */
	any function index( event, rc, prc ){
		prc.response.setData( rantService.list() );
	}

	/**
	 * Returns a single Rant
	 */
	function show( event, rc, prc ){
		validateOrFail( target = rc, constraints = { rantId : { required : true, type : "uuid" } } );
		prc.response.setData( rantService.getOrFail( rc.rantId ) );
	}

	/**
	 * Deletes a single Rant
	 */
	function delete( event, rc, prc ){
		validateOrFail( target = rc, constraints = { rantId : { required : true, type : "uuid" } } );
		rantService.existsOrFail( rc.rantId );
		rantService.delete( rc.rantId );
		prc.response.addMessage( "Rant deleted" );
	}

	/**
	 * Creates a new Rant
	 */
	function create( event, rc, prc ){
		validateOrFail(
			target      = rc,
			constraints = {
				userId : { required : true, type : "uuid" },
				body   : { required : true }
			}
		);
		userService.existsOrFail( rc.userId );
		var result = rantService.create( body = rc.body, userId = rc.userId );
		prc.response.setData( { "rantId" : result.generatedKey } );
		prc.response.addMessage( "Rant created" );
	}

	/**
	 * Updates an Existing Rant
	 */
	function update( event, rc, prc ){
		validateOrFail(
			target      = rc,
			constraints = {
				rantId : { required : true, type : "uuid" },
				body   : { required : true },
				userId : { required : true, type : "uuid" }
			}
		);

		rantService.existsOrFail( rc.rantId );
		userService.existsOrFail( rc.userId );

		rantService.update(
			body   = rc.body,
			userId = rc.userId,
			rantId = rc.rantId
		);

		prc.response.addMessage( "Rant Updated" );
	}

}
