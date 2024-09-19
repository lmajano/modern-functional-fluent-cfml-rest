component extends="coldbox.system.testing.BaseTestCase" appMapping="/root" {

	// Do not unload per test bundle to improve performance.
	this.unloadColdBox = false;

/*********************************** LIFE CYCLE Methods ***********************************/

	/**
	 * executes before all suites+specs in the run() method
	 */
	function beforeAll(){
		super.beforeAll();

        addMatchers( {
			toHaveLengthGT : function( expectation, args = {}, lengthTest=variables.lengthTest ) {
				args[ "operator" ] = "GT";
				return arguments.lengthTest( expectation, args );
			},

			toHaveLengthGTE : function( expectation, args = {}, lengthTest=variables.lengthTest ) {
				args[ "operator" ] = "GTE";
				return arguments.lengthTest( expectation, args );
			},

			toHaveLengthLT : function( expectation, args = {}, lengthTest=variables.lengthTest ) {
				args[ "operator" ] = "LT";
				return arguments.lengthTest( expectation, args );
			},

			toHaveLengthLTE : function( expectation, args = {}, lengthTest=variables.lengthTest ) {
				args[ "operator" ] = "LTE";
				return arguments.lengthTest( expectation, args );
			}
		} );
	}

	/**
	 * A length test
	 */
	private function lengthTest( expectation, args = {} ) {
		// handle both positional and named arguments
		param args.value = "";
		if ( structKeyExists( args, 1 ) ) {
			args.value = args[ 1 ];
		}

		param args.message = "";
		if ( structKeyExists( args, 2 ) ) {
			args.message = args[ 2 ];
		}

		param args.operator = "GT";
		if ( structKeyExists( args, 3 ) ) {
			args.value = args[ 3 ];
		}

		if ( !isNumeric( args.value )) {
			expectation.message = "The value you are testing must be a valid number";
			return false;
		}
		try{
			var length = 0;
			if ( isSimpleValue( expectation.actual ) ) {
				length = len( expectation.actual );
			}
			if ( isArray( expectation.actual ) ) {
				length = arrayLen( expectation.actual );
			}
			if ( isStruct( expectation.actual ) ) {
				length = structCount( expectation.actual );
			}
			if ( isQuery( expectation.actual ) ) {
				length = expectation.actual.recordcount;
			}

		} catch ( any e ){
			expectation.message = "The length of the Item could not be found";
			return false;
		}

		if( args.operator == "GT" && length <= args.value ){
			expectation.message = "The length of the item was #length# - that is not GT #args.value#";
			debug( expectation.actual );
			return false;
		} else if( args.operator == "GTE" && length < args.value ){
			expectation.message = "The length of the item was #length# - that is not GTE #args.value#";
			debug( expectation.actual );
			return false;
		} else if( args.operator == "LT" && length >= args.value ){
			expectation.message = "The length of the item was #length# - that is not LT #args.value#";
			debug( expectation.actual );
			return false;
		} else if( args.operator == "LTE" && length > args.value ){
			expectation.message = "The length of the item was #length# - that is not LTE #args.value#";
			debug( expectation.actual );
			return false;
		}

		return true;
	};

	/**
	 * executes after all suites+specs in the run() method
	 */
	function afterAll(){
		super.afterAll();
	}

	/**
	 * Rollback all testing, called by TestBox for me
	 *
	 * @spec The spec in test
	 * @suite The suite in test
	 */
	function withRollback( spec, suite ) aroundEach {
		transaction{
			try{
				return arguments.spec.body();
			} catch( any e ){
				rethrow;
			} finally{
				transaction action="rollback";
			}
		}
	}

}
