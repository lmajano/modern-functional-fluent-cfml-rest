component extends="tests.resources.BaseTest" {

	function run(){
		describe( "Rants V1 API Handler", function(){
			beforeEach( function( currentSpec ){
				// Setup as a new ColdBox request for this suite, VERY IMPORTANT. ELSE EVERYTHING LOOKS LIKE THE SAME REQUEST.
				setup();
			} );

			story( "Get a list of Rants", function(){
				given( "I make a get call to /api/v1/rants/list", function(){
					when( "I have no search filters", function(){
						then( "I will get a list of Rants", function(){
							var event        = get( "/api/v1/rants/list" );
							var returnedJSON = event.getRenderData().data;
							//debug( returnedJSON );
							expect( returnedJSON.error ).toBeFalse();
							expect( returnedJSON.data ).toHaveLengthGTE( 1 );
						} );
					} );
				} );
			} );

			story( "Get an individual Rant", function(){
				given( "I make a get call to /api/v1/rants/view", function(){
					when( "I pass an no rantID", function(){
						then( "I will get a 412 error", function(){
							var event        = get( "/api/v1/rants/view" );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatusCode( 412 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "rantID is required" );
						} );
					} );

					when( "I pass an invalid rantID", function(){
						then( "I will get a 412 error", function(){
							var event        = get( "/api/v1/rants/view?rantID=abc" );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatusCode( 412 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "rantID must be a UUID" );
						} );
					} );

					when( "I pass a valid but non existing rantID", function(){
						then( "I will get a 404 error", function(){
							var event        = get( "/api/v1/rants/view?rantID=#createUUID()#" );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatusCode( 404 );
							expect( returnedJSON.messages[ 1 ] ).toMatch( "Rant not found" );
						} );
					} );

					when( "I pass a valid and existing rantID", function(){
						then( "I will get a single Rant returned", function(){
							var testRantId   = queryExecute( "select id from rants limit 1" ).id;
							var event        = get( "/api/v1/rants/view?rantID=#testRantId#" );
							var returnedJSON = event.getRenderData().data;
							//debug( returnedJSON );
							expect( returnedJSON.error ).toBeFalse();
							expect( event ).toHaveStatusCode( 200 );
							expect( returnedJSON.data ).toHaveKeyWithCase( "ID" );
							expect( returnedJSON.data.id ).toBe( testRantId );
							expect( returnedJSON.messages ).toHaveLength( 0 );
						} );
					} );
				} );
			} );

			story( "Create a Rant", function(){
				given( "I make a get call to /api/v1/rants/create", function(){
					when( "Using a get method", function(){
						then( "I will get a 412 error", function(){
							var event        = get( "/api/v1/rants/create" );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatusCode( 405 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "InvalidHTTPMethod Execution of (create): GET" );
						} );
					} );

					when( "Including no body param", function(){
						then( "I will get a 412 error", function(){
							var event        = post( "/api/v1/rants/create" );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatusCode( 412 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "Rant body is required" );
						} );
					} );

					when( "Including an empty body param", function(){
						then( "I will get a 412 error", function(){
							var event        = post( "/api/v1/rants/create", { "body" : "" } );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatusCode( 412 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "Rant body cannot be empty" );
						} );
					} );

					when( "Including no userID param", function(){
						then( "I will get a 412 error", function(){
							var event        = post( "/api/v1/rants/create", { "body" : "xsxswxws" } );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatusCode( 412 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "userID is required" );
						} );
					} );

					when( "Including an empty userID param", function(){
						then( "I will get a 412 error", function(){
							var event        = post( "/api/v1/rants/create", { "body" : "xsxswxws", "userID" : "" } );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatusCode( 412 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "userID must be a UUID" );
						} );
					} );

					when( "Including a non uuid userID param", function(){
						then( "I will get a 412 error", function(){
							var event        = post( "/api/v1/rants/create", { "body" : "xsxswxws", "userID" : "abc" } );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatusCode( 412 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "userID must be a UUID" );
						} );
					} );

					when( "Including valid userID for a non existing User", function(){
						then( "I will get a 404 error", function(){
							var event = post(
								"/api/v1/rants/create",
								{ "body" : "xsxswxws", "userID" : "#createUUID()#" }
							);
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatusCode( 404 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "User not found" );
						} );
					} );

					when( "I pass a valid body and userID", function(){
						then( "I will get a successful query result with a generatedKey", function(){
							var testUserId = queryExecute( "select id from users limit 1" ).id;
							var event      = post(
								"/api/v1/rants/create",
								{
									"body"   : "I am a integration test rant! Do it!",
									"userID" : "#testUserId#"
								}
							);
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeFalse();
							expect( event.getStatusCode() ).toBe( 200 );
							expect( returnedJSON.data ).toHaveKeyWithCase( "rantID" );
							expect( returnedJSON.data.rantID ).toBeGT( 7 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "Rant Created" );
						} );
					} );
				} );
			} );

			story( "Update a Rant", function(){
				given( "I make a get call to /api/v1/rants/save", function(){
					when( "Including no body param", function(){
						then( "I will get a 412 error", function(){
							var event        = post( "/api/v1/rants/save" );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatusCode( 412 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "Rant body is required" );
						} );
					} );

					when( "Including an empty body param", function(){
						then( "I will get a 412 error", function(){
							var event        = post( "/api/v1/rants/save", { "body" : "" } );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatusCode( 412 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "Rant body cannot be empty" );
						} );
					} );

					when( "Including no rantID param", function(){
						then( "I will get a 412 error", function(){
							var event        = post( "/api/v1/rants/save", { "body" : "abc" } );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatusCode( 412 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "rantID is required" );
						} );
					} );

					when( "Including an empty rantID param", function(){
						then( "I will get a 412 error", function(){
							var event        = post( "/api/v1/rants/save", { "body" : "abc", "rantID" : "" } );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatusCode( 412 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "rantID must be a UUID" );
						} );
					} );

					when( "Including a non UUID rantID param", function(){
						then( "I will get a 412 error", function(){
							var event        = post( "/api/v1/rants/save", { "body" : "abc", "rantID" : "abc" } );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatusCode( 412 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "rantID must be a UUID" );
						} );
					} );

					when( "Including valid rantID for a non existing Rant", function(){
						then( "I will get a 404 error", function(){
							var event = post(
								"/api/v1/rants/save",
								{ "body" : "xsxswxws", "rantID" : "#createUUID()#" }
							);
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatusCode( 404 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "Rant not found" );
						} );
					} );

					when( "Including no userID param and a valid rant ID", function(){
						then( "I will get a 412 error", function(){
							var testRant = queryExecute( "select id,userId from rants limit 1" );
							var event    = post(
								"/api/v1/rants/save",
								{ "body" : "xsxswxws", "rantID" : "#testRant.id#" }
							);
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatusCode( 412 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "userID is required" );
						} );
					} );

					when( "Including an empty userID param and valid rantId", function(){
						then( "I will get a 412 error", function(){
							var testRant = queryExecute( "select id,userId from rants limit 1" );
							var event    = post(
								"/api/v1/rants/save",
								{
									"body"   : "xsxswxws",
									"rantID" : "#testRant.id#",
									"userID" : ""
								}
							);
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatusCode( 412 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "userID must be a UUID" );
						} );
					} );

					when( "Including a non UUID userID param and a valid rant Id", function(){
						then( "I will get a 412 error", function(){
							var testRant = queryExecute( "select id,userId from rants limit 1" );
							var event    = post(
								"/api/v1/rants/save",
								{
									"body"   : "xsxswxws",
									"rantID" : "#testRant.id#",
									"userID" : "abc"
								}
							);
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatusCode( 412 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "userID must be a UUID" );
						} );
					} );

					when( "Including valid userID for a non existing User and a valid rantId", function(){
						then( "I will get a 404 error", function(){
							var testRant = queryExecute( "select id,userId from rants limit 1" );
							var event    = post(
								"/api/v1/rants/save",
								{
									"body"   : "xsxswxws",
									"rantID" : "#testRant.id#",
									"userID" : "#createUUID()#"
								}
							);
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatusCode( 404 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "User not found" );
						} );
					} );

					when( "I pass a valid body and userID and rantID", function(){
						then( "I will update the Rant Successfully", function(){
							var testRant = queryExecute( "select id,userId from rants limit 1" );
							var event    = post(
								"/api/v1/rants/save",
								{
									"body"   : "xsxswxws",
									"rantID" : "#testRant.id#",
									"userID" : "#testRant.userId#"
								}
							);
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeFalse();
							expect( event.getStatusCode() ).toBe( 200 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "Rant Updated" );
						} );
					} );
				} );
			} );

			story( "Delete a Rant", function(){
				given( "I make a get call to /api/v1/rants/delete", function(){
					when( "Using a get method", function(){
						then( "I will get a 412 error", function(){
							var event        = get( "/api/v1/rants/delete" );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatusCode( 405 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "InvalidHTTPMethod Execution of (delete): GET" );
						} );
					} );

					when( "Using a post method", function(){
						then( "I will get a 412 error", function(){
							var event        = post( "/api/v1/rants/delete" );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatusCode( 405 );
							expect( returnedJSON.messages[ 1 ] ).toBe(
								"InvalidHTTPMethod Execution of (delete): POST"
							);
						} );
					} );

					when( "Including no rantID param", function(){
						then( "I will get a 412 error", function(){
							var event        = delete( "/api/v1/rants/delete", { "body" : "abc" } );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatusCode( 412 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "rantID is required" );
						} );
					} );

					when( "Including an empty rantID param", function(){
						then( "I will get a 412 error", function(){
							var event        = delete( "/api/v1/rants/delete", { "rantID" : "" } );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatusCode( 412 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "rantID must be a UUID" );
						} );
					} );

					when( "Including a non UUID rantID param", function(){
						then( "I will get a 412 error", function(){
							var event        = delete( "/api/v1/rants/delete", { "rantID" : "abc" } );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatusCode( 412 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "rantID must be a UUID" );
						} );
					} );

					when( "Including valid rantID for a non existing Rant", function(){
						then( "I will get a 404 error", function(){
							var event        = delete( "/api/v1/rants/delete", { "rantID" : "#createUUID()#" } );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatusCode( 404 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "Rant not found" );
						} );
					} );

					when( "I pass a valid rantID", function(){
						then( "I will delete the rant successfully", function(){
							var testUserId = queryExecute( "select id from users limit 1" ).id;
							var testRantId = getInstance( "RantService@v1" ).create(
								"my integration test",
								testUserId
							).generatedKey;

							var event        = delete( "/api/v1/rants/delete", { "rantID" : testRantId } );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeFalse();
							expect( event.getStatusCode() ).toBe( 200 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "Rant Deleted" );
						} );
					} );
				} );
			} );
		} );
	}

}
