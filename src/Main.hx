package;

import Term;
import Utility;


class Main 
{
	static function main() 
	{
		Term.test();
		

		var x:String="135A";
		var y:String="+";
		trace(Utility.isNumber(x));
		trace(Utility.isOperator("+"));
		// TODO:
		// --------------------
		/*
		var c:Formula = "2";
		
		var x:Formula = 1.0;
		x.name = "x"; // <- identifier in formula-string
		
		var f:F = new F("f"); // <- identifier in formula-string
		f = c + x ^ 2;
		
		trace(f); // -> "2+x^2"
		trace(f.params); // -> [ x ];
		
		var h:F = "1 + f * 3";
		h.params = [f];
		trace(h); // -> "1+2+x^2*3"
		
		x = 3; // give x a value
		trace(f.result); // -> 5
		trace(h.result); // -> 30
		
		var g:F = f.differential(x); // ableitung nach x
		trace(g); // -> "2*x"
		
		*/

	}

}
