class TestTermNode extends haxe.unit.TestCase
{
	public function testValue()
	{
		var a:TermNode  = TermNode.newValue(2.0);
		assertTrue(a.isValue);
	}
	/*
	public function testOperations()
	{
		var f:TermNode  = TermNode.newOperation('+', a, b);
		
		assertEquals("A", f.is);
	}*/
	
	inline function simplify(s:String):String {
		return TermNode.fromString(s).simplify().toString();
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
		return TermNode.fromString(s).derivate("x").simplify().toString();
	}
	public function testDerivate()
	{
		
		assertEquals(derivate("sin(x)"), "cos(x)");
		assertEquals(derivate("cos(x)"), "-sin(x)");
		assertEquals(derivate("tan(x)"), "1+(tan(x)^2)");
		assertEquals(derivate("cot(x)"), "-(1+(tan(x)^2))/(tan(x)^2)");

		assertEquals(derivate("asin(x)"), "1/((1-(x^2))^0.5)");
		assertEquals(derivate("acos(x)"), "-(1/((1-(x^2))^0.5))");
		assertEquals(derivate("atan(x)"), "1/(1+(x^2))");
		assertEquals(derivate("atan2(y,x)"), "-y/((y*y)+(x*x))");
		
		assertEquals(derivate("ln(x)"), "1/x");
		assertEquals(derivate("log(a,x)"), "((1/x)*ln(a))/(ln(a)^2)");
		assertEquals(derivate("log(x,a)"), "-(ln(a)*(1/x))/(ln(x)^2)");

		assertEquals(derivate("x^a")         , "(x^a)*(a*(1/x))");
		assertEquals(derivate("a^x")         , "(a^x)*ln(a)");
		assertEquals(derivate("a^(x+b)")     , "(a^(x+b))*ln(a)");
		assertEquals(derivate("a^(x-b)")     , "(a^(x-b))*ln(a)");
		assertEquals(derivate("a^(x*b)")     , "(a^(x*b))*(b*ln(a))");
		assertEquals(derivate("a^(x/b)")     , "(a^(x/b))*((b/(b^2))*ln(a))");
		assertEquals(derivate("a^(x^b)")     , "(a^(x^b))*(((x^b)*(b*(1/x)))*ln(a))");
		assertEquals(derivate("a^(b^x)")     , "(a^(b^x))*(((b^x)*ln(b))*ln(a))");
		assertEquals(derivate("a^(b^(x+c))") , "(a^(b^(x+c)))*(((b^(x+c))*ln(b))*ln(a))");
		
		
	}
	
	inline function fromString(s:String):String {
		return TermNode.fromString(s).toString();
	}
	public function testFromString()
	{
		assertEquals(fromString(" 3"), "3");
		assertEquals(fromString("-3"), "-3");
		assertEquals(fromString("- -3"), "--3");
		assertEquals(fromString("1.5 "), "1.5");
		assertEquals(fromString("1.50"), "1.5");
		assertEquals(fromString("10.5"), "10.5");
		assertEquals(fromString("1 + 2"), "1+2");
		assertEquals(fromString("1+2*3"), "1+(2*3)");
		assertEquals(fromString("- (1 + 2)"), "-(1+2)");
		assertEquals(fromString("sin(x)"), "sin(x)");
		assertEquals(fromString("- sin(x)"), "-sin(x)");
		assertEquals(fromString("cos(x+1)"), "cos(x+1)");
		assertEquals(fromString("tan( x )"), "tan(x)");
		assertEquals(fromString("asin(x)"), "asin(x)");
		assertEquals(fromString("acos(x)"), "acos(x)");
		assertEquals(fromString("atan(x)"), "atan(x)");
		assertEquals(fromString("atan2(x,y)"), "atan2(x,y)");
		assertEquals(fromString("log(2,x)"), "log(2,x)");
		assertEquals(fromString("max(2,3 )"), "max(2,3)");
		assertEquals(fromString("min( 2,3)"), "min(2,3)");
		assertEquals(fromString("1+a^x*3"), "1+((a^x)*3)");
		assertEquals(fromString("a^b^c"), "(a^b)^c");
		assertEquals(fromString("a/b/c"), "(a/b)/c");
		assertEquals(fromString("a/b*c"), "(a/b)*c");
		assertEquals(fromString("a/b*c+1"), "((a/b)*c)+1");
	}
	
	inline function errorFromString(s:String):Int {
		var e:Int = 0;
		try TermNode.fromString(s) catch (msg:String) e = 1;
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
