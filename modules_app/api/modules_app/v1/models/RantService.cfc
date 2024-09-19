/**
 * I am the Rant Service V1
 */
component singleton accessors="true" {

	/**
	 * Constructor
	 */
	RantService function init(){
		return this;
	}

	function list(){
		return queryExecute( "select * from rants ORDER BY createdDate DESC", {} );
	}

	function getRant( required rantId ){
		return queryExecute(
			"select * from rants
			where id = :rantId",
			{ rantId : arguments.rantId }
		);
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
		var now   = now();
		var newId = createUUID();
		queryExecute(
			"insert into rants
				set
				id = :rantId,
				body         = :body,
				userId       = :userId
			",
			{
				rantId : newId,
				body   : { value : "#body#", cfsqltype : "varchar" },
				userId : arguments.userId
			},
			{ result : "local.result" }
		);
		local.result.generatedKey = newId;
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
				body        : { value : "#body#", cfsqltype : "varchar" },
				updatedDate : { value : "#now#", cfsqltype : "timestamp" }
			},
			{ result : "local.result" }
		);
		return local.result;
	}

}
