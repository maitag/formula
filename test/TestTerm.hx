class TestTerm extends haxe.unit.TestCase
{
	public function testValue()
	{
		var a:Term  = Term.newValue(2.0);
		assertTrue(a.isValue);
	}
	/*
	public function testOperations()
	{
		var f:Term  = Term.newOperation('+', a, b);
		
		assertEquals("A", f.is);
	}*/
	
	inline function simplify(s:String):String {
		return Term.fromString(s).simplify().toString();
	}
	public function testSimplify()
	{
		assertEquals(simplify("0+x"), "x");
		assertEquals(simplify("x+0"), "x");
		assertEquals(simplify("1*x"), "x");
		assertEquals(simplify("x*1"), "x");
		assertEquals(simplify("x*0"), "0");
		assertEquals(simplify("0*x"), "0");
		assertEquals(simplify("x/1"), "x");
		assertEquals(simplify("0/x"), "0");
		assertEquals(simplify("0^x"), "0");
		assertEquals(simplify("1^x"), "1");
		assertEquals(simplify("x^0"), "1");
		assertEquals(simplify("x^1"), "x");
		// TODO: assertEquals(simplify("1/1/x", "x"));
	}
	
	inline function derivate(s:String):String {
		return Term.fromString(s).derivate("x").simplify().toString();
	}
	public function testDerivate()
	{
		
		assertEquals(derivate("sin(x)"), "cos(x)");
		assertEquals(derivate("cos(x)"), "-sin(x)");
		assertEquals(derivate("tan(x)"), "1+(tan(x)^2)");

		assertEquals(derivate("x^a")   , "a*(x^(a-1))");
		
		assertEquals(derivate("a^x")   , "e()^(ln(a)*x)");
		/*
		assertEquals(derivate("a^(x+b)")     , "");
		assertEquals(derivate("a^(x-b)")     , "");
		assertEquals(derivate("a^(x*b)")     , "");
		assertEquals(derivate("a^(x/b)")     , "");
		assertEquals(derivate("a^(x^b)")     , "");
		assertEquals(derivate("a^(b^x)")     , "");
		assertEquals(derivate("a^(b^(x+c))") , "");
		*/
		
	}
	
	inline function errorFromString(s:String):Int {
		var e:Int = 0;
		try Term.fromString(s) catch (msg:String) e = 1;
		return e;
	}
	public function testErrorFromString()
	{
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
	}
}