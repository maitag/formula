package;
/**
 * knot of a Tree to do math operations at runtime
 * by Sylvio Sell 2017
 */
class TermNode { // knot of a tree
	
	public var id:String;    // f or x
	public var op:Void->Float; // math operation

	var left:TermNode;   // left branch of tree
	var right:TermNode;  // right branch of tree
	
	var value:Float; // leaf of the tree (todo: <N> ;)
	
	// TESTING first
	public static function test() {
		var left:TermNode  = new TermNode();
		var right:TermNode = new TermNode();
		var t:TermNode = new TermNode();

		left.setOpValue(2);
		right.setOpValue(3);
		
		t.setOp("+", left , right); trace(t.op()); // -> 5
		trace(t.toString());
		t.setOp("*", left ,right); trace(t.op()); // -> 6
		trace(t.toString());
	}
	
	public function new() {}
	
	// ---------------------------------------------------------
	public function setOpValue(f:Float) {
		op = opValue;
		value = f;
	}
	
	public function setOpTerm(t:TermNode) {
		op = opParam;
		left = t;
	}
	
	public function setOp(s:String, left:TermNode, ?right:TermNode) {
		this.left = left; this.right = right;
		switch(s) {
			case '+'   :op = opAdd;
			case '-'   :op = opDif;
			case '*'   :op = opMul;
			case '/'   :op = opDiv;
			case '%'   :op = opMod;
			case '^'   :op = opPow;
			//case 'pow' :op = opPow;
			case 'ln'  :op = opLn;
			case 'log' :op = opLog;
			case 'sin' :op = opSin;
			case 'cos' :op = opCos;
			case 'tan' :op = opTan;
			case 'asin':op = opASin;
			case 'acos':op = opACos;
			case 'atan':op = opATan;
			case 'abs' :op = opAbs;
			case 'max' :op = opMax;
			case 'min' :op = opMin;
		}
	}
	// ------ Function Pointers stored into this.op ------------
	
	function opValue():Float return value;
	function opParam():Float return left.op();

	function opAdd():Float return left.op() + right.op();
	function opDif():Float return left.op() - right.op();
	function opMul():Float return left.op() * right.op();
	function opDiv():Float return left.op() / right.op();
	function opPow():Float return Math.pow(left.op(), right.op());
	
	function opMod():Float return left.op() % right.op();
	
	function opLog():Float return Math.log(right.op()) / Math.log(left.op());
	function opLn():Float return Math.log(left.op());
	
	function opSin():Float return Math.sin(left.op());
	function opCos():Float return Math.cos(left.op());
	function opTan():Float return Math.tan(left.op());
	function opASin():Float return Math.asin(left.op());
	function opACos():Float return Math.acos(left.op());
	function opATan():Float return Math.atan(left.op());
	
	function opAbs():Float return Math.abs(left.op());
	
	function opMax():Float return Math.max(left.op(), right.op());
	function opMin():Float return Math.min(left.op(), right.op());

	// ------ Build Tree up from String Math Expression -------

	// ------ Put out Math Expression as a String -------------
	public function toString():String
	{
		var out:String = "";
		
		if ((op != opValue) && (op != opParam) &&
		    (op != opLog)   && (op != opLn)    &&
		    (op != opSin)   && (op != opCos)   && (op != opTan)  &&
		    (op != opASin)  && (op != opACos)  && (op != opATan) &&
		    (op != opAbs)   && (op != opMax)   && (op != opMin)
		   )
		{  out += "(" + left.toString();
		}
		trace(op);
		
		if (Reflect.compareMethods(op, opAdd)) out += "+";
		else if (Reflect.compareMethods(op, opMul)) out += "*";
		/*
		switch(op) {
			case opAdd : out+="+";
			case opDif : out+="-";
			case opMul : out+="*";
			case opDiv : out+="/";
			case opMod : out+="%";
			case opPow : out+="^";
			case opLn  : out+="ln(";
			case opLog : out+=")log(";
			case opSin : out+="sin(";
			case opCos : out+="cos(";
			case opTan : out+="tan(";
			case opASin: out+="asin(";
			case opACos: out+="acos(";
			case opATan: out+="atan(";
			case opAbs : out+="abs(";
			case opMax : out+="max(";
			case opMin : out+="min(";
		}
		*/
		if (Reflect.compareMethods(op, opValue))
		{
			out += value;
		}
		else
		{
			if (op == opParam)
			{
				out += "P";//TODO!!!
				//printf("%c",(char)((k1->parameter)-p+97));
			}
			else out += right.toString();
		}
		
		if ((op != opValue) && (op != opParam)) out += ")";

		return out;

	} //end print_tree  ---------------------------------

}