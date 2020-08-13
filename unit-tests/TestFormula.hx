class TestFormula extends haxe.unit.TestCase
{
	// feel free to put your own tests here:
	public function testBinding() {
		var x:Formula, y:Formula, a:Formula, f:Formula, g:Formula;
		
		x = 7.0;
		assertEquals(x.name, null);
		
		a = "a: y^2 + 2*y";
		assertEquals(a.name, "a");
		
		f = "2.5 * sin(a)^2";
		assertEquals(f.depth(), 0);
		assertEquals(f.toString(), "2.5*(sin(a)^2)");
		assertTrue(f.hasParam("a"));
		assertFalse(f.hasParam("y"));
		assertFalse(f.hasBinding(a));
		
		f.bind(a);
		assertTrue(f.hasBinding(a));
		assertFalse(f.hasBinding(x));
		assertEquals(f.depth(), 1);
		assertEquals(f.toString(0),"2.5*(sin(a)^2)");
		assertEquals(f.toString(1),"2.5*(sin(((y^2)+(2*y)))^2)");
		assertEquals(f.toString(), "2.5*(sin(((y^2)+(2*y)))^2)");
		g = f.resolveAll(); //g.debug();
		assertEquals(g.toString(0), "2.5*(sin((y^2)+(2*y))^2)");
		assertFalse(g.hasParam("a"));
		assertTrue(g.hasParam("y"));
		assertFalse(g.hasBinding(x));
		
		a.bind(x, "y");
		assertFalse(g.hasBinding(x));
		
		assertTrue(f.hasBinding(x));
		assertEquals(f.depth(), 2);
		assertEquals(f.toString(0), "2.5*(sin(a)^2)");
		assertEquals(f.toString(1), "2.5*(sin(((y^2)+(2*y)))^2)");
		assertEquals(f.toString(2), "2.5*(sin(((7^2)+(2*7)))^2)");
		assertEquals(f.toString() , "2.5*(sin(((7^2)+(2*7)))^2)");
		assertTrue(f.hasParam("a"));
		assertTrue(f.hasParam("y"));

		g = f.resolveAll(0); //g.debug();
		assertEquals(g.toString(0), "2.5*(sin((y^2)+(2*y))^2)");
		assertEquals(g.toString(1), "2.5*(sin((7^2)+(2*7))^2)");
		x.set("10");
		assertEquals(g.toString(1), "2.5*(sin((10^2)+(2*10))^2)");
		assertFalse(g.hasParam("a"));
		assertTrue(g.hasParam("y"));
		x.set("7");
		
		g = f.resolveAll(1); //g.debug();
		x.set("99");
		assertEquals(g.toString(0), "2.5*(sin((7^2)+(2*7))^2)");
		assertFalse(g.hasParam("a"));
		assertFalse(g.hasParam("y"));
				
		
		f.unbind(a);
		assertFalse(f.hasBinding(a));
		assertEquals(f.depth(), 0);
		assertEquals(f.toString(), "2.5*(sin(a)^2)");
		
		assertEquals(a.depth(), 1);
		a.unbindParam("y");
		assertEquals(a.depth(), 0);
				
		// -----
		
		a = "x^2 + 2*y";
		assertEquals(a.params().join(","), "x,y");
		assertTrue(a.hasParam("x"));
		assertTrue(a.hasParam("y"));
		x = "1+2";
		y = "3+4";
		a.bindArray([x, y], ["x", "y"]);
		assertEquals(a.depth(), 1);
		assertEquals(a.toString() , "((1+2)^2)+(2*(3+4))");
		
		a.unbindArray([x, y]);
		assertEquals(a.depth(), 0);
		assertEquals(a.toString() , "(x^2)+(2*y)");
		
		a.bindMap(["y" => x, "x" => y]);
		assertEquals(a.depth(), 1);
		assertEquals(a.toString() , "((3+4)^2)+(2*(1+2))");

		a.unbindParamArray(["x", "y"]);
		assertEquals(a.depth(), 0);
		
		x.name = "x";
		y.name = "y";
		
		a.bindArray([x, y]);
		assertEquals(a.depth(), 1);
		assertEquals(a.toString() , "((1+2)^2)+(2*(3+4))");
		
		a.unbindAll();
		assertEquals(a.depth(), 0);
		assertEquals(a.toString() , "(x^2)+(2*y)");
	}

	public function testResolving() {
		var x:Formula = "x: ln(3)";
		var y:Formula = "y: sin(x)";
		y.bind(x);
		
		var a:Formula = "a: y+2";
		a.bind(y);
		
		var b:Formula = "b: 3+4";
		var ab:Formula = "ab: a*b";
		ab.bindArray([a, b]);
		
		var c:Formula = "c: 1-2";
		var d:Formula = "d: 3-4";
		var cd:Formula = "cd: c/d";
		cd.bindArray([c, d]);
		
		var abcd:Formula = "ab^cd";
		abcd.bindArray([ab, cd]); //abcd.debug();
		
		var g:Formula;
		//g = abcd.resolveAll(0); x.set(55); b.set(77); ab.set(88); abcd.set(99); g.debug();
		//g = abcd.resolveAll(1); x.set(55); y.set(66); b.set(77); ab.set(88); abcd.set(99); g.debug();
		//g = abcd.resolveAll(2); x.set(55); y.set(66); b.set(77); ab.set(88); abcd.set(99); g.debug();
		//g = abcd.resolveAll(3); x.set(55); y.set(66); b.set(77); ab.set(88); abcd.set(99); g.debug();
		g = abcd.resolveAll(); x.set(55); y.set(66); b.set(77); ab.set(88); abcd.set(99); //g.debug();
		assertEquals(g.toString() , "((sin(ln(3))+2)*(3+4))^((1-2)/(3-4))");
	}
	public function testSet() {
		
		var x:Formula, y:Formula;
		x = "x: 1+2";
		y = "y: 3*4";
		x = y;
		assertEquals(x.name, "y");
		assertEquals(x.toString(), "3*4");
		y.set("5/6");
		assertEquals(x.toString(), "5/6");
		y.name = "yy";
		assertEquals(x.name, "yy");
				
		x = "x: 1+2";
		y = "y: 3*4";
		x.set(y);
		assertEquals(x.toString(), "3*4");
		assertEquals(x.name, "x");
		
		x = "x: 1+2";
		y = "y: 3*4";
		x = y.copy();
		assertEquals(x.name, "y");
		assertEquals(x.toString(), "3*4");
		y.set("5/6");
		assertEquals(x.toString(), "3*4");
	}

	public function testByteIO() {
		var f:Formula = "2.5 * sin(a)^2";
		assertEquals(Formula.fromBytes(f.toBytes()).toString(), "2.5*(sin(a)^2)");
	}
	
	public function testOutput() {
		var f = new Formula("2.5 * sin(a)^2");
		var a:Formula = "a: y^2 + 2*y";
		f.bind(a);
		assertEquals(f.toString("glsl"), "2.5*pow(sin((pow(y,2.0)+(2.0*y))),2.0)");
	}
}