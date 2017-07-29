class TestTermNode extends haxe.unit.TestCase
{
	public function testValue()
	{
		var a:TermNode  = TermNode.newValue(2.0);
		assertTrue(a.isValue);
		assertEquals(a.result, 2.0);
	}
	
	inline function opResult(symbol:String, ?left:Float, ?right:Float):Float {
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
		
		assertEquals(opResult('pi'), Math.PI);
		assertEquals(opResult('e'), Math.exp(1));
		
	}
	
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

		assertEquals(simplify("1/(1/x)"), "x");
		assertEquals(simplify("a/b+c/d"), "((a*d)+(c*b))/(b*d)");
		assertEquals(simplify("(a*b)/b"), "a");
		assertEquals(simplify("(a*ln(b))/ln(b)"), "a");
		assertEquals(simplify("x/x"), "1");
		assertEquals(simplify("b/(a*b)"), "1/a");
		assertEquals(simplify("x+x^2+2+4+x^5+x^ln(2)"), "((4+(2+(x+(x^2))))+(x^5))+(x^ln(2))");
		//really bad bracket nesting 

		assertEquals(simplify("log(a,b)"), "ln(b)/ln(a)");
		assertEquals(simplify("log(a,a)"), "1");
		assertEquals(simplify("ln(a)+ln(b)"), "ln(a*b)");
		assertEquals(simplify("log(a,b)+log(c,d)"), "((ln(b)*ln(c))+(ln(d)*ln(a)))/(ln(a)*ln(c))");
		assertEquals(simplify("(x^a)^b"), "x^(a*b)");

	}
	
	inline function derivate(s:String):String {
		return TermNode.fromString(s).derivate("x").simplify().toString();
	}
	public function testDerivate()
	{
		
		assertEquals(derivate("sin(x)"), "cos(x)");
		assertEquals(derivate("cos(x)"), "-sin(x)");
		assertEquals(derivate("tan(x)"), "1+(tan(x)^2)");
		assertEquals(derivate("cot(x)"), "-((1+(tan(x)^2))/(tan(x)^2))");

		assertEquals(derivate("asin(x)"), "1/((1-(x^2))^0.5)");
		assertEquals(derivate("acos(x)"), "-(1/((1-(x^2))^0.5))");
		assertEquals(derivate("atan(x)"), "1/(1+(x^2))");
		assertEquals(derivate("atan2(y,x)"), "-(y/((y*y)+(x*x)))");
		assertEquals(derivate("atan2(x,y)"), "y/((x*x)+(y*y))");

		assertEquals(derivate("ln(x)"), "1/x");
		assertEquals(derivate("log(a,x)"), "ln(a)/(x*(ln(a)^2))");
		assertEquals(derivate("log(x,a)"), "-(ln(a)/(x*(ln(x)^2)))");

		assertEquals(derivate("x^a")         , "((x^a)*a)/x");
		assertEquals(derivate("a^x")         , "(a^x)*ln(a)");
		assertEquals(derivate("a^(x+b)")     , "(a^(x+b))*ln(a)");
		assertEquals(derivate("a^(x-b)")     , "(a^(x-b))*ln(a)");
		assertEquals(derivate("a^(x*b)")     , "(a^(x*b))*(b*ln(a))");
		assertEquals(derivate("a^(x/b)")     , "(((a^(x/b))*ln(a))*b)/(b^2)");
		assertEquals(derivate("a^(x^b)")     , "(a^(x^b))*((((x^b)*b)/x)*ln(a))");
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
