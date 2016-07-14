/** 
* test
* comment
*/
component {

	/**
	* test
	* comment
	*/
	function iGetCalled() {
		// single line comment
		/*  multi
			line
			comment */
		
		var variableDeclaration = 'foo';
		if( true ) {
			var firstHalf = 0;
		} else {
			var firstHalf = 0;			
		}
		anotherMethodCall();
		return;
	}


	/**
	* test
	* comment
	*/
	function iDoNotGetCalled() {
		var variableDeclaration = 'foo';
		return false;
	}

	/**
	* test
	* comment
	*/
	function anotherMethodCall() {
		var result = [
			'a',
			'b',
			'c',
			'd'
		];
		return result;
	}
		
}