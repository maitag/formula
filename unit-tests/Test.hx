class Test {
	
	static function main(){
		var r = new haxe.unit.TestRunner();
		
		r.add(new TestTermNode());
		r.add(new TestFormula());
		r.add(new TestTermDerivate());
		r.add(new TestTermTransform());
		r.add(new TestIntegrate());

		// run the tests
		r.run();
	}
}
