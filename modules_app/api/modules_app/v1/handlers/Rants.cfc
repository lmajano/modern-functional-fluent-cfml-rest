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
	property name="rantService" inject="RantService@v1";
	property name="userService" inject="UserService@v1";

	/**
	 * Returns a list of Rants
	 */
	any function list( event, rc, prc ){
		var rants = rantService.list();
		prc.response.setData( rants );
	}

	/**
	 * Returns a single Rant
	 */
	function view( event, rc, prc ){
		if ( !structKeyExists( rc, "rantId" ) ) {
			prc.response.setError( true );
			prc.response.setStatusCode( 412 );
			prc.response.addMessage( "rantId is required" );
			return;
		}
		if ( !isValid( "uuid", rc.rantId ) ) {
			prc.response.setError( true );
			prc.response.setStatusCode( 412 );
			prc.response.addMessage( "rantId must be a UUID" );
			return;
		}
		var rant = rantService.getRant( rc.rantId );

		if ( rant.recordcount ) {
			prc.response.setData( queryGetRow( rant, 1 ) );
		} else {
			prc.response.setError( true );
			prc.response.setStatusCode( 404 );
			prc.response.addMessage( "Error loading Rant - Rant not found" );
		}
	}

	/**
	 * Deletes a single Rant
	 */
	function delete( event, rc, prc ){
		if ( !structKeyExists( rc, "rantId" ) ) {
			prc.response.setError( true );
			prc.response.setStatusCode( 412 );
			prc.response.addMessage( "rantId is required" );
		} else if ( !isValid( "UUID", rc.rantId ) ) {
			prc.response.setError( true );
			prc.response.setStatusCode( 412 );
			prc.response.addMessage( "rantId must be a UUID" );
		} else {
			var result = rantService.delete( rc.rantId );
			if ( result.recordcount > 0 ) {
				prc.response.addMessage( "Rant deleted" );
			} else {
				prc.response.setError( true );
				prc.response.setStatusCode( 404 );
				prc.response.addMessage( "Rant not found" );
			}
		}
	}

	/**
	 * Creates a new Rant
	 */
	function create( event, rc, prc ){
		if ( !structKeyExists( rc, "body" ) ) {
			prc.response.setError( true );
			prc.response.setStatusCode( 412 );
			prc.response.addMessage( "Rant body is required" );
			return
		}
		if ( !rc.body.trim().len() ) {
			prc.response.setError( true );
			prc.response.setStatusCode( 412 );
			prc.response.addMessage( "Rant body cannot be empty" );
			return
		}
		if ( !structKeyExists( rc, "userId" ) ) {
			prc.response.setError( true );
			prc.response.setStatusCode( 412 );
			prc.response.addMessage( "userId is required" );
			return;
		}
		if ( !isValid( "uuid", rc.userId ) ) {
			prc.response.setError( true );
			prc.response.setStatusCode( 412 );
			prc.response.addMessage( "userId must be a UUID" );
			return;
		}
		var user = userService.get( rc.userId )
		if ( !user.recordcount ) {
			prc.response.setError( true );
			prc.response.setStatusCode( 404 );
			prc.response.addMessage( "User not found" );
			return;
		}
		var result = rantService.create( body = rc.body, userId = rc.userId );
		if ( result.recordcount ) {
			prc.response.setData( { "rantId" : result.generatedKey } );
			prc.response.addMessage( "Rant created" );
			return;
		} else {
			prc.response.setError( true );
			prc.response.setStatusCode( 500 );
			prc.response.addMessage( "Error creating Rant" );
			return;
		}
	}

	/**
	 * Updates an Existing Rant
	 */
	function save( event, rc, prc ){
		if ( !structKeyExists( rc, "body" ) ) {
			prc.response.setError( true );
			prc.response.setStatusCode( 412 );
			prc.response.addMessage( "Rant body is required" );
			return
		}
		if ( !rc.body.trim().len() ) {
			prc.response.setError( true );
			prc.response.setStatusCode( 412 );
			prc.response.addMessage( "Rant body cannot be empty" );
			return
		}
		if ( !structKeyExists( rc, "rantId" ) ) {
			prc.response.setError( true );
			prc.response.setStatusCode( 412 );
			prc.response.addMessage( "rantId is required" );
			return
		}
		if ( !isValid( "uuid", rc.rantId ) ) {
			prc.response.setError( true );
			prc.response.setStatusCode( 412 );
			prc.response.addMessage( "rantId must be a UUID" );
			return
		}
		var rant = rantService.getRant( rc.rantId )
		if ( !rant.recordcount ) {
			prc.response.setError( true );
			prc.response.setStatusCode( 404 );
			prc.response.addMessage( "Rant not found" );
			return;
		}
		if ( !structKeyExists( rc, "userId" ) ) {
			prc.response.setError( true );
			prc.response.setStatusCode( 412 );
			prc.response.addMessage( "userId is required" );
			return;
		}
		if ( !isValid( "UUID", rc.userId ) ) {
			prc.response.setError( true );
			prc.response.setStatusCode( 412 );
			prc.response.addMessage( "userId must be a UUID" );
			return;
		}
		var user = userService.get( rc.userId )
		if ( !user.recordcount ) {
			prc.response.setError( true );
			prc.response.setStatusCode( 404 );
			prc.response.addMessage( "User not found" );
			return;
		}
		var result = rantService.update(
			body   = rc.body,
			userId = rc.userId,
			rantId = rc.rantId
		);
		if ( result.recordcount ) {
			prc.response.addMessage( "Rant Updated" );
		} else {
			prc.response.setError( true );
			prc.response.setStatusCode( 500 );
			prc.response.addMessage( "Error updating Rant" );
			return;
		}
	}

}
