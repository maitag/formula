package;

/**
 * knot of a Tree to do math operations at runtime
 * by Sylvio Sell 2017
 * 
 **/

class Term {

	// TESTING first ( todo: put into other file later )
	public static function test() {
		
		// WORKS:
		
		// building terms manual
		var left:Term  = new Term();
		left.setOpValue(2);    trace(left.result); // -> 2

		var right:Term = new Term();
		right.setOpValue(3);   trace(right.result); // -> 3
		

		var f:Term = new Term();
		f.setOp("+", left , right); trace(f.result); // 2+3 -> 5
		trace("f="+f.toString());
		

		f.setOp("*", left ,right);  trace(f.result); // 2*3 -> 6
		trace("f="+f.toString());
	

		var p:Term=new Term();
		p.setOp("^", f, f);
		var psin:Term=new Term();
		psin.setOp("sin", p);
		trace(psin.result);


		try	f.setOp("§", left , right) catch (msg:String) trace('Error: $msg'); // Error (todo)
		
		var x:Term = new Term();
		x.setOpValue(4);   trace(x.result); // -> 4
		
		var g:Term = new Term();
		g.setOp("+", x, f); trace(g.result); // 4+2*3 -> 10
		
		x.setOpValue(5);    trace(g.result); // 5+2*3 -> 11
		left.setOpValue(3); trace(g.result); // 5+3*3 -> 14
		trace("g=" + g.toString());
		
		//TODO:
		
		// read from string
		Term.fromString("-3.13 +1");
		Term.fromString(" 1 + 2 * 3");
		Term.fromString("sin(5/2)");
		Term.fromString("max(5,4)");
		Term.fromString("(1+2)*3");
		Term.fromString(" (3*(1+2))");
		Term.fromString("((1+2)*3)");
		try	Term.fromString("((1+2*3)") catch (msg:String) trace('Error: $msg'); // Bracket Error
		try	Term.fromString("(1+(2*3)+(4-5)") catch (msg:String) trace('Error: $msg'); // Bracket Error
		try	Term.fromString("()") catch (msg:String) trace('Error: $msg'); // empty Bracket Error
	}
	

	/*
	 * Properties
	 * 
	 */
	var operation:Term->Float; // math operation  (todo: <N> ;)
	var symbol:String; //operator like "+"

	var left:Term;  // left branch of tree
	var right:Term; // right branch of tree
	
	var value:Float; // leaf of the tree (todo: <N> ;)
	
	public var id:String; // term identifier, like "f" or "x"
	
	public var result(get, null):Float; // result of tree calculation (todo: <N> ;)
	inline function get_result() return operation(this);

	/*
	 * Methods
	 * 
	 */
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

	
	/*
	 * static Function Pointers (to stored in this.operation)
	 * 
	 */	
	static function opValue(t:Term):Float return t.value;
	static function opParam(t:Term):Float return t.left.result;
	
	static var MathOp:Map<String, Term->Float> = [
		"+"    => function(t) return t.left.result + t.right.result,
		"-"    => function(t) return t.left.result - t.right.result,
		"*"    => function(t) return t.left.result * t.right.result,
		"/"    => function(t) return t.left.result / t.right.result,
		"^"    => function(t) return Math.pow(t.left.result, t.right.result),
		"%"    => function(t) return t.left.result % t.right.result,
		       
		"abs"  => function(t) return Math.abs(t.left.result),
		"ln"   => function(t) return Math.log(t.left.result),
		"sin"  => function(t) return Math.sin(t.left.result),
		"cos"  => function(t) return Math.cos(t.left.result),
		"tan"  => function(t) return Math.tan(t.left.result),
		"asin" => function(t) return Math.asin(t.left.result),
		"acos" => function(t) return Math.acos(t.left.result),
		"atan" => function(t) return Math.atan(t.left.result),
		
		"atan2"=> function(t) return Math.atan2(t.left.result, t.right.result),
		"log"  => function(t) return Math.log(t.left.result) / Math.log(t.right.result),
		"max"  => function(t) return Math.max(t.left.result, t.right.result),
		"min"  => function(t) return Math.min(t.left.result, t.right.result),		
	];
	static var twoSideOp  = "^,*,/,+,-,%";  // <- order here determines the operator precedence
	static var oneParamOp = "abs,ln,sin,cos,tan,asin,acos,atan"; // functions with one parameter like "sin(2)"
	static var twoParamOp = "atan2,log,max,min";                 // functions with two parameters like "max(a,b)"
	
	
	/*
	 * Build Tree up from String Math Expression
	 * 
	 */	
	static var clearSpacesReg:EReg = ~/\s+/g;
	static var numberReg:EReg = ~/^(\+|\-?\d+?\.?\d*)/;
	static var twoSideOpReg:EReg  = new EReg("^(" + "\\"+ twoSideOp.split(',').join("|\\") + ")" , "");
	static var oneParamOpReg:EReg = new EReg("^("       + oneParamOp.split(',').join("|")  + ")" , "i");
	static var twoParamOpReg:EReg = new EReg("^("       + twoParamOp.split(',').join("|")  + ")" , "i");
	
	public static function fromString(s:String):Term
	{
		var t:Term = new Term();
		var subterms:Array<Term> = new Array<Term>();
		var operations:Array<String> = new Array<String>();
		
		s = clearSpacesReg.replace(s, ''); // clear whitespaces
		trace('fromString: $s');
		
		
		//while (s.length != 0)
		//{
			
			 // check full term starting from left
			var e:String;
			
			
			if (numberReg.match(s)) {
				e = numberReg.matched(1);
				s = s.substr(e.length);
				trace("   number: " + e + " | rest:" + s);
				// TODO
				var vt:Term = new Term(); vt.setOpValue(Std.parseFloat(e));
				subterms.push( t );
			}
			else if (oneParamOpReg.match(s)) {
				e = oneParamOpReg.matched(1);
				s = s.substr(e.length);
				trace("   function(): " + e + " | rest:" + s);
				// TODO
				// check inside brackets (...) and recursive inner term
			}
			else if (twoParamOpReg.match(s)) {
				e = twoParamOpReg.matched(1);
				s = s.substr(e.length);
				trace("   function(a,b): " + e + " | rest:" + s);
				// TODO
				// check for "," on same bracket level (.(..(.)).. , ...)
				// // recursive inner terms
			}
			else {
				e = getBracketExp(s);
				if (e != "") {
					if (e == "()") throw("empty bracket");
					s = s.substr(e.length);
					trace("   bracket: " + e + " | rest:" + s);
					// TODO
					// recursive inner term
				}
				
			}
			// TODO
			// else -> if some new symbol (like "x" or something) -> new parameter key!
			
		
			// TODO
			// check for two side operation like "+","-" and so on

			
			
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
	
	
	/*
	 * Puts out Math Expression as a String
	 * 
	 */	
	public static var twoSideOpReg1:EReg  = new EReg("^(" + "\\"+ twoSideOp.split(',').join("|\\") + ")$" , "");
	public static var twoParamOpReg1:EReg = new EReg("^("       + twoParamOp.split(',').join("|")  + ")$" , "i");

	public function toString():String
	{
		return switch(symbol) {
			case "v": Std.string(value);
			case "t": "f"; // TODO: bind to other term
			case s if (twoSideOpReg1.match(s)) : "(" + left.toString() + symbol + right.toString() + ")";
			case s if (twoParamOpReg1.match(s)): symbol + "(" + left.toString() + ", " + right.toString() + ")";
			default: symbol + "(" + left.toString() +  ")";
		}
	}

}
