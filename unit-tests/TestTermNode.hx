class TestTermNode extends haxe.unit.TestCase
{
	public function testValue()
	{
		var a:TermNode  = TermNode.newValue(2.0);
		assertTrue(a.isValue);
		assertEquals(a.result, 2.0);
	}
	
	function opResult(symbol:String, ?left:Float, ?right:Float):Float {
		return TermNode.newOperation(symbol,
			(left != null)  ? TermNode.newValue(left)  : null,
			(right != null) ? TermNode.newValue(right) : null
		).result;
	}
	public function testOperations()
	{
		assertEquals(opResult('+', 3, 2), 5);		
		assertEquals(opResult('-', 3, 2), 1);		
		assertEquals(opResult('*', 3, 2), 6);		
		assertEquals(opResult('/', 3, 2), 1.5);		
		assertEquals(opResult('^', 3, 2), 9);		
		assertEquals(opResult('%', 3, 2), 1);		
		
		assertEquals(opResult('sin', 0), 0);
		assertEquals(opResult('sin', Math.PI), Math.sin(Math.PI));
		assertEquals(opResult('cos', 0), 1);
		assertEquals(opResult('cos', Math.PI), Math.cos(Math.PI));
		
		assertEquals(opResult('abs',  1.23), 1.23);
		assertEquals(opResult('abs', -1.23), 1.23);
		
		assertEquals(opResult('pi'), Math.PI);
		assertEquals(opResult('e'), Math.exp(1));
		
	}
	
	function equal(a:String, b:String, ?compareNames=false, ?compareParams=false):Bool {
		return TermNode.fromString(a).isEqual( TermNode.fromString(b), compareNames, compareParams);
	}
	public function testEqual()
	{	
		assertTrue( equal("f:1+2" , "f:1+2" , true) );
		
		assertTrue( equal("a:1+2" , "b:1+2" ) );
		assertFalse( equal("a:1+2" , "b:1+2" , true) );
		
		assertTrue( equal("1+a" , "1+b" ) );
		assertFalse( equal("1+a" , "1+b" ,false , true) );
		
		assertTrue( equal("1+2" , "1+2") );
		assertTrue( equal("1+2*3" , "1+(2*3)") );
		assertTrue( equal("f: 1+a*3" , "g: 1+(b*3)") );
		
		var a:TermNode = TermNode.fromString("a: 1+2");
		var b:TermNode = TermNode.newValue(3);
		
		var f:TermNode = TermNode.fromString("f: a*b", ["a"=>a, "b"=>b] );
		var g:TermNode = TermNode.fromString("g: (1+2)*3");

		assertTrue(f.isEqual(g));		
		assertTrue(f.isEqual(TermNode.fromString("(1+2)*c", ["c"=>b])));

		// compare Names only
		assertFalse(f.isEqual(g, true));  // different names
		assertFalse(f.isEqual(TermNode.fromString("(1+2)*3"), true)); // different name (no name)
		assertTrue (f.isEqual(TermNode.fromString("f: a*c", ["a"=>a, "c"=>b]), true)); // same name "f"
		
		// compare Params only		  
		assertFalse(f.isEqual(g, false, true));
		assertTrue(f.isEqual(TermNode.fromString("g: a*b", ["a" => a, "b" => b]), false, true));
		
		// compare Names and Params
		assertFalse(f.isEqual(g, true, true));
		assertFalse(f.isEqual(TermNode.fromString("f: a*c", ["a"=>a, "c"=>b]), true, true));
		assertTrue(f.isEqual(TermNode.fromString("f: a*b", ["a"=>a, "b"=>b]), true, true));
	}
	
	
	function fromString(s:String):String {
		return TermNode.fromString(s).toString();
	}
	public function testFromString()
	{
		assertEquals(fromString(" 3"), "3");
		assertEquals(fromString("+3"), "3");
		assertEquals(fromString("-3"), "-3");
		assertEquals(fromString("--3"), "3");
		assertEquals(fromString("---3"), "-3");
		assertEquals(fromString("1.5 "), "1.5");
		assertEquals(fromString("1.50"), "1.5");
		assertEquals(fromString("10.5"), "10.5");
		assertEquals(fromString("1 + 2"), "1+2");
		assertEquals(fromString("1+2*3"), "1+(2*3)");
		assertEquals(fromString("- (1 + 2)"), "-(1+2)");
		assertEquals(fromString("(1 + 2)"), "1+2");
		assertEquals(fromString("--(1 + 2)"), "1+2");
		assertEquals(fromString("-++- +- (1 + 2)"), "-(1+2)");
		assertEquals(fromString("+ (1 + 2)"), "1+2");
		assertEquals(fromString("sin(x) "), "sin(x)");
		assertEquals(fromString("- sin(x)"), "-sin(x)");
		assertEquals(fromString("+ sin(x)"), "sin(x)");
		assertEquals(fromString("cos(x+1)"), "cos(x+1)");
		assertEquals(fromString("tan( x )"), "tan(x)");
		assertEquals(fromString("asin(x)"), "asin(x)");
		assertEquals(fromString("acos(x)"), "acos(x)");
		assertEquals(fromString("atan(x)"), "atan(x)");
		assertEquals(fromString("atan2(x,y)"), "atan2(x,y)");
		assertEquals(fromString("log(2,x)"), "log(2,x)");
		assertEquals(fromString("max(2,3 )"), "max(2,3)");
		assertEquals(fromString("min( 2,3)"), "min(2,3)");
		assertEquals(fromString("abs( --  - 1 )"), "abs(-1)");
		assertEquals(fromString("abs( - -- x )"), "abs(-x)");
		assertEquals(fromString("1+a ^ x*3"), "1+((a^x)*3)");
		assertEquals(fromString("a^ b^ c"), "(a^b)^c");
		assertEquals(fromString("a/b/ c"), "(a/b)/c");
		assertEquals(fromString("a/b *c"), "(a/b)*c");
		assertEquals(fromString("a /b*c+1"), "((a/b)*c)+1");
	}
	
	function errorFromString(s:String):Int {
		var e:Int = 0;
		try TermNode.fromString(s) catch (error:Dynamic) e = 1;
		return e;
	}
	public function testErrorFromString()
	{
		assertEquals(errorFromString("+*3"), 1);
		assertEquals(errorFromString("-*3"), 1);
		assertEquals(errorFromString("((1+2*3)"), 1);
		assertEquals(errorFromString("(1+(2*3)+(4-5)"), 1);
		assertEquals(errorFromString("1+(2*3))"), 1);
		assertEquals(errorFromString("()"), 1);
		assertEquals(errorFromString("1+"), 1);
		assertEquals(errorFromString("1-"), 1);
		assertEquals(errorFromString("1*"), 1);
		assertEquals(errorFromString("1/"), 1);
		assertEquals(errorFromString("1^"), 1);
		assertEquals(errorFromString("1%"), 1);
		assertEquals(errorFromString("*1"), 1);
		assertEquals(errorFromString("/1"), 1);
		assertEquals(errorFromString("^1"), 1);
		assertEquals(errorFromString("%1"), 1);
		assertEquals(errorFromString("a1"), 1);
		assertEquals(errorFromString("sin (3)"), 1);
	}
}
