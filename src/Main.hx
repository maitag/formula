package;

/**
 * build math expressions at runtime to do math operations
 * by Sylvio Sell, Rostock 2017
 * 
 **/


/*
 * some manual testing
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
		//try var h:TermNode = TermNode.newOperation("§", a , b) catch (error:Dynamic) trace('Error: ${error.msg}'); // Error: "§" is no valid operation
		
		
		
		
		/*
		 * construct Term Tree from String Input
		 * 
		 */	
		 
		trace("\nconstruct Term Tree from String Input");
		trace("-----------------------------------------");
		 
		var a:TermNode,b:TermNode,x:TermNode,f:TermNode,g:TermNode;
		
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
		
		
		var x:TermNode,a:TermNode,b:TermNode,f:TermNode;
		
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

		x = 7.0;
		a = "a: 1+2*3";  // a has a defined name
		
		f = "2.5 * sin(x-a)^2";

		// change name of Formula
		x.name = "x";

		// bind Formulas as parameter to other Formula
		f.bindMap(["x" => x, "a" => a]);
		
		trace( f.toString(0) );	// 2.5*(sin(x-a)^2)

		// fast calculation at runtime
		trace( f.result );      // 0
		
		// derivation           // 2.5*((sin(x-a)^2)*(2*(cos(x-a)/sin(x-a))))
		trace( f.derivate("x").simplify().toString(0) );
		
		// change value (keeps parameter bindings)
		x.set("atan(a)");
		x.bind(a);              // a has a defined name to bind to

		trace( f.toString(0) ); // 2.5*(sin(x-a)^2)
		trace( f.toString(1) ); // 2.5*(sin(atan(a)-(1+(2*3)))^2)
		trace( f.toString(2) ); // 2.5*(sin(atan((1+(2*3)))-(1+(2*3)))^2)
		
		// unbind parameter
		x.unbindParam("a");
		f.unbindParamArray(["a", "x"]); // unbind accepts array of param-names
		f.unbind(a);          // unbind accepts Formula
		f.unbindArray([a , x]);    // unbind accepts array of Formulas
		f.unbindAll();        // or unbind all params
		
		trace( f );  // 2.5*(sin(x-a)^2)
			
		// operations with Formulas
		a = "a: 1-2";
		x = "x = 3*4";
		c = 5;
		
		f = a + x / c;
		f.name = "f";
		
		// show parameters
		// c has no name, so operation will not generate param for f
		trace( f.params() ); // [ "a", "x" ]
			
		// debugging Formulas
		f.debug(); // f = a+(x/5) -> (1-2)+((3*4)/5)
		
		// simplify reduce operations with values
		a.simplify();
		trace( f );             // -1+((3*4)/5)
		
		// using math functions
		f = Formula.sin(c * a) + Formula.max(f, 3);
		f.name = "F";
		f.debug(); // F = sin(5*a)+max(f,3) -> sin(5*-1)+max((a+(x/5)),3) -> sin(5*-1)+max((-1+((3*4)/5)),3)
		
		
		// testing output for glsl
		f = " - (a^0.5) + ln(1 % 2) + log(3, 5) + tan(3) + e() + pi() + atan2(1,2)";
		trace("norm     :" + f.toString());
		trace("norm-simp:"+f.copy().simplify().toString());
		trace("glsl:     "+f.toString('glsl'));
		trace("glsl-simp:" + f.copy().simplify().toString('glsl'));
		
		// packging
		f = "sin(pi())+param";
		trace(f.toBytes());
		trace(Formula.fromBytes(f.toBytes()));
		
		f = "sin(b*x)/(2*(y*x-(3.14/2+a))/3.14)";
		//trace(f.toBytes());
		trace(Formula.fromBytes(f.toBytes()));
		
		// errorhandling
		try f = "hallo:welt" catch (error:Dynamic) trace('Error: ${error.msg}');
		f.debug();
		
		
		
		
		trace("starting new samples");
		f = "(a-b)*c";
		trace(f.simplify().toString());
		
		
		// derivation of abs
		f = "abs(x)";
		trace( f.derivate("x").toString(0) );
		
		// errorhandling
		var s:String = "4 + (3*4";
		trace(s);
		try {
			f = s;
		} catch (error:Dynamic) {
			var spaces:String = "";
			for (i in 0...error.pos) spaces += " ";
			trace(spaces + "^");
			trace('Error: ${error.msg}'); // Error: Missing right operand.
		}
		
		c = "4";
		f = "3 * c";
		f.debug();
		
		try	f.bind(c)
		catch (error:String) trace('Error: ${error}'); // Error: Can't bind formula with unnamed parameter.
		
		f.bindMap(["c" => c]);
		f.debug();
		
		try	f.unbind(c)
		catch (error:String) trace('Error: ${error}'); // Error: Can't unbind formula with unnamed parameter.
		
		//f.unbindParam("c");
		f.unbind(c);
		f.debug();
	}

}
