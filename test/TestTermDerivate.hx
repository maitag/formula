class TestTermDerivate extends haxe.unit.TestCase
{
	public function derivate(s:String):String {
		return TermNode.fromString(s).derivate("x").toString();
	}
	public function testDerivate()
	{
		
		assertEquals(derivate("sin(x)"), "1*cos(x)");
		assertEquals(derivate("cos(x)"), "1*-sin(x)");
		assertEquals(derivate("tan(x)"), "1*(1+(tan(x)^2))");
		assertEquals(derivate("cot(x)"), "((0*tan(x))-(1*(1*(1+(tan(x)^2)))))/(tan(x)^2)");

		assertEquals(derivate("asin(x)"), "1*(1/((1-(x^2))^(1/2)))");
		assertEquals(derivate("acos(x)"), "1*-(1/((1-(x^2))^(1/2)))");
		assertEquals(derivate("atan(x)"), "1*(1/(1+(x^2)))");
		assertEquals(derivate("atan2(y,x)"), "((x*0)-(y*1))/((y*y)+(x*x))");
		assertEquals(derivate("atan2(x,y)"), "((y*1)-(x*0))/((x*x)+(y*y))");

		assertEquals(derivate("abs(x)"), "1*(x/abs(x))");
		assertEquals(derivate("ln(x)"), "1*(1/x)");
		assertEquals(derivate("log(a,x)"), "(((1*(1/x))*ln(a))-(ln(x)*(0*(1/a))))/(ln(a)^2)");
		assertEquals(derivate("log(x,a)"), "(((0*(1/a))*ln(x))-(ln(a)*(1*(1/x))))/(ln(x)^2)");

		assertEquals(derivate("x^a")         , "(x^a)*((0*ln(x))+(a*(1*(1/x))))");
		assertEquals(derivate("a^x")         , "(a^x)*((1*ln(a))+(x*(0*(1/a))))");
		assertEquals(derivate("a^(x+b)")     , "(a^(x+b))*(((1+0)*ln(a))+((x+b)*(0*(1/a))))");
		assertEquals(derivate("a^(x-b)")     , "(a^(x-b))*(((1-0)*ln(a))+((x-b)*(0*(1/a))))");
		assertEquals(derivate("a^(x*b)")     , "(a^(x*b))*((((1*b)+(x*0))*ln(a))+((x*b)*(0*(1/a))))");
		assertEquals(derivate("a^(x/b)")     , "(a^(x/b))*(((((1*b)-(x*0))/(b^2))*ln(a))+((x/b)*(0*(1/a))))");
		assertEquals(derivate("a^(x^b)")     , "(a^(x^b))*((((x^b)*((0*ln(x))+(b*(1*(1/x)))))*ln(a))+((x^b)*(0*(1/a))))");
		assertEquals(derivate("a^(b^x)")     , "(a^(b^x))*((((b^x)*((1*ln(b))+(x*(0*(1/b)))))*ln(a))+((b^x)*(0*(1/a))))");
		assertEquals(derivate("a^(b^(x+c))") , "(a^(b^(x+c)))*((((b^(x+c))*(((1+0)*ln(b))+((x+c)*(0*(1/b)))))*ln(a))+((b^(x+c))*(0*(1/a))))");
			
	}
}
