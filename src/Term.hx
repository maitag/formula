package;
import haxe.ds.Vector;
/**
 * knot of a Tree to do math operations at runtime
 * by Sylvio Sell 2017
 */

class Term { // knot of a tree
	
	// TESTING first
	public static function test() {
		
		var left:Term  = new Term();
		left.setOpValue(2);    trace(left.result); // -> 2

		var right:Term = new Term();
		right.setOpValue(3);   trace(right.result); // -> 3

		var f:Term = new Term();
		f.setOp("+", left , right); trace(f.result); // 2+3 -> 5
		trace("f="+f.toString());
		
		f.setOp("*", left ,right);  trace(f.result); // 2*3 -> 6
		trace("f="+f.toString());
		
		try	f.setOp("§", left , right) catch (msg:String) trace('Error: $msg'); // Error
		
		var x:Term = new Term();
		x.setOpValue(4);   trace(x.result); // -> 4
		
		var g:Term = new Term();
		g.setOp("+", x, f); trace(g.result); // 4+2*3 -> 10
		
		x.setOpValue(5);    trace(g.result); // 5+2*3 -> 11
		left.setOpValue(3); trace(g.result); // 5+3*3 -> 14
		trace("g=" + g.toString());
		
		// TODO
		Term.fromString("-3.13 +1");
		Term.fromString(" 1 + 2 * 3");
		Term.fromString("sin(5/2)");
		Term.fromString("(1+2)*3");
		Term.fromString(" (3*(1+2))");
		Term.fromString("((1+2)*3)");
		try	Term.fromString("((1+2*3)") catch (msg:String) trace('Error: $msg'); // Bracket Error
		try	Term.fromString("(1+(2*3)+(4-5)") catch (msg:String) trace('Error: $msg'); // Bracket Error
		try	Term.fromString("()") catch (msg:String) trace('Error: $msg'); // empty Bracket Error
	}

	// PROPERTIES -------------------------------------------
	var operation:Term->Float; // math operation  (todo: <N> ;)
	var symbol:String;  //operator like "+"

	var left:Term;   // left branch of tree
	var right:Term;  // right branch of tree
	
	var value:Float; // leaf of the tree (todo: <N> ;)
	
	public var id:String;  // term identifier, like "f" or "x"
	
	public var result(get, null):Float; // result of tree calculation (todo: <N> ;)
	inline function get_result() return operation(this); // getter

	// METHODS -------------------------------------------------
	public function new() {}
	
	public function setOpValue(f:Float) {
		operation = opValue;
		symbol = "v"; // <- helper to put into String
		value = f;
	}
	
	public function setOpTerm(t:Term) {
		operation = opParam;
		symbol = "t"; // <- helper to put into String
		left = t;
	}
	
	public function setOp(s:String, left:Term, ?right:Term) {
		if (MathOp.exists(s))
		{
			operation = MathOp.get(s);
			symbol = s;
			this.left = left;
			this.right = right;
		}
		else throw ('"$s" is no valid operation');
	}
	
	// ---- static Function Pointers (to stored in this.operation) --------
	
	static function opValue(t:Term):Float return t.value;
	static function opParam(t:Term):Float return t.left.result;
	
	static var MathOp:Map<String, Term->Float> = [
		"+" => function(t) return t.left.result + t.right.result,
		"-" => function(t) return t.left.result - t.right.result,
		"*" => function(t) return t.left.result * t.right.result,
		"/" => function(t) return t.left.result / t.right.result,
		"^" => function(t) return Math.pow(t.left.result, t.right.result),
		"%" => function(t) return t.left.result % t.right.result,
		
		"abs" => function(t) return Math.abs(t.left.result),
		"ln"  => function(t) return Math.log(t.left.result),
		"sin" => function(t) return Math.sin(t.left.result),
		"cos" => function(t) return Math.cos(t.left.result),
		"tan" => function(t) return Math.tan(t.left.result),
		"asin"=> function(t) return Math.asin(t.left.result),
		"acos"=> function(t) return Math.acos(t.left.result),
		"atan" => function(t) return Math.atan(t.left.result),
		
		"atan2"=> function(t) return Math.atan2(t.left.result, t.right.result),
		"log"  => function(t) return Math.log(t.left.result) / Math.log(t.right.result),
		"max"  => function(t) return Math.max(t.left.result, t.right.result),
		"min"  => function(t) return Math.min(t.left.result, t.right.result),		
	];
	public static var atomOps:EReg = ~/^[+\-\*\/\^%]$/;
	public static var par2Ops:EReg = ~/^atan2|log|max|min$/;
	public static var par1Ops:EReg = ~/^abs|ln|sin|cos|tan|asin|acos|atan$/;

	
	// ------ Build Tree up from String Math Expression -------
	
	public static var clearSpaces:EReg = ~/\s+/g;
	public static var twoSideExp:EReg = ~/^[+\-\*\/\^%]/;
	public static var numberExp:EReg = ~/^(\+|\-?\d+?\.?\d*)/;
	public static var functionExp:EReg = ~/^(atan2|log|max|min|abs|ln|sin|cos|tan|asin|acos|atan)/i;
	public static function fromString(s:String):Term
	{
		var t:Term = new Term();
		var operators:Array<String>  = new Array<String>();
		var innerTerms:Array<String> = new Array<String>();
		var brackets:Array<Int>;
		
		s = clearSpaces.replace(s, ''); // clear whitespaces
		trace('fromString: $s');
		
		
		//while (s.length != 0)
		//{
			
			 // check full term starting from left
			var e:String;
			
			
			if (numberExp.match(s)) {
				e = numberExp.matched(1);
				s = s.substr(e.length);
				trace("   number: " + e + " | rest:" + s);
				// TODO
				// check two side operation
			}
			else if (functionExp.match(s)) {
				e = functionExp.matched(1);
				s = s.substr(e.length);
				trace("   function: " + e + " | rest:" + s);
				// TODO
				// check two side operation
			}
			else {
				e = getBracketExp(s);
				if (e != "") {
					if (e == "()") throw("empty bracket");
					s = s.substr(e.length);
					trace("   bracket: " + e + " | rest:" + s);
					// TODO
					// check two side operation
				}
				
			}
			
			
			
		//}
		
		return t;
	}
	
	public static function getBracketExp(s:String):String
	{
		var pos:Int = 1;
		if (s.indexOf("(") == 0) // check that s starts with opening bracket
		{ 
			var i:Int;
			var openBrackets:Int = 1;
			while ( openBrackets > 0 )
			{	
				i = s.indexOf("(", pos);
				if (i > 0) { // found open bracket
					openBrackets++; pos = i + 1;
				}
				else {
					i = s.indexOf(")", pos);
					if (i > 0) { // found close bracket
						openBrackets--; pos = i + 1;
					}
					else { // no close or open found
						throw("Error with brackets.");
						return null;
					}
				}
			}
			return s.substring(0, pos);
		}
		return null;
	}
	
	
	// ------ Put out Math Expression as a String -------------
	
	public function toString():String
	{
		var out:String = "";
		if (symbol == "v") {
			out += value;
		}
		else if (symbol == "t") {
			out += "f"; // TODO
		}
		else if ( atomOps.match(symbol) ) {
			out += "(" + left.toString() + symbol + right.toString() + ")";
		}
		else if ( par2Ops.match(symbol) ) {
			out += symbol + "(" + left.toString() + ", " + right.toString() + ")";
		}
		else {
			out += symbol + "(" + left.toString() +  ")";
		}
		
		return out;

	} //end print_tree  ---------------------------------

}