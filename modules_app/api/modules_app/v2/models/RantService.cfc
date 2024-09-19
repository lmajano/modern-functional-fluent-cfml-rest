/**
 * I am the Rant Service V2
 */
component singleton accessors="true" {

	/**
	 * Constructor
	 */
	RantService function init(){
		return this;
	}

	array function list(){
		return queryExecute(
			"select * from rants ORDER BY createdDate DESC",
			{},
			{ returnType : "array" }
		);
	}

	struct function get( required rantId ){
		return queryExecute(
			"select * from rants
				where id = :rantId
			",
			{ rantId : arguments.rantId }
		).reduce( ( result, row ) => {
			return row;
		}, {} );
	}

	function delete( required rantId ){
		queryExecute(
			"delete from rants
				where id = :rantId",
			{ rantId : arguments.rantId },
			{ result : "local.result" }
		);
		return local.result;
	}

	function create( required body, required userId ){
		var now    = now();
		var newKey = createUUID();
		queryExecute(
			"insert into rants
				set
				id  		= :rantId,
				body        = :body,
				userId      = :userId
			",
			{
				rantId : newKey,
				body   : { value : "#body#", cfsqltype : "longvarchar" },
				userId : arguments.userId
			},
			{ result : "local.result" }
		);
		local.result.generatedKey = newKey;
		return local.result;
	}

	function update( required body, required rantId ){
		var now = now();
		queryExecute(
			"update rants
				set
				body         = :body,
				updatedDate = :updatedDate
				where id     = :rantId
			",
			{
				rantId      : arguments.rantId,
				body        : { value : "#body#", cfsqltype : "longvarchar" },
				updatedDate : { value : "#now#", cfsqltype : "timestamp" }
			},
			{ result : "local.result" }
		);
		return local.result;
	}

	boolean function exists( required rantId ){
		return booleanFormat(
			queryExecute(
				"select id from rants
					where id = :rantId",
				{ rantId : arguments.rantId }
			).len()
		)
	}

}
