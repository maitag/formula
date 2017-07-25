package;

/**
 * build math expressions at runtime to do math operations
 * by Sylvio Sell, Rostock 2017
 * 
 **/


/*
 * manual testings and playing to climb the tree UP;)
 * 
 */	

// typedef F = Formula; // shortkeys sometimes helps

class Main 
{
	static function main() 
	{
		/*
		 * build Term Tree manual
		 * 
		 */	
		
		trace("\nTesting TermNode");
		trace("-----------------");
		 
		var a:TermNode  = TermNode.newValue(2);
		trace("a: " + a.result + ((a.isValue) ? ' isValue' : '')); // -> a: 2 isValue

		var b:TermNode = TermNode.newValue(3);
		trace("b: " + b.result + ((b.isValue) ? ' isValue' : '')); // -> b: 3 isValue

		var f:TermNode = TermNode.newOperation("+", a , b);
		trace("f: " + f.toString() + ((f.isValue) ? '' : ' isOperation') + " -> " + f.result); // f: 2+3 isOperation -> 5
		
		f.setOperation("*", TermNode.newParam("a", a) , b);
		trace("f: " + f.toString(0) + " -> " + f.toString() + " -> " + f.result); // f: a*3 -> 6
		
		
		var x:TermNode = TermNode.newValue(4);
		trace("x: " + x.result + ((x.isValue) ? ' isValue' : '')); // -> x: 4 isValue
		
		// references to sub-terms
		var g:TermNode = TermNode.newOperation("+", TermNode.newParam("x", x), TermNode.newParam("f", f));
		trace("g: " + g.toString(0) + " , " + g.toString(1) + " , " + g.toString(2) + " -> " + g.result); // g: x+f , 4+f , 4+2*3 -> 10
		
		x.setValue(5);
		trace("x: " + x.result); // -> x: 5
		trace("g: " + g.toString(0) + " , " + g.toString(1) + " , " + g.toString(2) + " -> " + g.result); // g: x+f , 5+f , 5+2*3 -> 11
		
		a.setValue(3);
		trace("a: " + a.result); // -> a: 3
		trace("g: " + g.toString(0) + " , " + g.toString(1) + " , " + g.toString(2) + " -> " + g.result); // g: x+f , 5+f , 5+3*3 -> 14

		// error handling
		try var h:TermNode = TermNode.newOperation("§", a , b) catch (msg:String) trace('Error: $msg'); // Error: "§" is no valid operation
		
		
		
		
		/*
		 * construct Term Tree from String Input
		 * 
		 */	
		trace("\nTesting Formula");
		trace("---------------");
		 
		var a,b,x,f,g:TermNode;
		
		// terms with other terms as parameters
		
		a = TermNode.fromString("1 + 2 * 3");
		x = TermNode.newValue(7);
		f = TermNode.fromString("2.5 * sin(x - a) ^ 2", ["x"=>x, "a"=>a] );
		
		trace( "x=" + x.toString(0) );
		trace( "a=" + a.toString(0) );
		trace( "f=" + f.toString(0) + " -> " + f.toString(1) + " -> " + f.result );	// -> f=2.5*(sin(x-a)^2) -> 2.5*(sin(7-(1+(2*3)))^2) -> 0

		// cloning a Term
		g = f.copy();
		
		b = TermNode.fromString("x+1", ["x" => x] ); trace( "b=" + b.toString(0) + " -> " + b.toString(1) + " -> " + b.result );
		g.bind(["a"=>b]);
		trace( "g=" + g.toString(0) + " -> " + g.toString(1) + " -> " + g.toString(2) + " -> " + g.result );

		// derivate g'(x)
		trace( "g'(x) = " + g.derivate("x").simplify().toString(0));
		
		
		var x,a,b,f:TermNode;
		
		f = TermNode.fromString("x^a");
		f=f.derivate("x");
		trace("x^a ->" + f.simplify().toString(0) );
		
		f = TermNode.fromString("a^x");
		f=f.derivate("x");
		trace("a^x ->" + f.simplify().toString(0) );
		
		f = TermNode.fromString("atan2(x,y)");
		f=f.derivate("x");
		trace("d/dx: atan2(x,y)= " + f.simplify().toString(0));	
		
		/*

		
		
		/*
		 * Formula abstract wrapper around Term
		 * 
		 */
		trace("\nTesting Formula");
		trace("---------------");
		 
		var x:Formula, a:Formula, b:Formula, c:Formula, f:Formula;
		/*

		x = 7.0;        trace('x = 7.0;');
		a = "a: 1+2*3"; trace('a = "a: 1+2*3";');
		
		f = "f: 2.5 * sin(x-a)^2"; trace('f = "f: 2.5 * sin(x-a)^2";');
		
		// bind Formulas as parameter to other Formula
		f.bind(["x" => x, "a" => a]); trace('f.bind(["x" => x, "a" => a]);');
		
		trace( "-> " + f.name + ":" + f.toString(0) + "-> " + f.toString(1) );	// f: 2.5*(sin(x-a)^2)
		
		// fast calculation at runtime
		trace( "f.result = " + f.result );      // 0
		
		// derivation           // 2.5*((sin(x-a)^2)*(2*(cos(x-a)*(1/sin(x-a)))))
		trace( 'f.derivate("x").simplify() = ' + f.derivate("x").simplify().toString(0) );
		*/
		
		// TODO: unbind
		a = "a:1-2"; a.debug();
		x = "x:3*4"; x.debug();
		c = "c:5+1"; c.debug();

		f = Formula.sin("3"); f.debug();
		//f = a + x / c + 3;	f.name = "f";
		//f = "f: a + x / c"; f.bind(["x" => x, "a" => a, "c"=>c]);
	}

}
