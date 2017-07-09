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
		var s:String;
		var t:Term;
		
		// test error handling
		s = "((1+2*3)";       try Term.fromString(s) catch (msg:String) trace(s, ' Error: $msg'); // Error: Bracket nesting
		s = "(1+(2*3)+(4-5)"; try Term.fromString(s) catch (msg:String) trace(s, ' Error: $msg'); // Error: Bracket nesting
		s = "()";             try Term.fromString(s) catch (msg:String) trace(s, ' Error: $msg'); // Error: Empty brackets
		s = "5+ "; try Term.fromString(s) catch (msg:String) trace(s, ' Error: $msg'); // Error: Missing right operand
		s = "5- "; try Term.fromString(s) catch (msg:String) trace(s, ' Error: $msg'); // Error: Missing right operand
		s = "5* "; try Term.fromString(s) catch (msg:String) trace(s, ' Error: $msg'); // Error: Missing right operand
		s = "*5 "; try Term.fromString(s) catch (msg:String) trace(s, ' Error: $msg'); // Error: Missing left operand

		s = "3 * p + 2";  t = Term.fromString(s); trace(s +' -> ' + t.toString(0) +' -> ' + t.toString(1)); // no bindings to "p"
		try trace(t.result) catch (msg:String) trace('Error: $msg'); // Error: Missing parameter "p"
		t.bind(["p" => Term.newValue(2)]);
		trace('p=2 -> ' + s +' -> ' + t.toString(0) +' -> ' + t.toString(1) + '->' + t.result); // OK
		
		// more tests
		s = "2 * -3 "; try {t = Term.fromString(s); trace(s +' -> ' + t.toString() +' -> ' + t.result); } catch (msg:String) trace(s, 'Error: $msg');
		s = "5 - -1 "; try {t = Term.fromString(s); trace(s +' -> ' + t.toString() +' -> ' + t.result); } catch (msg:String) trace(s, 'Error: $msg');
		s = "5 + -1 "; try {t = Term.fromString(s); trace(s +' -> ' + t.toString() +' -> ' + t.result); } catch (msg:String) trace(s, 'Error: $msg');
		s = "+min(2,5) "; try {t = Term.fromString(s); trace(s +' -> ' + t.toString() +' -> ' + t.result); } catch (msg:String) trace(s,'Error: $msg');
		s = "3* -max(2,3) + 5"; try {t = Term.fromString(s); trace(s +' -> ' + t.toString() +' -> ' + t.result); } catch (msg:String) trace(s,'Error: $msg');
		s = "3* 0-max(2,3) + 5"; try {t = Term.fromString(s); trace(s +' -> ' + t.toString() +' -> ' + t.result); } catch (msg:String) trace(s,'Error: $msg');
		s = "3* (0-max(2,3)) + 5"; try {t = Term.fromString(s); trace(s +' -> ' + t.toString() +' -> ' + t.result); } catch (msg:String) trace(s,'Error: $msg');
		
		s = "1.5+2*3";       t = Term.fromString(s); trace(s +' -> '+ t.toString() +' -> '+ t.result);
		s = " (1+2)*3";      t = Term.fromString(s); trace(s +' -> '+ t.toString() +' -> '+ t.result);
		s = "(1+2*3)";       t = Term.fromString(s); trace(s +' -> '+ t.toString() +' -> '+ t.result);
		s = "((1+2))*3";     t = Term.fromString(s); trace(s +' -> '+ t.toString() +' -> '+ t.result);
		s = "-1+((2*3))";    t = Term.fromString(s); trace(s +' -> '+ t.toString() +' -> '+ t.result);
		s = "-1.5+((2*3))";  t = Term.fromString(s); trace(s +' -> '+ t.toString() +' -> '+ t.result);
		
		s = "(2)+(3)"; t = Term.fromString(s); trace(s +' -> ' + t.toString() +' -> ' + t.result);
		
		s = "sin(3.14159)";  t = Term.fromString(s); trace(s +' -> '+ t.toString() +' -> '+ t.result);
		s = "1+cos(3.141)";  t = Term.fromString(s); trace(s +' -> '+ t.toString() +' -> '+ t.result);
		s = "max( 1.9 , 2)"; t = Term.fromString(s); trace(s +' -> '+ t.toString() +' -> '+ t.result);
		s = "2 + -max(1,2) * 3 - 1"; t = Term.fromString(s); trace(s +' -> ' + t.toString() +' -> ' + t.result);
		
		s = "(2+1)^(3-1)"; t = Term.fromString(s); trace(s +' -> ' + t.toString() +' -> ' + t.result);
		
		t = Term.fromString("100");
		s = "a + 2";  t = Term.fromString(s,["a"=>t]); trace(s +' -> '+ t.toString(0) +' -> '+ t.toString(1) +' -> '+ t.result);
		
		var pi:Term = Term.fromString("3.14159265359");
		s = "2.5 * sin(a + pi) ^ 2";  t = Term.fromString(s,["pi"=>pi, "a"=>Term.newValue(4)]); trace(s +' -> '+ t.toString(0) +' -> '+ t.toString(1) +' -> '+ t.result);
		
		var x:Term = Term.newValue(7);
		var a:Term = Term.fromString("1 + 2 * 3");
		var f:Term = Term.fromString("2.5 * sin(x - a) ^ 2", ["x"=>x, "a"=>a] );
		trace( "f=" + f.toString(0) + " -> " + f.toString(1) + " -> " + f.result );	// -> f=2.5*(sin(x-a)^2) -> 2.5*(sin(7-(1+(2*3)))^2) -> 0
		

	}

}