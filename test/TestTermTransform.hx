class TestTermTransform extends haxe.unit.TestCase
{
	inline function simplify(s:String):String {
		return TermNode.fromString(s).simplify().toString();
	}

	inline function expand(s:String):String {
		return TermNode.fromString(s).expand().toString();
	}

	inline function factorize(s:String):String {
		return TermNode.fromString(s).factorize().toString();
	}

	public function testExpand() {
		assertEquals(expand("a*(b+c)"), "(a*b)+(a*c)");
		assertEquals(expand("(a+b)*(a-b)"), "((a*a)-(a*b))+((b*a)-(b*b))");
		assertEquals(expand("(a+b)*c"), "(a*c)+(b*c)");
		assertEquals(expand("(x)*(a-(b+c))"), "(x*a)-((x*b)+(x*c))");
		assertEquals(expand("(0+1+2)*(3+4+5)"), "((((0*3)+(0*4))+((1*3)+(1*4)))+((0*5)+(1*5)))+(((2*3)+(2*4))+(2*5))");
		assertEquals(expand("a*(-b-c)"), "((a*0)-(a*b))-(a*c)");	
	}

	public function testfactorize() {
		assertEquals(factorize("x+x"), "x*(1+1)");
		assertEquals(factorize("-x+x"), "x*(-1+1)");
		assertEquals(factorize("-x-x"), "x*(-1-1)");
		assertEquals(factorize("x^4+cos(a)*x"), "x*((x^(4-1))+cos(a))");
		assertEquals(factorize("a*b+a*b"), "(a*b)*(1+1)");
		assertEquals(factorize("cos(a)-cos(a)*b"), "cos(a)*(1-b)");
		assertEquals(factorize("a+b"), "a+b");
		assertEquals(factorize("x+x+b"), "(x+x)+b");
		assertEquals(factorize("x+0*x"), "x*(1+0)");
		assertEquals(factorize("-a*x+a-4*a"), "a*(((-1*x)+1)-4)");
		assertEquals(factorize("x^2+x^2"), "(x^2)+(x^2)");
		assertEquals(factorize("x+x^2"), "x*(1+(x^(2-1)))");
	}

	public function testSimplify() {
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
	}
	
	public function testSimplify1() {
		assertEquals(simplify("(a/b)/c"), "a/(c*b)");
		assertEquals(simplify("a/(b/c)"), "(c*a)/b");
		assertEquals(simplify("(0-a)/b"), "-(a/b)");
		assertEquals(simplify("1/(1/x)"), "x");
		assertEquals(simplify("a/b+c/b"), "(c+a)/b");
		assertEquals(simplify("a/b-c/b"), "-((c-a)/b)");
		assertEquals(simplify("(a/b)/(c/b)"), "a/c");
		assertEquals(simplify("(a/b)/(c/d)"), "(d*a)/(c*b)");
		assertEquals(simplify("a/b+c/d"), "((d*a)+(c*b))/(d*b)");
		assertEquals(simplify("a/b-c/d"), "((d*a)-(c*b))/(d*b)");
		assertEquals(simplify("(a*b)/b"), "a");
		assertEquals(simplify("(a*ln(b))/ln(b)"), "a");
		assertEquals(simplify("x/x"), "1");
		assertEquals(simplify("b/(a*b)"), "1/a");
	}
	
	public function testSimplify2() {
		assertEquals(simplify("log(a,b)"), "ln(b)/ln(a)");
		assertEquals(simplify("log(a,a)"), "1");
		assertEquals(simplify("ln(a)+ln(b)"), "ln(b*a)");
		assertEquals(simplify("ln(a)-ln(b)"), "ln(a/b)");
		assertEquals(simplify("log(a,b)+log(c,d)"), "((ln(c)*ln(b))+(ln(d)*ln(a)))/(ln(c)*ln(a))");
		
	}
	
	public function testSimplify3() {
		assertEquals(simplify("(x^a)^b"), "x^(b*a)");
		assertEquals(simplify("(a+b)*c"), "c*(b+a)");
		assertEquals(simplify("(a-b)*c"), "c*-(b-a)");
		assertEquals(simplify("a*(b-c)"), "-(c-b)*a");
		assertEquals(simplify("a*(b+c)"), "(c+b)*a");

		assertEquals(simplify("-b-a"), "-(b+a)");
		assertEquals(simplify("a*(b+c)+a*(b-c)"), "(b*a)*2");
		assertEquals(simplify("a-(1+d/a)*a"), "-d");
		assertEquals(simplify("x^m+x^n"), "(x^n)+(x^m)"); 
		assertEquals(simplify("x*-1"), "x*-1");

		assertEquals(simplify("x+x"), "x*2");
		assertEquals(simplify("x*5+x*3"), "x*8");
		assertEquals(simplify("3+4"), "7");
		assertEquals(simplify("-x+x"), "0");
		assertEquals(simplify("2*x-2*x"), "0");
		assertEquals(simplify("-x-x"), "-x*2");
	}

}
