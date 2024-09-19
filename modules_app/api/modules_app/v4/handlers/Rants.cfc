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
	property name="rantService" inject="RantService@v4";
	property name="userService" inject="UserService@v4";

	/**
	 * Returns a list of Rants
	 */
	any function index( event, rc, prc ){
		prc.response.setData( rantService.list().map( rant => rant.getMemento() ) );
	}

	/**
	 * Returns a single Rant
	 */
	function show( event, rc, prc ){
		validateOrFail( target = rc, constraints = { rantId : { required : true, type : "uuid" } } );
		prc.response.setData( rantService.getOrFail( rc.rantId ).getMemento() );
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
		var rant = rantService.new();

		validateOrFail( target = rc, constraints = rant.constraints );

		userService.existsOrFail( rc.userId );

		rant.setBody( rc.body );
		rant.setUserId( rc.userId );

		rantService.create( rant );

		prc.response.setData( rant.getMemento() );
		prc.response.addMessage( "Rant created" );
	}

	/**
	 * Updates an Existing Rant
	 */
	function update( event, rc, prc ){
		validateOrFail( target = rc, constraints = { rantId : { required : true, type : "uuid" } } );

		var rant = rantService.getOrFail( rc.rantId );

		validateOrFail( target = rc, constraints = rant.constraints );

		userService.existsOrFail( rc.userId );

		rant.setBody( rc.body );
		rant.setuserId( rc.userId );

		rantService.update( rant );

		prc.response.setData( rant.getMemento() );
		prc.response.addMessage( "Rant Updated" );
	}

}
