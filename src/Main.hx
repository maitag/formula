package;

/**
 * build Terms at runtime to do math operations
 * by Sylvio Sell, Rostock 2017
 * 
 **/

class Main 
{
	static function main() 
	{
		/*
		 * build Term Tree manual
		 * 
		 */	
		var a:Term  = Term.newValue(2);
		trace("a: " + a.result + ((a.isValue) ? ' isValue' : '')); // -> a: 2 isValue

		var b:Term = Term.newValue(3);
		trace("b: " + b.result + ((b.isValue) ? ' isValue' : '')); // -> b: 3 isValue

		var f:Term = Term.newOperation("+", a , b);
		trace("f: " + f.toString() + ((f.isValue) ? '' : ' isOperation') + " -> " + f.result); // f: 2+3 isOperation -> 5
		
		f.setOperation("*", Term.newParam("a", a) , b);
		trace("f: " + f.toString(0) + " -> " + f.result); // f: a*3 -> 6
		
		
		var x:Term = Term.newValue(4);
		trace("x: " + x.result + ((x.isValue) ? ' isValue' : '')); // -> x: 4 isValue
		
		// references to sub-terms
		var g:Term = Term.newOperation("+", Term.newParam("x", x), Term.newParam("f", f));
		trace("g: " + g.toString(0) + " , " + g.toString(1) + " , " + g.toString(2) + " -> " + g.result); // g: x+f , 4+f , 4+2*3 -> 10
		
		x.setValue(5);
		trace("x: " + x.result); // -> x: 5
		trace("g: " + g.toString(0) + " , " + g.toString(1) + " , " + g.toString(2) + " -> " + g.result); // g: x+f , 5+f , 5+2*3 -> 11
		
		a.setValue(3);
		trace("a: " + a.result); // -> a: 3
		trace("g: " + g.toString(0) + " , " + g.toString(1) + " , " + g.toString(2) + " -> " + g.result); // g: x+f , 5+f , 5+3*3 -> 14

		// error handling
		try var h:Term = Term.newOperation("§", a , b) catch (msg:String) trace('Error: $msg'); // Error: "§" is no valid operation

		
		/*
		 * construct Term Tree from String Input
		 * 
		 */	
		var a,b,x,f,g:Term;
		
		// terms with other terms as parameters
		
		a = Term.fromString("1 + 2 * 3");
		x = Term.newValue(7);
		f = Term.fromString("2.5 * sin(x - a) ^ 2", ["x"=>x, "a"=>a] );
		
		trace( "x=" + x.toString(0) );
		trace( "a=" + a.toString(0) );
		trace( "f=" + f.toString(0) + " -> " + f.toString(1) + " -> " + f.result );	// -> f=2.5*(sin(x-a)^2) -> 2.5*(sin(7-(1+(2*3)))^2) -> 0

		// cloning a Term
		g = f.copy();
		
		b = Term.fromString("x+1", ["x" => x] ); trace( "b=" + b.toString(0) + " -> " + b.toString(1) + " -> " + b.result );
		g.bind(["a"=>b]);
		trace( "g=" + g.toString(0) + " -> " + g.toString(1) + " -> " + g.toString(2) + " -> " + g.result );

		// derivate g'(x)
		trace( "g'(x) = " + g.derivate("x").simplify().toString(0));

	}

}