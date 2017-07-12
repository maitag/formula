class Test {
	
	static function main(){
		var r = new haxe.unit.TestRunner();
		
		r.add(new TestTerm());
		//r.add(new TestFormula());
		
		// run the tests
		r.run();
	}
}