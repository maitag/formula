class Test {
	
	static function main(){
		var r = new haxe.unit.TestRunner();
		
		r.add(new TestTermNode());
		r.add(new TestFormula());
		
		// run the tests
		r.run();
	}
}