package;

/**
 * knot of a Tree to do math operations at runtime
 * by Sylvio Sell, Rostock 2017
 * 
 **/
	
typedef OperationNode = {symbol:String, left:TermNode, right:TermNode, leftOperation:OperationNode, rightOperation:OperationNode, precedence:Int};

class TermNode {

	/*
	 * Properties
	 * 
	 */
	var operation:TermNode->Float; // operation function pointer
	var symbol:String; //operator like "+" or parameter name like "x"

	var left:TermNode;  // left branch of tree
	var right:TermNode; // right branch of tree
	
	var value:Float;  // leaf of the tree
	
	public var name(get, set):String;  // name is stored into a param-TermNode at root of the tree
	inline function get_name():String return (isName) ? symbol : null;
	inline function set_name(name:String):String {
		if (name == null && isName) {
			copyNodeFrom(left);
		}
		else {
			if (!nameReg.match(name)) throw('Not allowed characters for name $name".');
			if (isName) symbol = name else setName(name, (left != null) ? left.copyNode() : null);
		}
		return name;
	}
	
	/*
	 * gets depth of parameter bindings
	 * 
	 */	
	public inline function depth():Int {
		var l:Int = 0;
		var r:Int = 0;
		if (left != null) l = left.depth();
		if (right != null) r = right.depth();
		return( (l>r) ? l : r);
	}
	
	
	/*
	 * Check Type of TermNode
	 * 
	 */
	public var isName(get, null):Bool; // true -> root TermNode that holds name
	inline function get_isName():Bool return Reflect.compareMethods(operation, opName);
	
	public var isParam(get, null):Bool; // true -> it's a parameter
	inline function get_isParam():Bool return Reflect.compareMethods(operation, opParam);
	
	public var isValue(get, null):Bool; // true ->  it's a value (no left and right)
	inline function get_isValue():Bool return Reflect.compareMethods(operation, opValue);
	
	public var isOperation(get, null):Bool; // true ->  it's a operation TermNode
	inline function get_isOperation():Bool return !(isName||isParam||isValue);
	
	/*
	 * Calculates result of all Operations
	 * throws error if there is unbind param
	 */
	public var result(get, null):Float; // result of tree calculation
	inline function get_result():Float return operation(this);

	
	/*
	 * Constructors
	 * 
	 */
	public function new() {}
	
	public static inline function newName(name:String, ?term:TermNode):TermNode {
		var t:TermNode = new TermNode();
		t.setName(name, term);
		return t;
	}
	
	public static inline function newParam(name:String, ?term:TermNode):TermNode {
		var t:TermNode = new TermNode();
		t.setParam(name, term);
		return t;
	}
	
	public static inline function newValue(f:Float):TermNode {
		var t:TermNode = new TermNode();
		t.setValue(f);
		return t;
	}
	
	public static inline function newOperation(s:String, ?left:TermNode, ?right:TermNode):TermNode {
		var t:TermNode = new TermNode();
		t.setOperation(s, left, right);
		return t;
	}

	
	/*
	 * atomic methods
	 * 
	 */
	public inline function setName(name:String, ?term:TermNode) {
		operation = opName;
		symbol = name;
		left = term; right = null;
	}
	
	public inline function setParam(name:String, ?term:TermNode) {
		operation = opParam;
		symbol = name;
		left = term; right = null;
	}
	
	public inline function setValue(f:Float) {
		operation = opValue;
		value = f;
		left = null; right = null;
	}
	
