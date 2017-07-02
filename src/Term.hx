package;
/**
 * knot of a Tree to do math operations at runtime
 * by Sylvio Sell 2017
 */
class Term { // knot of a tree
	public var name:String;    // f or x
	public var op:Void->Float; // math operation

	var left:Term;   // left branch of tree
	var right:Term;  // right branch of tree
	
	var value:Float; // leaf of the tree (todo: <N> ;)
	
	// TESTING first
	public static function test() {
		var left  = new Term();
		left.setOpValue(2);
		
		var right = new Term();
		right.setOpValue(3);
		
		var t = new Term();
		t.setOp("+", left ,right);
		
		trace(t.op());
	}
	
	public function new() {}
	
	// ---------------------------------------------------------
	public function setOpValue(f:Float) {
		op = opValue;
		value = f;
	}
	
	public function setOpTerm(t:Term) {
		op = opParam;
		left = t;
	}
	
	public function setOp(s:String, left:Term, ?right:Term) {
		this.left = left; this.right = right;
		switch(s) {
			case '+':   op = opAdd;
			case '-':   op = opDif;
			case '*':   op = opMul;
			case '/':   op = opDiv;
			case '%':   op = opMod;
			case '^':   op = opPow;
			case 'pow': op = opPow;
			case 'ln':  op = opLn;
			case 'log': op = opLog;
			case 'sin': op = opSin;
			case 'cos': op = opCos;
			case 'tan': op = opTan;
			case 'asin':op = opASin;
			case 'acos':op = opACos;
			case 'atan':op = opATan;
			case 'abs': op = opAbs;
			case 'max': op = opMax;
			case 'min': op = opMin;
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
	
}