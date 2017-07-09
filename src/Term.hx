package;

/**
 * knot of a Tree to do math operations at runtime
 * by Sylvio Sell, Rostock 2017
 * 
 **/
	
typedef OperationNode = {symbol:String, left:Term, right:Term, leftOperation:OperationNode, rightOperation:OperationNode, precedence:Int};

class Term {

	/*
	 * Properties
	 * 
	 */
	var operation:Term->Float; // operation function pointer
	var symbol:String; //operator like "+" or parameter name like "x"

	var left:Term;  // left branch of tree
	var right:Term; // right branch of tree
	
	var value:Float;  // leaf of the tree
	
	public var isValue(get, null):Bool; // true ->  it's a value (no left and right)
	inline function get_isValue() return Reflect.compareMethods(operation, opValue);
	
	public var isParam(get, null):Bool; // true -> it's a parameter
	inline function get_isParam() return Reflect.compareMethods(operation, opParam);
	
	public var result(get, null):Float; // result of tree calculation
	inline function get_result() return operation(this);
	

	/*
	 * Constructors
	 * 
	 */
	public function new() {}
	
	public static inline function newValue(f:Float):Term {
		var t:Term = new Term();
		t.setValue(f);
		return t;
	}
	
	public static inline function newParam(id:String, ?term:Term):Term {
		var t:Term = new Term();
		t.setParam(id, term);
		return t;
	}
	
	public static inline function newOperation(s:String, left:Term, ?right:Term):Term {
		var t:Term = new Term();
		t.setOperation(s, left, right);
		return t;
	}

	
	/*
	 * Methods
	 * 
	 */
	public inline function setValue(f:Float) {
		operation = opValue;
		value = f;
		left = null; right = null;
	}
	
	public inline function setParam(id:String, ?term:Term) {
		operation = opParam;
		symbol = id;
		left = term; right = null;
	}
	
	public inline function setOperation(s:String, left:Term, ?right:Term) {
		operation = MathOp.get(s);
		if (operation != null)
		{
			symbol = s;
			this.left = left;
			this.right = right;
		}
		else throw ('"$s" is no valid operation.');
	}

	/*
	 * bind terms to parameters
	 * 
	 */	
	public inline function bind(?params:Map<String, Term>) {
		if (isParam && params.exists(symbol)) left = params.get(symbol);
		else {
			if (left != null) left.bind(params);
			if (right != null) right.bind(params);
		}
		
	}
	
	
	/*
	 * clones the Term Tree
	 * 
	 */	
	public function copy():Term
	{
		if (isValue) return Term.newValue(value);
		else if (isParam) return Term.newParam(symbol, (left!=null) ? left.copy() : null);
		else return Term.newOperation(symbol, left.copy(), (right!=null) ? right.copy() : null);
	}

	
	/*
	 * number of Term nodes
	 * 
	 */	
	public function length(?depth:Null<Int>=null) {
		if (depth == null) depth = -1;
		return switch(symbol) {
			case s if (isValue): 1;
			case s if (isParam): (depth == 0 || left == null) ? 1 : left.length(depth-1); // recursive
			case s if (oneParamOpRegFull.match(s)): 1 + left.length(depth);
			default: 1 + left.length(depth) + right.length(depth);
		}		
	}
	/*
	 * static Function Pointers (to stored in this.operation)
	 * 
	 */	
	static function opValue(t:Term):Float return t.value;
	static function opParam(t:Term):Float if(t.left!=null) return t.left.result else throw('Missing parameter "${t.symbol}".');
	
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
		"cot"  => function(t) return 1/Math.tan(t.left.result),
		"asin" => function(t) return Math.asin(t.left.result),
		"acos" => function(t) return Math.acos(t.left.result),
		"atan" => function(t) return Math.atan(t.left.result),
		
