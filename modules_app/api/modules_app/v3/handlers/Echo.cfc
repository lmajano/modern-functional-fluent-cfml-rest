/**
 * My RESTFul Event Handler which inherits from the module `api`
 */
component extends="coldbox.system.RestHandler" {

	// REST Allowed HTTP Methods Ex: this.allowedMethods = {delete='POST,DELETE',index='GET'}
	this.allowedMethods = {};

	/**
	 * Index
	 */
	any function index( event, rc, prc ){
		prc.response.setData( "Welcome to my ColdBox RESTFul Service v3" );
	}

}
