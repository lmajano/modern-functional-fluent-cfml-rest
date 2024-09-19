component extends="tests.resources.BaseTest" {

	function run(){
		describe( "Rants V3 API Handler", function(){
			beforeEach( function( currentSpec ){
				// Setup as a new ColdBox request for this suite, VERY IMPORTANT. ELSE EVERYTHING LOOKS LIKE THE SAME REQUEST.
				setup();
			} );

			story( "Get a list of Rants", function(){
				given( "I make a get call to /api/v3/rants", function(){
					when( "I have no search filters", function(){
						then( "I will get a list of Rants", function(){
							var event        = get( "/api/v3/rants" );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeFalse();
							expect( returnedJSON.data ).toBeArray();
							expect( returnedJSON.data ).toHaveLengthGTE( 1 );
						} );
					} );
				} );
			} );

			story( "Get an individual Rant", function(){
				given( "I make a get call to /api/v3/rants/:rantID", function(){
					when( "I pass an invalid rantID", function(){
						then( "I will get a 400 error", function(){
							var rantID       = "x"
							var event        = get( "/api/v3/rants/#rantID#" );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatus( 400 );
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
						} );
					} );

					when( "I pass a valid but non existing rantID", function(){
						then( "I will get a 404 error", function(){
							var rantID       = createUUID();
							var event        = get( "/api/v3/rants/#rantID#" );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatus( 404 );
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toInclude( "rant not found" );
						} );
					} );

					when( "I pass a valid and existing rantID", function(){
						then( "I will get a single Rant returned", function(){
							var testRantId   = queryExecute( "select id from rants limit 1" ).id;
							var event        = get( "/api/v3/rants/#testRantId#" );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeFalse();
							expect( event ).toHaveStatus( 200 );
							expect( returnedJSON.data ).toBeStruct();
							expect( returnedJSON.data ).toHaveKey( "ID" );
							expect( returnedJSON.data.id ).toBe( testRantId );
							expect( returnedJSON.messages ).toHaveLength( 0 );
						} );
					} );
				} );
			} );

			story( "Create a Rant", function(){
				given( "I make a post call to /api/v3/rants", function(){
					when( "Using a get method", function(){
						then( "I will hit the index action instead of the create action", function(){
							var event = get( "/api/v3/rants" );
							expect( event.getCurrentAction() ).toBe(
								"index",
								"Expected to hit index action not [#event.getCurrentAction()#] action"
							);
						} );
					} );

					when( "Including no userID param", function(){
						then( "I will get a 400 error", function(){
							var event        = post( "/api/v3/rants", {} );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatus( 400 );
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
						} );
					} );

					when( "Including an empty userID param", function(){
						then( "I will get a 400 error", function(){
							var event        = post( "/api/v3/rants", { "userID" : "" } );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatus( 400 );
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
						} );
					} );

					when( "Including a non uuid userID param", function(){
						then( "I will get a 400 error", function(){
							var event        = post( "/api/v3/rants", { "userID" : "abc" } );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatus( 400 );
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
						} );
					} );

					when( "Including no body param", function(){
						then( "I will get a 400 error", function(){
							var event        = post( "/api/v3/rants", { "userID" : "5" } );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatus( 400 );
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
						} );
					} );

					when( "Including an empty body param", function(){
						then( "I will get a 400 error", function(){
							var event        = post( "/api/v3/rants", { "userID" : "5", "body" : "" } );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatus( 400 );
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
						} );
					} );

					when( "Including valid userID for a non existing User", function(){
						then( "I will get a 404 error", function(){
							var event        = post( "/api/v3/rants", { "body" : "xsxswxws", "userID" : createUUID() } );
							var returnedJSON = event.getRenderData().data;
							debug( returnedJSON );
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatus( 404 );
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toInclude( "user not found" );
						} );
					} );

					when( "I pass a valid body and userID", function(){
						then( "I will get a successful query result with a generatedKey", function(){
							var testUserId   = queryExecute( "select id from users limit 1" ).id;
							var event        = post( "/api/v3/rants", { "body" : "xsxswxws", "userID" : testUserId } );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeFalse();
							expect( event.getStatusCode() ).toBe( 200 );
							expect( returnedJSON.data ).toBeStruct();
							expect( returnedJSON.data ).toHaveKey( "rantId" );
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "Rant Created" );
						} );
					} );
				} );
			} );

			story( "Update a Rant", function(){
				given( "I make a get call to /api/v3/rants/:rantID", function(){
					when( "Using a get method", function(){
						then( "I will hit the show action instead of the update action", function(){
							var rantID = "1";
							var event  = get( "/api/v3/rants/#rantID#" );
							expect( event.getCurrentAction() ).toBe(
								"show",
								"I expect to hit show action instead of the update action due to the VERB, but I actually hit [#event.getCurrentAction()#]"
							);
						} );
					} );

					when( "Using a post method", function(){
						then( "I will hit the show action instead of the update action", function(){
							var rantID = "1";
							var event  = post( "/api/v3/rants/#rantID#" );
							expect( event.getCurrentAction() ).toBe(
								"onInvalidHTTPMethod",
								"I expect to hit onInvalidHTTPMethod action instead of the update action due to the VERB, but I actually hit [#event.getCurrentAction()#]"
							);
						} );
					} );

					when( "Including no userID param", function(){
						then( "I will get a 400 error", function(){
							var rantID       = createUUID();
							var event        = put( "/api/v3/rants/#rantID#", {} );
							var returnedJSON = event.getRenderData().data;
							debug( returnedJSON );
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatus( 400 );
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
						} );
					} );

					when( "Including an empty userID param", function(){
						then( "I will get a 400 error", function(){
							var rantID       = createUUID();
							var event        = put( "/api/v3/rants/#rantID#", { "userID" : "" } );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatus( 400 );
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
						} );
					} );

					when( "Including a non uuid userID param", function(){
						then( "I will get a 400 error", function(){
							var rantID       = createUUID();
							var event        = put( "/api/v3/rants/#rantID#", { "userID" : "abc" } );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatus( 400 );
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
						} );
					} );

					when( "Including no body param", function(){
						then( "I will get a 400 error", function(){
							var rantID       = createUUID();
							var event        = put( "/api/v3/rants/#rantID#", { "userID" : createUUID() } );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatus( 400 );
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
						} );
					} );

					when( "Including an empty body param", function(){
						then( "I will get a 400 error", function(){
							var rantID       = createUUID();
							var event        = put( "/api/v3/rants/#rantID#", { "userID" : createUUID(), "body" : "" } );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatus( 400 );
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
						} );
					} );

					when( "Including a non uuid rantID param", function(){
						then( "I will get a 400 error", function(){
							var rantID = "abc";
							var event  = put(
								"/api/v3/rants/#rantID#",
								{ "userID" : createUUID(), "body" : "abc" }
							);
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatus( 400 );
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
						} );
					} );

					when( "Including valid userID for a non existing User", function(){
						then( "I will get a 404 error", function(){
							var testRantId = queryExecute( "select id from rants limit 1" ).id;
							var event      = put(
								"/api/v3/rants/#testRantId#",
								{ "body" : "xsxswxws", "userID" : createUUID() }
							);
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatus( 404 );
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toInclude( "user not found" );
						} );
					} );

					when( "Including valid rantID for a non existing Rant", function(){
						then( "I will get a 404 error", function(){
							var event = put(
								"/api/v3/rants/#createUUID()#",
								{ "userID" : createUUID(), "body" : "xsxswxws" }
							);
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatus( 404 );
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toInclude( "rant not found" );
						} );
					} );

					when( "I pass a valid body and userID and rantID", function(){
						then( "I will update the Rant Successfully", function(){
							var testRant = queryExecute( "select id,userId from rants limit 1" );
							var event    = put(
								"/api/v3/rants/#testRant.id#",
								{ "body" : "xsxswxws", "userID" : testRant.userId }
							);
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeFalse();
							expect( event.getStatusCode() ).toBe( 200 );
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "Rant Updated" );
						} );
					} );
				} );
			} );

			story( "Delete a Rant", function(){
				given( "I make a get call to /api/v3/rants/:rantID", function(){
					when( "Using a get method", function(){
						then( "I will hit the show action instead of the update action", function(){
							var rantID = "1";
							var event  = get( "/api/v3/rants/#rantID#" );
							expect( event.getCurrentAction() ).toBe(
								"show",
								"I expect to hit show action instead of the delete action due to the VERB, but I actually hit [#event.getCurrentAction()#]"
							);
						} );
					} );

					when( "Using a post method", function(){
						then( "I will hit the show action instead of the update action", function(){
							var rantID = "1";
							var event  = post( "/api/v3/rants/#rantID#" );
							expect( event.getCurrentAction() ).toBe(
								"onInvalidHTTPMethod",
								"I expect to hit onInvalidHTTPMethod action instead of the delete action due to the VERB, but I actually hit [#event.getCurrentAction()#]"
							);
						} );
					} );

					when( "Including a space for rantID param", function(){
						then( "I will hit the index action instead of the delete action", function(){
							var rantID = " ";
							var event  = get( "/api/v3/rants/#rantID#" );
							expect( event.getCurrentAction() ).toBe(
								"index",
								"I expect to hit index action instead of the delete action due to the VERB, but I actually hit [#event.getCurrentAction()#]"
							);
						} );
					} );

					when( "Including a non uuid rantID param", function(){
						then( "I will get a 400 error", function(){
							var rantID       = "abc";
							var event        = delete( "/api/v3/rants/#rantID#" );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatus( 400 );
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
						} );
					} );

					when( "Including valid rantID for a non existing Rant", function(){
						then( "I will get a 404 error", function(){
							var rantID       = createUUID();
							var event        = delete( "/api/v3/rants/#rantID#" );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatus( 404 );
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toInclude( "rant not found" );
						} );
					} );

					when( "I pass a valid rantID", function(){
						then( "I will delete the rant successfully", function(){
							var testUserId = queryExecute( "select id from users limit 1" ).id;
							var testRantId = getInstance( "RantService@v3" ).create(
								"my integration test",
								testUserId
							).generatedKey;

							var event        = delete( "/api/v3/rants/#testRantID#/delete" );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON.error ).toBeFalse();
							expect( event.getStatusCode() ).toBe( 200 );
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "Rant Deleted" );
						} );
					} );
				} );
			} );
		} );
	}

}