		"atan2"=> function(t) return Math.atan2(t.left.result, t.right.result),
		"log"  => function(t) return Math.log(t.left.result) / Math.log(t.right.result),
		"max"  => function(t) return Math.max(t.left.result, t.right.result),
		"min"  => function(t) return Math.min(t.left.result, t.right.result),		
	];
	static var twoSideOp  = "^,*,/,-,+,%";  // <- order here determines the operator precedence
	static var twoSideOpArray:Array<String> = twoSideOp.split(',');
	static var precedence:Map<String,Int> = [ for (i in 0...twoSideOpArray.length) twoSideOpArray[i] => i ];
	
	static var oneParamOp = "abs,ln,sin,cos,tan,cot,asin,acos,atan"; // functions with one parameter like "sin(2)"
	static var twoParamOp = "atan2,log,max,min";                 // functions with two parameters like "max(a,b)"

	
	/*
	 * Regular Expressions for parsing
	 * 
	 */	
	static var clearSpacesReg:EReg = ~/\s+/g;
	
	static var numberReg:EReg = ~/^([-+]?\d+\.?\d*)/;
	static var paramReg:EReg = ~/^([a-z]+)/i;

	static var oneParamOpReg:EReg = new EReg("^(" + oneParamOp.split(',').join("|")  + ")" , "i");
	static var twoParamOpReg:EReg = new EReg("^(" + twoParamOp.split(',').join("|")  + ")" , "i");
	static var twoSideOpReg: EReg = new EReg("^(" + "\\"+ twoSideOpArray.join("|\\") + ")" , "");

	static var oneParamOpRegFull:EReg = new EReg("^(" + oneParamOp.split(',').join("|")  + ")$" , "i");
	static var twoParamOpRegFull:EReg = new EReg("^(" + twoParamOp.split(',').join("|")  + ")$" , "i");
	static var twoSideOpRegFull: EReg = new EReg("^(" + "\\"+ twoSideOpArray.join("|\\") + ")$" , "");


	/*
	 * Build Tree up from String Math Expression
	 * 
	 */	
	public static function fromString(s:String, ?params:Map<String, Term>):Term
	{
		var t:Term = null;
		var operations:Array<OperationNode> = new Array();
		var e, f:String;
		var negate:Bool;
		
		s = clearSpacesReg.replace(s, ''); // clear whitespaces

		while (s.length != 0) // read in terms from left
		{
			negate = false;
			
			if (numberReg.match(s)) {        // float number
				e = numberReg.matched(1);
				t = newValue(Std.parseFloat(e));
			}
			else if (oneParamOpReg.match(s)) {  // like sin(...)
				f = oneParamOpReg.matched(1);
				s = oneParamOpReg.matchedRight();
				e = getBrackets(s);
				t = newOperation(f, fromString(e.substring(1, e.length-1), params) );
				
			}
			else if (twoParamOpReg.match(s)) { // like atan2(... , ...)
				f = twoParamOpReg.matched(1);
				s = twoParamOpReg.matchedRight();
				e = getBrackets(s);
				if (comataPos == -1) throw(f+"() needs two parameter separated by comma.");
				t = newOperation(f, fromString(e.substring(1, comataPos), params), fromString(e.substring(comataPos+1, e.length-1), params) );
				
			}
			else if (paramReg.match(s)) { // parameter
				e = paramReg.matched(1);
				t = newParam(e, (params==null) ? null : params.get(e));
			}
			else if (twoSideOpReg.match(s)) { // start with +- 
				e = twoSideOpReg.matched(1);
				if (e == "-") {
					t = newValue(0); e = ""; negate = true;
				}
				else if (e != "+") throw("Missing left operand.");
			}
			else {
				e = getBrackets(s);    // term inside brackets
				t = fromString(e.substring(1, e.length - 1), params);
			}
			
			s = s.substr(e.length);
			
			if (operations.length > 0) operations[operations.length - 1].right = t;

			if (twoSideOpReg.match(s)) {   // two side operation symbol
				e = twoSideOpReg.matched(1);
				s = twoSideOpReg.matchedRight();
				operations.push( { symbol:e, left:t, right:null, leftOperation:null, rightOperation:null, precedence:((negate) ? -1 :precedence.get(e)) } );
				if (operations.length > 1) {
					operations[operations.length - 2].rightOperation = operations[operations.length - 1];
					operations[operations.length - 1].leftOperation = operations[operations.length - 2];
				}
			}
		}
		
		if ( operations.length > 0 ) {
			if ( operations[operations.length-1].right == null ) throw("Missing right operand.");
			else {
				operations.sort(function(a:OperationNode, b:OperationNode):Int
				{
					if (a.precedence < b.precedence) return -1;
					if (a.precedence > b.precedence) return 1;
					return 0;
				});
				for (op in operations) {
					t = Term.newOperation(op.symbol, op.left, op.right);
					if (op.leftOperation  != null && op.rightOperation != null) {
						op.rightOperation.leftOperation = op.leftOperation;
						op.leftOperation.rightOperation = op.rightOperation;
					}
					if (op.leftOperation  != null) op.leftOperation.right = t;
					if (op.rightOperation != null) op.rightOperation.left = t;
				}
				return t;
			}
		}
		else return t;
	}
	
	static var comataPos:Int;
	static function getBrackets(s:String):String
	{
		var pos:Int = 1;
		if (s.indexOf("(") == 0) // check that s starts with opening bracket
		{ 
			var i,j,k:Int;
			var openBrackets:Int = 1;
			comataPos = -1;
			while ( openBrackets > 0 )
			{	
				i = s.indexOf("(", pos);
				j = s.indexOf(")", pos);

				// check for commata position
				if (openBrackets == 1) {
					k = s.indexOf(",", pos);
					if (k<j && j>0) comataPos = k;
				}
				
				if ((i>0 && j>0 && i<j)||(i>0 && j<0)) { // found open bracket
					openBrackets++; pos = i + 1;
				}
				else if ((j>0 && i>0 && j<i)||(j>0 && i<0)) { // found close bracket
					openBrackets--; pos = j + 1;
				} else { // no close or open found
					throw("Wrong bracket nesting.");
				}
			}
			if (pos < 3) {
				 throw("Empty brackets.");
			} else return s.substring(0, pos);
		}
		throw("No opening bracket.");
	}
	
	
	/*
	 * Puts out Math Expression as a String
	 * 
	 */
	public function toString(?depth:Null<Int>=null, ?isFirst:Bool=true):String
	{	
		if (depth == null) depth = -1;
		return switch(symbol) {
			case s if (isValue): Std.string(value);
			case s if (isParam): (depth == 0 || left == null) ? symbol : left.toString(depth-1, false); // recursive
			case s if (twoSideOpRegFull.match(s)) : ((isFirst)?'':"(") + left.toString(depth, false) + symbol + right.toString(depth, false) + ((isFirst)?'':")");
			case s if (twoParamOpRegFull.match(s)): symbol + "(" + left.toString(depth) + ", " + right.toString(depth) + ")";
			default: symbol + "(" + left.toString(depth) +  ")";
		}
	}
	
	
	/*
	 * Trim length of math expression
	 * 
	 */
	public function trim():Void
	{
		var len:Int = -1;
		var len_old:Int = 0;
		while (len != len_old) {
			trimFull();
			len_old = len;
			len = length();
		}
	}
	
	function trimFull():Void
	{	
		if (isParam || isValue) return;
		
		switch(symbol) {
			case '+':
				if (left.isValue) {
					if (right.isValue) setValue(result);
					else if (left.value == 0) cutNode(right);
				} else if (right.isValue) {
					if (right.value == 0) cutNode(left);
				}
			case '-':
				if (right.isValue) {
					if (left.isValue) setValue(result);
					else if (right.value == 0) cutNode(left);
				}
			case '*':
				if (left.isValue) {
					if (right.isValue) setValue(result);
					else if (left.value == 1) cutNode(right);
					else if (left.value == 0) setValue(0);
				} else if (right.isValue) {
					if (right.value == 1) cutNode(left);
					else if (right.value == 0) setValue(0);
				}
			case '/':
				if (left.isValue) {
					if (right.isValue) setValue(result);
					else if (left.value == 0) setValue(0);
				} else if (right.isValue) {
					if (right.value == 1) cutNode(left);
				}
			case '^':
				if (left.isValue) {
					if (right.isValue) setValue(result);
					else if (left.value == 1) setValue(1);
					else if (left.value == 0) setValue(0);
				} else if (right.isValue) {
					if (right.value == 1) cutNode(left);
					else if (right.value == 0) setValue(1);
				}
		}
		if (left != null) left.trimFull();
		if (right != null) right.trimFull();
	}
	
	inline function cutNode(t:Term)
	{
		if (t.isValue) setValue(value);
		else if (t.isParam) setParam(t.symbol, t.left);
		else return setOperation(t.symbol, t.left, t.right);
	}
	
	/*
	 * creates the derivate of a term
	 * 
	 */
	public function derivate(p:String):Term
	{	
		return switch (symbol) 
		{
			case s if (isValue): newValue(0);
			case s if (isParam): (symbol==p) ? newValue(1) : newValue(0);
			case '+' | '-':
				newOperation(symbol, left.derivate(p), right.derivate(p));
			case '*':
				newOperation('+',
					newOperation('*', left.derivate(p), right.copy()),
					newOperation('*', left.copy(), right.derivate(p))
				);
			case '/':
				newOperation('/',
					newOperation('-',
						newOperation('*', left.derivate(p) , right.copy()),
						newOperation('*', left.copy(), right.derivate(p))
					),
					newOperation('^', right.copy(), newValue(2) )
				);
			case '^':
				newOperation('*', left.derivate(p),
					newOperation('*', right.copy(),
						newOperation('^', left.copy(),
							newOperation('-', right.copy(), newValue(1))
						)
					)
				);
			case 'sin':
				newOperation('*', left.derivate(p),
					newOperation('cos', left.copy())
				);
			case 'cos':
				newOperation('*', left.derivate(p),
					newOperation('-', newValue(0),
						newOperation('sin', left.copy() )
					)
				);
			case 'tan':
				newOperation('*', left.derivate(p),
					newOperation('+', newValue(1),
						newOperation('^',
							newOperation('tan', left.copy() ),
							newValue(2)
						)
					)
				);
			case 'cot':
				newOperation('*', left.derivate(p),
					newOperation('+', newValue(-1),
						newOperation('^',
							newOperation('cot', left.copy() ),
							newValue(2)
						)
					)
				);
			case 'log':
				newOperation('*', left.derivate(p),
					newOperation('/', newValue(1),
						newOperation('*', right.copy(),
							newOperation('ln', newValue(0), left.copy() )
						)
					)
				);
			case 'ln':
				newOperation('*', left.derivate(p),
					newOperation('/', newValue(1), left.copy())
				);
				
			default: null;	
		}

	}
	
	
	

}