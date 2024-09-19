component extends="tests.resources.BaseTest" {

	function run(){
		describe( "Rants V2 API Handler", function(){
			beforeEach( function( currentSpec ){
				// Setup as a new ColdBox request for this suite, VERY IMPORTANT. ELSE EVERYTHING LOOKS LIKE THE SAME REQUEST.
				setup();
			} );

			story( "Get a list of Rants", function(){
				given( "I make a get call to /api/v2/rants", function(){
					when( "I have no search filters", function(){
						then( "I will get a list of Rants", function(){
							var event        = get( "/api/v2/rants" );
							var returnedJSON = event.getRenderData().data;
							expect( structKeyExists( returnedJSON, "error" ) ).toBeTrue();
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeFalse();
							expect( returnedJSON ).toHaveKeyWithCase( "data" );
							expect( returnedJSON.data ).toBeArray();
							expect( returnedJSON.data ).toHaveLengthGTE( 1 );
						} );
					} );
				} );
			} );

			story( "Get an individual Rant", function(){
				given( "I make a get call to /api/v2/rants/:rantID", function(){
					when( "I pass an invalid rantID", function(){
						then( "I will get a 412 error", function(){
							var rantID       = "x"
							var event        = get( "/api/v2/rants/#rantID#" );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatus( 412 );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe(
								"The 'RANTID' has an invalid type, expected type is uuid"
							);
						} );
					} );

					when( "I pass a valid but non existing rantID", function(){
						then( "I will get a 404 error", function(){
							var rantID       = createUUID();
							var event        = get( "/api/v2/rants/#rantID#" );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatus( 404 );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toMatch( "Rant not found" );
						} );
					} );

					when( "I pass a valid and existing rantID", function(){
						then( "I will get a single Rant returned", function(){
							var testRantId   = queryExecute( "select id from rants limit 1" ).id;
							var event        = get( "/api/v2/rants/#testRantId#" );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeFalse();
							expect( event ).toHaveStatus( 200 );
							expect( returnedJSON ).toHaveKeyWithCase( "data" );
							expect( returnedJSON.data ).toBeStruct();
							expect( returnedJSON.data ).toHaveKeyWithCase( "ID" );
							expect( returnedJSON.data.id ).toBe( testRantId );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLength( 0 );
						} );
					} );
				} );
			} );

			story( "Create a Rant", function(){
				given( "I make a get call to /api/v2/rants/create", function(){
					when( "Using a get method", function(){
						then( "I will get a 412 error", function(){
							var event        = get( "/api/v2/rants/create" );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatus( 405 );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "InvalidHTTPMethod Execution of (create): GET" );
						} );
					} );

					when( "Including no userID param", function(){
						then( "I will get a 412 error", function(){
							var event        = post( "/api/v2/rants/create", {} );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatus( 412 );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "The 'USERID' value is required" );
						} );
					} );

					when( "Including an empty userID param", function(){
						then( "I will get a 412 error", function(){
							var event        = post( "/api/v2/rants/create", { "userID" : "" } );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatus( 412 );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "The 'USERID' value is required" );
						} );
					} );

					when( "Including a non numeric userID param", function(){
						then( "I will get a 412 error", function(){
							var event        = post( "/api/v2/rants/create", { "userID" : "abc" } );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatus( 412 );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe(
								"The 'USERID' has an invalid type, expected type is uuid"
							);
						} );
					} );

					when( "Including no body param", function(){
						then( "I will get a 412 error", function(){
							var event        = post( "/api/v2/rants/create", { "userID" : createUUID() } );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatus( 412 );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "The 'BODY' value is required" );
						} );
					} );

					when( "Including an empty body param", function(){
						then( "I will get a 412 error", function(){
							var event        = post( "/api/v2/rants/create", { "userID" : createUUID(), "body" : "" } );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatus( 412 );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "The 'BODY' value is required" );
						} );
					} );

					when( "Including valid userID for a non existing User", function(){
						then( "I will get a 404 error", function(){
							var event = post(
								"/api/v2/rants/create",
								{ "body" : "xsxswxws", "userID" : createUUID() }
							);
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatus( 404 );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "User not found" );
						} );
					} );

					when( "I pass a valid body and userID", function(){
						then( "I will get a successful query result with a generatedKey", function(){
							var testUserId = queryExecute( "select id from users limit 1" ).id;
							var event      = post(
								"/api/v2/rants/create",
								{ "body" : "xsxswxws", "userID" : "#testUserId#" }
							);
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeFalse();
							expect( event.getStatusCode() ).toBe( 200 );
							expect( returnedJSON ).toHaveKeyWithCase( "data" );
							expect( returnedJSON.data ).toBeStruct();
							expect( returnedJSON.data ).toHaveKeyWithCase( "rantId" );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "Rant Created" );
						} );
					} );
				} );
			} );

			story( "Update a Rant", function(){
				beforeEach( function( currentSpec ){
					testRant = queryExecute( "select id,userId from rants limit 1" );
				} );

				given( "I make a get call to /api/v2/rants/:rantID/save", function(){
					when( "Using a get method", function(){
						then( "I will get a 412 error", function(){
							var event        = get( "/api/v2/rants/#testRant.id#/save" );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatus( 405 );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "InvalidHTTPMethod Execution of (save): GET" );
						} );
					} );

					when( "Including no userID param", function(){
						then( "I will get a 412 error", function(){
							var event        = put( "/api/v2/rants/#testRant.id#/save", {} );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatus( 412 );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "The 'USERID' value is required" );
						} );
					} );

					when( "Including an empty userID param", function(){
						then( "I will get a 412 error", function(){
							var event        = put( "/api/v2/rants/#testRant.id#/save", { "userID" : "" } );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatus( 412 );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "The 'USERID' value is required" );
						} );
					} );

					when( "Including a non numeric userID param", function(){
						then( "I will get a 412 error", function(){
							var rantID       = createUUID();
							var event        = put( "/api/v2/rants/#rantID#/save", { "userID" : "abc" } );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatus( 412 );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe(
								"The 'USERID' has an invalid type, expected type is uuid"
							);
						} );
					} );

					when( "Including no body param", function(){
						then( "I will get a 412 error", function(){
							var event        = put( "/api/v2/rants/#testRant.id#/save", { "userID" : createUUID() } );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatus( 412 );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "The 'BODY' value is required" );
						} );
					} );

					when( "Including an empty body param", function(){
						then( "I will get a 412 error", function(){
							var event = put(
								"/api/v2/rants/#testRant.id#/save",
								{ "userID" : createUUID(), "body" : "" }
							);
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatus( 412 );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "The 'BODY' value is required" );
						} );
					} );

					when( "Including a non UUID rantID param", function(){
						then( "I will get a 412 error", function(){
							var event = put(
								"/api/v2/rants/abcdddd/save",
								{ "userID" : createUUID(), "body" : "abc" }
							);
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatus( 412 );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe(
								"The 'RANTID' has an invalid type, expected type is uuid"
							);
						} );
					} );

					when( "Including valid userID for a non existing User", function(){
						then( "I will get a 404 error", function(){
							var event = put(
								"/api/v2/rants/#testRant.id#/save",
								{ "body" : "xsxswxws", "userID" : createUUID() }
							);
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatus( 404 );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "User not found" );
						} );
					} );

					when( "Including valid rantID for a non existing Rant", function(){
						then( "I will get a 404 error", function(){
							var event = put(
								"/api/v2/rants/#createUUID()#/save",
								{ "userID" : createUUID(), "body" : "xsxswxws" }
							);
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatus( 404 );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "Rant not found" );
						} );
					} );

					when( "I pass a valid body and userID and rantID", function(){
						then( "I will update the Rant Successfully", function(){
							var event = put(
								"/api/v2/rants/#testRant.id#/save",
								{
									"body"   : "Updated by my magic integration test",
									"userID" : testRant.userId
								}
							);
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeFalse();
							expect( event.getStatusCode() ).toBe( 200 );
							expect( returnedJSON ).toHaveKeyWithCase( "data" );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "Rant Updated" );
						} );
					} );
				} );
			} );

			story( "Delete a Rant", function(){
				given( "I make a get call to /api/v2/rants/:rantID/delete", function(){
					when( "Using a get method", function(){
						then( "I will get a 412 error", function(){
							var event        = get( "/api/v2/rants/a/delete" );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatus( 405 );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "InvalidHTTPMethod Execution of (delete): GET" );
						} );
					} );

					when( "Including no rantID param", function(){
						then( "I will get a 412 error", function(){
							var event        = delete( "/api/v2/rants/delete" );
							var returnedJSON = event.getRenderData().data;
							debug( returnedJSON );
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatus( 405 );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe(
								"InvalidHTTPMethod Execution of (view): DELETE"
							);
						} );
					} );

					when( "Including an empty rantID param", function(){
						then( "I will get a 412 error", function(){
							var rantID       = "";
							var event        = delete( "/api/v2/rants/#rantID#/delete" );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatus( 405 );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe(
								"InvalidHTTPMethod Execution of (view): DELETE"
							);
						} );
					} );

					when( "Including a space for rantID param", function(){
						then( "I will get a 412 error", function(){
							var rantID       = " ";
							var event        = delete( "/api/v2/rants/#rantID#/delete" );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatus( 412 );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "The 'RANTID' value is required" );
						} );
					} );

					when( "Including a non numeric rantID param", function(){
						then( "I will get a 412 error", function(){
							var rantID       = "abc";
							var event        = delete( "/api/v2/rants/#rantID#/delete" );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatus( 412 );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe(
								"The 'RANTID' has an invalid type, expected type is uuid"
							);
						} );
					} );

					when( "Including valid rantID for a non existing Rant", function(){
						then( "I will get a 404 error", function(){
							var rantID       = createUUID();
							var event        = delete( "/api/v2/rants/#rantID#/delete" );
							var returnedJSON = event.getRenderData().data;
							debug( returnedJSON );
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatus( 404 );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "Rant not found" );
						} );
					} );

					when( "I pass a valid rantID", function(){
						then( "I will delete the rant successfully", function(){
							var testUserId = queryExecute( "select id from users limit 1" ).id;
							var testRantId = getInstance( "RantService@v2" ).create(
								"my integration test",
								testUserId
							).generatedKey;

							var event        = delete( "/api/v2/rants/#testRantID#/delete" );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeFalse();
							expect( event.getStatusCode() ).toBe( 200 );
							expect( returnedJSON ).toHaveKeyWithCase( "data" );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "Rant Deleted" );
						} );
					} );
				} );
			} );
		} );
	}

}