	public inline function setOperation(s:String, ?left:TermNode, ?right:TermNode) {
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
	public inline function bind(params:Map<String, TermNode>):TermNode {
		if (isParam && params.exists(symbol)) left = params.get(symbol);
		else {
			if (left != null) left.bind(params);
			if (right != null) right.bind(params);
		}
		return this;
	}
	
	
	/*
	 * unbind terms that is bind to parameter-names
	 * 
	 */	
	public inline function unbind(params:Array<String>):TermNode {
		if (isParam && params.indexOf(symbol)>=0) left = null;
		else {
			if (left != null) left.unbind(params);
			if (right != null) right.unbind(params);
		}
		return this;
	}
	
	/*
	 * unbind terms
	 * 
	 */	
	public inline function unbindTerm(params:Array<TermNode>) {
		/*
		if ( params.indexOf(left) >= 0 )
		{
			copyNodeFrom(right);
		}
		
		if (isParam && params.indexOf(symbol)>=0) left = null;
		else {
			if (left != null) left.unbind(params);
			if (right != null) right.unbind(params);
		}
		*/
	}
	
	/*	
	public function debugBindings() {
		trace(name + ": " + node.toString(0));// + " -> " + node.toString());
		for (k in bindTo.keys()) trace("   " + bindTo.get(k) + " --> "+k.name + ":" + k.node.toString(0));
		for (k in bindings.keys()) trace("   " + bindings.get(k).node.toString(0) + " <-- " + k);
	}
	*/
	
	/*
	 * returns a clone of full Tree, starting with this TermNode
	 * 
	 */	
	public function copy():TermNode // TODO: depth params like in toString
	{
		if (isValue) return TermNode.newValue(value);
		else if (isName) return TermNode.newName(symbol, (left!=null) ? left.copy() : null);
		else if (isParam) return TermNode.newParam(symbol, (left!=null) ? left.copy() : null);
		else return TermNode.newOperation(symbol, left.copy(), (right!=null) ? right.copy() : null);
	}

	/*
	 * returns a clone of this TermNode only
	 * 
	 */	
	function copyNode():TermNode
	{
		if (isValue) return TermNode.newValue(value);
		else if (isName) return TermNode.newName(symbol, (left!=null) ? left : null);
		else if (isParam) return TermNode.newParam(symbol, (left!=null) ? left : null);
		else return TermNode.newOperation(symbol, left, (right!=null) ? right : null);
	}

	/*
	 * copy all from other TermNode to this
	 * 
	 */	
	inline function copyNodeFrom(t:TermNode) {
		if (t.isValue) setValue(value);
		else if (t.isName) setName(t.symbol, t.left);
		else if (t.isParam) setParam(t.symbol, t.left);
		else return setOperation(t.symbol, t.left, t.right);
	}
	
	
	/*
	 * number of TermNodes inside Tree
	 * 
	 */	
	public function length(?depth:Null<Int>=null) {
		if (depth == null) depth = -1;
		return switch(symbol) {
			case s if (isValue): 1;
			case s if (isName):  (left == null) ? 0 : left.length(depth);
			case s if (isParam): (depth == 0 || left == null) ? 1 : left.length(depth-1);
			case s if (oneParamOpRegFull.match(s)): 1 + left.length(depth);
			default: 1 + left.length(depth) + right.length(depth);
		}		
	}
	/*
	 * static Function Pointers (to stored in this.operation)
	 * 
	 */	
	
	static function opName(t:TermNode) :Float if(t.left!=null) return t.left.result else throw('Empty function "${t.symbol}".');
	static function opParam(t:TermNode):Float if(t.left!=null) return t.left.result else throw('Missing parameter "${t.symbol}".');
	static function opValue(t:TermNode):Float return t.value;
	
	static var MathOp:Map<String, TermNode->Float> = [
		// two side operations
		"+"    => function(t) return t.left.result + t.right.result,
		"-"    => function(t) return t.left.result - t.right.result,
		"*"    => function(t) return t.left.result * t.right.result,
		"/"    => function(t) return t.left.result / t.right.result,
		"^"    => function(t) return Math.pow(t.left.result, t.right.result),
		"%"    => function(t) return t.left.result % t.right.result,
		
		// function without params (constants)
		"e"    => function(t) return Math.exp(1),
		"pi"   => function(t) return Math.PI,

		// function with one param
		"abs"  => function(t) return Math.abs(t.left.result),
		"ln"   => function(t) return Math.log(t.left.result),
		"sin"  => function(t) return Math.sin(t.left.result),
		"cos"  => function(t) return Math.cos(t.left.result),
		"tan"  => function(t) return Math.tan(t.left.result),
		"cot"  => function(t) return 1/Math.tan(t.left.result),
		"asin" => function(t) return Math.asin(t.left.result),
		"acos" => function(t) return Math.acos(t.left.result),
		"atan" => function(t) return Math.atan(t.left.result),
		
		// function with two params
		"atan2"=> function(t) return Math.atan2(t.left.result, t.right.result),
		"log"  => function(t) return Math.log(t.right.result) / Math.log(t.left.result),
		"max"  => function(t) return Math.max(t.left.result, t.right.result),
		"min"  => function(t) return Math.min(t.left.result, t.right.result),		
	];
	static var twoSideOp  = "^,/,*,-,+,%";  // <- order here determines the operator precedence
	static var twoSideOpArray:Array<String> = twoSideOp.split(',');
	static var precedence:Map<String,Int> = [ for (i in 0...twoSideOpArray.length) twoSideOpArray[i] => i ];
	
	static var constantOp = "e,pi"; // functions without parameters like "e() or pi()"
	static var oneParamOp = "abs,ln,sin,cos,tan,cot,asin,acos,atan"; // functions with one parameter like "sin(2)"
	static var twoParamOp = "atan2,log,max,min";                 // functions with two parameters like "max(a,b)"

	
	/*
	 * Regular Expressions for parsing
	 * 
	 */	
	static var clearSpacesReg:EReg = ~/\s+/g;
	
	static var numberReg:EReg = ~/^([-+]?\d+\.?\d*)/;
	static var paramReg:EReg = ~/^([a-z]+)/i;

	static var constantOpReg:EReg = new EReg("^(" + constantOp.split(',').join("|")  + ")\\(" , "i");
	static var oneParamOpReg:EReg = new EReg("^(" + oneParamOp.split(',').join("|")  + ")\\(" , "i");
	static var twoParamOpReg:EReg = new EReg("^(" + twoParamOp.split(',').join("|")  + ")\\(" , "i");
	static var twoSideOpReg: EReg = new EReg("^(" + "\\"+ twoSideOpArray.join("|\\") + ")" , "");

	static var constantOpRegFull:EReg = new EReg("^(" + constantOp.split(',').join("|")  + ")$" , "i");
	static var oneParamOpRegFull:EReg = new EReg("^(" + oneParamOp.split(',').join("|")  + ")$" , "i");
	static var twoParamOpRegFull:EReg = new EReg("^(" + twoParamOp.split(',').join("|")  + ")$" , "i");
	static var twoSideOpRegFull: EReg = new EReg("^(" + "\\"+ twoSideOpArray.join("|\\") + ")$" , "");

	static var nameReg:EReg = ~/^([a-z]+):/i;

	/*
	 * Build Tree up from String Math Expression
	 * 
	 */	
	public static inline function fromString(s:String, ?bindings:Map<String, TermNode>):TermNode {
		if (nameReg.match(s)) {
			var name:String = nameReg.matched(1);
			s = s.substr(name.length + 1);
			return newName(name, parseString(s, bindings));
		}
		return parseString(s, bindings);
	}
	
	public static function parseString(s:String, ?params:Map<String, TermNode>):TermNode {
		var t:TermNode = null;
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
			else if (constantOpReg.match(s)) {  // like e() or pi()
				e = constantOpReg.matched(1);
				t = newOperation(e);				
			}
			else if (oneParamOpReg.match(s)) {  // like sin(...)
				f = oneParamOpReg.matched(1);
				s = "("+oneParamOpReg.matchedRight();
				e = getBrackets(s);
				t = newOperation(f, parseString(e.substring(1, e.length-1), params) );
				
			}
			else if (twoParamOpReg.match(s)) { // like atan2(... , ...)
				f = twoParamOpReg.matched(1);
				s = "("+twoParamOpReg.matchedRight();
				e = getBrackets(s);
				var p1:String = e.substring(1, comataPos);
				var p2:String = e.substring(comataPos + 1, e.length - 1);
				if (comataPos == -1) throw(f+"() needs two parameter separated by comma.");
				t = newOperation(f, parseString(p1, params), parseString(p2, params) );
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
				t = parseString(e.substring(1, e.length - 1), params);
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
					t = TermNode.newOperation(op.symbol, op.left, op.right);
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
	static function getBrackets(s:String):String {
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
				if (openBrackets == 1 && comataPos == -1) {
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
	public function toString(?depth:Null<Int>=null, ?isFirst:Bool=true):String {	
		if (depth == null) depth = -1;
		return switch(symbol) {
			case s if (isValue): Std.string(value);
			case s if (isName):  (left == null) ? symbol : left.toString(depth, false); // recursive
			case s if (isParam): (depth == 0 || left == null) ? symbol : left.toString(depth-1, false); // recursive
			case s if (twoSideOpRegFull.match(s)) :
				if (symbol == '-' && left.isValue && left.value == 0) symbol + right.toString(depth, false);
				else ((isFirst)?'':"(") + left.toString(depth, false) + symbol + right.toString(depth, false) + ((isFirst)?'':")");
			case s if (twoParamOpRegFull.match(s)): symbol + "(" + left.toString(depth) + "," + right.toString(depth) + ")";
			case s if (constantOpRegFull.match(s)): symbol + "()";
			default: symbol + "(" + left.toString(depth) +  ")";
		}
	}
	
	
	/*
	 * enrolls all toString
	 * 
	 */
	public function debug(maxDepth:Null<Int> = null) {
		//TODO
		var out:String = "";
		for (i in 0 ... depth()) {
			out += " -> " + name + "=" + toString(i);
		}
		trace(out);
	}
	
	
	/*
	 * Trim length of math expression
	 * 
	 */
	public function simplify():TermNode {
		var len:Int = -1;
		var len_old:Int = 0;
		while (len != len_old) {
			if (isName && left != null) left.simplifyStep() else simplifyStep();
			len_old = len;
			len = length();
		}
		return this;
	}
	
	function simplifyStep():Void {	
		if (isName || isParam || isValue) return;
		
		switch(symbol) {
			case '+':
				if (left.isValue) {
					if (right.isValue) setValue(result);
					else if (left.value == 0) copyNodeFrom(right);
				} else if (right.isValue) {
					if (right.value == 0) copyNodeFrom(left);
				}
			case '-':
				if (right.isValue) {
					if (left.isValue) setValue(result);
					else if (right.value == 0) copyNodeFrom(left);
				}
			case '*':
				if (left.isValue) {
					if (right.isValue) setValue(result);
					else if (left.value == 1) copyNodeFrom(right);
					else if (left.value == 0) setValue(0);
				} else if (right.isValue) {
					if (right.value == 1) copyNodeFrom(left);
					else if (right.value == 0) setValue(0);
				}
			case '/':
				if (left.isValue) {
					if (right.isValue) setValue(result);
					else if (left.value == 0) setValue(0);
				} else if (right.isValue) {
					if (right.value == 1) copyNodeFrom(left);
				}
			case '^':
				if (left.isValue) {
					if (right.isValue) setValue(result);
					else if (left.value == 1) setValue(1);
					else if (left.value == 0) setValue(0);
				} else if (right.isValue) {
					if (right.value == 1) copyNodeFrom(left);
					else if (right.value == 0) setValue(1);
				}
		}
		if (left != null) left.simplifyStep();
		if (right != null) right.simplifyStep();
	}
	
	/*
	 * creates a new term that is derivate of a given term 
	 * 
	 */
	public function derivate(p:String):TermNode {	
		return switch (symbol) 
		{
			case s if (isName): newName( symbol, left.derivate(p) );
			case s if (isValue || constantOpRegFull.match(s)): newValue(0);
			case s if (isParam): (symbol == p) ? newValue(1) : newValue(0);
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
						newOperation('*', left.derivate(p), right.copy()),
						newOperation('*', left.copy(), right.derivate(p))
					),
					newOperation('^', right.copy(), newValue(2) )
				);
			case '^':
				if (left.symbol == 'e')
					newOperation('*', right.derivate(p),
						newOperation('^', newOperation('e'), left.copy())
					);
				else
					newOperation('*', 
						newOperation('^', left.copy(), right.copy()),
						newOperation('*',
							right.copy(),
							newOperation('ln', left.copy())
						).derivate(p)
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
				newOperation('/',
					newValue(1),
					newOperation('tan', left.copy())
				).derivate(p);				
			case 'atan':
				newOperation('*', left.derivate(p),
					newOperation('/', newValue(1),
						newOperation('+', newValue(1),
							newOperation('^', left.copy(), newValue(2))
						)
					)
				);
			case 'atan2':
				newOperation('/', 
					newOperation('-',
						newOperation('*', right.copy(), left.derivate(p)),
						newOperation('*', left.copy(), right.derivate(p))
					),
					newOperation('+',
						newOperation('*', left.copy(), left.copy()),
						newOperation('*', right.copy(), right.copy())
					)
				);
			case 'asin':
				newOperation('*', left.derivate(p),
					newOperation('/', newValue(1),
						newOperation('^',
							newOperation('-', newValue(1),
								newOperation('^', left.copy(), newValue(2))
							), newOperation('/', newValue(1), newValue(2))
						)
					)
				);
			case 'acos':
				newOperation('*', left.derivate(p),
					newOperation('-', newValue(0),
						newOperation('/', newValue(1),
							newOperation('^',
								newOperation('-', newValue(1),
									newOperation('^', left.copy(), newValue(2))
								), newOperation('/', newValue(1), newValue(2))
							)
						)
					)
				);
			case 'log':
				newOperation('/',
					newOperation('ln', right.copy()),
					newOperation('ln', left.copy())
				).derivate(p);
			case 'ln':
				newOperation('*', left.derivate(p),
					newOperation('/', newValue(1), left.copy())
				);
				
			default: throw('derivation of "$symbol" not implemented');	
		}

	}
	
	
	

}
