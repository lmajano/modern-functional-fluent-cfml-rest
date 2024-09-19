/**
 * My RESTFul Event Handler which inherits from the module `api`
 */
component extends="coldbox.system.RestHandler" {

	// REST Allowed HTTP Methods Ex: this.allowedMethods = {delete='POST,DELETE',index='GET'}
	this.allowedMethods = {};

	/**
	 * Say Hello v1
	 */
	function index( event, rc, prc ){
		event.getResponse().setData( "Welcome to my ColdBox RESTFul Service v1" );
	}

}
