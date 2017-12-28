package;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;

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
	public var symbol:String; //operator like "+" or parameter name like "x"

	public var left:TermNode;  // left branch of tree
	public var right:TermNode; // right branch of tree
	
	public var value:Float;  // leaf of the tree
	
	public var name(get, set):String;  // name is stored into a param-TermNode at root of the tree
	inline function get_name():String return (isName) ? symbol : null;
	inline function set_name(name:String):String {
		if (name == null && isName) {
			copyNodeFrom(left);
		}
		else {
			if (!nameRegFull.match(name)) throw('Not allowed characters for name $name".');
			if (isName) symbol = name else setName(name, copyNode());
		}
		return name;
	}
	
	/*
	 * returns depth of parameter bindings
	 * 
	 */	
	public inline function depth():Int {
		if (isName && left != null) return left._depth();
		else return _depth();
	}
	public inline function _depth():Int {
		var l:Int = 0;
		var r:Int = 0;
		var d:Int = 0;
		if (isParam) {
			if (left == null) d = 0;
			else if (!left.isName) d = 1;
		}
		else if (isName) d = 1; 
		
		if (left != null) l = left._depth();
		if (right != null) r = right._depth();
		
		return( d + ((l>r) ? l : r));
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
	public inline function set(term:TermNode):TermNode {
		if (isName) {
			if (!term.isName) left = term.copy();
			else if (term.left != null) left = term.left.copy();
			else left = null;
		}
		else {
			if (!term.isName) copyNodeFrom(term.copy());
			else if (term.left != null) copyNodeFrom(term.left.copy());
			//else return null;
		}
		return this;
	}
	
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
	
	public inline function setValue(f:Float):Void {
		operation = opValue;
		symbol = null;
		value = f;
		left = null; right = null;
	}
	
	public inline function setOperation(s:String, ?left:TermNode, ?right:TermNode):Void {
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
	 * returns an array of parameter-names
	 * 
	 */	
	public inline function params():Array<String> {
		var ret:Array<String> = new Array();
		if (isParam) {
			ret.push(symbol);
		}
		else {
			if (left != null ) {
				for (i in left.params()) if (ret.indexOf(i) < 0) ret.push(i);
			}
			if (right != null) {
				for (i in right.params()) if (ret.indexOf(i) < 0) ret.push(i);
			}
		}
		return ret;
	}
	
	
	/*
	 * bind terms to parameters
	 * 
	 */	
	public inline function bind(params:Map<String, TermNode>):TermNode {
		if (isParam) {
			if (params.exists(symbol)) left = params.get(symbol);
		}
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
		if (isParam) {
			if (params.indexOf(symbol)>=0) left = null;
		}
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
	public inline function unbindTerm(params:Map<Formula, String>):TermNode {
		if (left != null) {
			if (params.get(left) != null)
				left = newParam(params.get(left));
			else left.unbindTerm(params);
		}
		if (right != null) {
			if (params.get(right) != null)
				right = newParam(params.get(right));
			else right.unbindTerm(params);
		}
		return this;
	}
	
	
	/*
	 * unbind all terms that is bind to parameter-names
	 * 
	 */	
	public inline function unbindAll():TermNode {
		return unbind(params());
	}	
	
	/*
	 * returns a clone of full Tree, starting with this TermNode
	 * 
	 */	
	public function copy():TermNode // TODO: depth params like in toString
	{
		if (isValue) return TermNode.newValue(value);
		else if (isName) return TermNode.newName(symbol, (left!=null) ? left.copy() : null);
		else if (isParam) return TermNode.newParam(symbol, (left!=null) ? left.copy() : null);
		else return TermNode.newOperation(symbol, (left!=null) ? left.copy() : null, (right!=null) ? right.copy() : null);
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
	public inline function copyNodeFrom(t:TermNode) {
		if (t.isValue) setValue(t.value);
		else if (t.isName) setName(t.symbol, t.left);
		else if (t.isParam) setParam(t.symbol, t.left);
		else setOperation(t.symbol, t.left, t.right);
	}
	
	
	/*
	 * number of TermNodes inside Tree
	 * 
	 */	
	public function length(?depth:Null<Int>=null):Int {
		if (depth == null) depth = -1;
		return switch(symbol) {
			case s if (isValue): 1;
			case s if (isName):  (left == null) ? 0 : left.length(depth);
			case s if (isParam): (depth == 0 || left == null) ? 1 : left.length(depth-1);
			case s if (constantOpRegFull.match(s)): 1;
			case s if (oneParamOpRegFull.match(s)): 1 + left.length(depth);
			default: 1 + left.length(depth) + right.length(depth);
		}		
	}
			
	
	/*
	 * returns true if other term is equal in data and structure
	 * 
	 */	
	public function isEqual(t:TermNode, ?compareNames=false, ?compareParams=false):Bool
	{
		if ( !compareNames && (isName || t.isName) ) {
			if (isName   && left   != null) return left.isEqual(t, compareNames, compareParams);
			if (t.isName && t.left != null) return isEqual(t.left, compareNames, compareParams);
			return (isName && t.isName);
		}
		
		if ( !compareParams && (isParam || t.isParam) ) {
			if (isParam   && left   != null) return left.isEqual(t, compareNames, compareParams);
			if (t.isParam && t.left != null) return isEqual(t.left, compareNames, compareParams);
			return (isParam && t.isParam);
		}
		
		var is_equal:Bool = false;
		
		if (isValue && t.isValue)
			is_equal = (value==t.value);
		else if ( (isName && t.isName) || (isParam && t.isParam) || (isOperation && t.isOperation) )
			is_equal = (symbol==t.symbol);
		
		if (left != null) {
			if (t.left != null) is_equal = is_equal && left.isEqual(t.left, compareNames, compareParams);
			else is_equal = false;
		}
		if (right != null) {
			if (t.right != null) is_equal = is_equal && right.isEqual(t.right, compareNames, compareParams);
			else is_equal = false;		
		}

		return is_equal;
	}
	
	/*
	 * static Function Pointers (to stored in this.operation)
	 * 
	 */		
	static function opName(t:TermNode) :Float if (t.left!=null) return t.left.result else throw('Empty function "${t.symbol}".');
	static function opParam(t:TermNode):Float if (t.left!=null) return t.left.result else throw('Missing parameter "${t.symbol}".');
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
	
	static var twoSideOp_ = "^,/,*,-,+,%";  // <- order here determines the operator precedence
	static var constantOp_ = "e,pi"; // functions without parameters like "e() or pi()"
	static var oneParamOp_ = "abs,ln,sin,cos,tan,cot,asin,acos,atan"; // functions with one parameter like "sin(2)"
	static var twoParamOp_ = "atan2,log,max,min";                 // functions with two parameters like "max(a,b)"

	static public var twoSideOp :Array<String> = twoSideOp_.split(',');
	static public var constantOp:Array<String> = constantOp_.split(',');
	static public var oneParamOp:Array<String> = oneParamOp_.split(',');
	static public var twoParamOp:Array<String> = twoParamOp_.split(',');
	
	static var precedence:Map<String,Int> = [ for (i in 0...twoSideOp.length) twoSideOp[i] => i ];
	

	
	/*
	 * Regular Expressions for parsing
	 * 
	 */	
	static var clearSpacesReg:EReg = ~/\s+/g;
	
	static var numberReg:EReg = ~/^([-+]?\d+\.?\d*)/;
	static var paramReg:EReg = ~/^([a-z]+)/i;

	static var constantOpReg:EReg = new EReg("^(" + constantOp.join("|")  + ")\\(\\)" , "i");
	static var oneParamOpReg:EReg = new EReg("^(" + oneParamOp.join("|")  + ")\\(" , "i");
	static var twoParamOpReg:EReg = new EReg("^(" + twoParamOp.join("|")  + ")\\(" , "i");
	static var twoSideOpReg: EReg = new EReg("^(" + "\\"+ twoSideOp.join("|\\") + ")" , "");

	static public var constantOpRegFull:EReg = new EReg("^(" + constantOp.join("|")  + ")$" , "i");
	static public var oneParamOpRegFull:EReg = new EReg("^(" + oneParamOp.join("|")  + ")$" , "i");
	static public var twoParamOpRegFull:EReg = new EReg("^(" + twoParamOp.join("|")  + ")$" , "i");
	static public var twoSideOpRegFull: EReg = new EReg("^(" + "\\"+ twoSideOp.join("|\\") + ")$" , "");

	static var nameReg:EReg = ~/^([a-z]+)[:=]/i;
	static var nameRegFull:EReg = ~/^([a-z]+)$/i;

	/*
	 * Build Tree up from String Math Expression
	 * 
	 */	
	public static inline function fromString(s:String, ?bindings:Map<String, TermNode>):TermNode {
		s = clearSpacesReg.replace(s, ''); // clear whitespaces
		if (nameReg.match(s)) {
			var name:String = nameReg.matched(1);
			s = s.substr(name.length + 1);
			if (s == "") throw("Can't parse Term from empty string.");
			return newName(name, parseString(s, bindings));
		}
		if (s == "") throw("Can't parse Term from empty string.");
		return parseString(s, bindings);
	}
	
	static function parseString(s:String, ?params:Map<String, TermNode>):TermNode {
		var t:TermNode = null;
		var operations:Array<OperationNode> = new Array();
		var e, f:String;
		var negate:Bool;
		
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
				e+= "()";
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
			} else if (s.length > 0) throw("Missing operation.");
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
	public function toString(?depth:Null<Int> = null, ?plOut:String = null):String {
		var t:TermNode = this;
		if (isName) t = left;
		var options:Int;
		switch (plOut) {
			case 'glsl': options = noNeg|forceFloat|forcePow|forceMod|forceLog|forceAtan|forceConst;
			default:     options = 0;
		}
		return (left != null || !isName) ? t._toString(depth, options) : '';
	}
	// options
	public static inline var noNeg:Int = 1;
	public static inline var forceFloat:Int = 2;
	public static inline var forcePow:Int = 4;
	public static inline var forceMod:Int = 8;
	public static inline var forceLog:Int = 16;
	public static inline var forceAtan:Int = 32;
	public static inline var forceConst:Int = 64;
	
	inline function _toString(depth:Null<Int>, options:Int, ?isFirst:Bool=true):String {	
		if (depth == null) depth = -1;
		return switch(symbol) {
			case s if (isValue): floatToString(value, options);
			//case s if (isName && isFirst):  (left == null) ? symbol : left.toString(depth, false);
			case s if (isName):  (depth == 0 || left == null) ? symbol : left._toString(depth-1, options, false);
			case s if (isParam): (depth == 0 || left == null) ? symbol : left._toString(depth-((left.isName)?0:1), options, false);
			case s if (twoSideOpRegFull.match(s)) :
				if (symbol == "-" && left.isValue && left.value == 0 && options&noNeg == 0) symbol + right._toString(depth, options, false);
				else if (symbol == "^" && options&forcePow > 0) 'pow' + "(" + left._toString(depth, options) + "," + right._toString(depth, options) + ")";
				else if (symbol == "%" && options&forceMod > 0) 'mod' + "(" + left._toString(depth, options) + "," + right._toString(depth, options) + ")";
				else ((isFirst)?"":"(") + left._toString(depth, options, false) + symbol + right._toString(depth, options, false) + ((isFirst)?'':")");
			case s if (twoParamOpRegFull.match(s)):
				if (symbol == "log" && options&forceLog > 0) "(log(" + right._toString(depth, options) + ")/log(" + left._toString(depth, options) + "))";
				else if (symbol == "atan2" && options&forceAtan > 0) "atan(" + left._toString(depth, options) + "," + right._toString(depth, options) + ")";
				else symbol + "(" + left._toString(depth, options) + "," + right._toString(depth, options) + ")";
			case s if (constantOpRegFull.match(s)):
				if (symbol == "pi" && options & forceConst > 0) Std.string(Math.PI);
				else if (symbol == "e" && options&forceConst > 0) Std.string(Math.exp(1));
				else symbol + "()";
			default:
				if (symbol == "ln" && options&forceLog > 0) 'log' + "(" + left._toString(depth, options) + ")";
				else symbol + "(" + left._toString(depth, options) +  ")";
		}
	}
	
	inline function floatToString(value:Float, ?options:Int = 0):String {
		var s:String = Std.string(value);
		if (options&forceFloat > 0 && s.indexOf('.') == -1) s += ".0";
		return s;
	}
	
	/*
	 * enrolls terms and subterms for debugging
	 * 
	 */
	public function debug() {
		//TODO
		var out:String = "";// "(" + depth() + ")";
		for (i in 0 ... depth()+1) {
			if (i == 0) out += ((name != null) ? name : "?") + " = "; else out += " -> ";
			out += toString(i);
		}
		trace(out);
	}
	
	/*
	 * packs a TermNode and all sub-terms into Bytes
	 * 
	 */
	public function toBytes():Bytes {
		var b = new BytesOutput();
		_toBytes(b);
		return b.getBytes();
	}
	
	inline function _toBytes(b:BytesOutput) {
		// optimize (later to do): needs only 3 bit per TermNode type!
		if (isValue) {
			b.writeByte(0);
			b.writeFloat(value);
		}
		else if (isName) {
			b.writeByte((left!=null) ? 1:2);
			_writeString(symbol, b);
			if (left!=null) left._toBytes(b);
		}
		else if (isParam) {
			b.writeByte((left!=null) ? 3:4);
			_writeString(symbol, b);
			if (left!=null) left._toBytes(b);
		}
		else if (isOperation) {
			b.writeByte(5);
			var i:Int = twoSideOp.concat(constantOp.concat(oneParamOp.concat(twoParamOp))).indexOf(symbol);
			if (i > -1)	{
				b.writeByte(i);
				if (oneParamOpRegFull.match(symbol)) left._toBytes(b);
				else if (twoSideOpRegFull.match(symbol) || twoParamOpRegFull.match(symbol) ) { 
					left._toBytes(b);
					right._toBytes(b);
				}
			}
			else throw("Error in _toBytes");
		}
		else throw("Error in _toBytes");
	}
	
	inline function _writeString(s:String, b:BytesOutput):Void {
		b.writeByte((s.length<255) ? s.length: 255);
		for (i in 0...((s.length<255) ? s.length: 255)) b.writeByte(symbol.charCodeAt(i));
	}
	/*
	 * unserialize packed Bytes-Term to create a TermNode structure
	 * 
	 */
	public static function fromBytes(b:Bytes):TermNode {
		return _fromBytes(new BytesInput(b));	 
	}
	
	static inline function _fromBytes(b:BytesInput):TermNode {
		return switch (b.readByte()) {
			case 0: TermNode.newValue(b.readFloat());
			case 1: TermNode.newName( _readString(b), _fromBytes(b) );
			case 2: TermNode.newName( _readString(b) );
			case 3: TermNode.newParam( _readString(b), _fromBytes(b) );
			case 4: TermNode.newParam( _readString(b) );
			case 5: 
				var op:String = twoSideOp.concat(constantOp.concat(oneParamOp.concat(twoParamOp)))[b.readByte()];
				if (oneParamOpRegFull.match(op)) TermNode.newOperation( op, _fromBytes(b) );
				else if (twoSideOpRegFull.match(op) || twoParamOpRegFull.match(op) ) TermNode.newOperation( op, _fromBytes(b), _fromBytes(b) );
				else TermNode.newOperation( op );
			default: throw("Error in _fromBytes");
		}
	}
	
	static inline function _readString(b:BytesInput):String {
		var len:Int = b.readByte();
		var s:String = "";
		for (i in 0...len) s += String.fromCharCode(b.readByte());
		return s;
	}
	
	
	/**************************************************************************************
	 *                                                                                    *
	 * various math operations transformation and more.        *
	 *                                                                                    *
	 *                                                                                    *
	 **************************************************************************************/
	
	/*
	 * creates a new term that is derivate of a given term 
	 * 
	 */
	public function derivate(p:String):TermNode return TermDerivate.derivate(this, p);
	
	/*
	 * Simplify: trims the length of a math expression
	 * 
	 */
	public function simplify():TermNode return TermTransform.simplify(this);

	/*
	 * expands a mathmatical expression recursivly into a polynomial
	 * 
	 */
	public function expand():TermNode return TermTransform.expand(this);

	/*
	 * factorizes a mathmatical expression
	 *
	 */
	public function factorize():TermNode return TermTransform.factorize(this);
}
