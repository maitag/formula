package;

import TermNode;
/**
 * wrappers around TermNode
 * 
 * by Sylvio Sell, Rostock 2017
 */

class Term
{
	public var name:String;
	public var node:TermNode;
	public var bindings:Map<String, Term>;
	
	static var nameReg:EReg = ~/^([a-z]+):/i;

	public var result(get, null):Float;
	inline function get_result() return node.result;
	
	public function new(node:TermNode, ?name:String, ?bindings:Map<String, Term>)
	{
		this.node = node;
		this.name = name;
		if (bindings != null) bind(bindings);
	}

	public static inline function newValue(f:Float):Term {
		return new Term(TermNode.newValue(f));
	}
	
	public static inline function newParam(id:String, ?term:Term):Term {
		return new Term(TermNode.newParam(id, term.node));
	}
	
	public static inline function newOperation(s:String, ?left:Term, ?right:Term):Term {
		return new Term(TermNode.newOperation(s, left.node, (right != null) ? right.node : null));
	}
	
	public static inline function fromString(s:String):Term {
		var name:String = null;
		
		if (nameReg.match(s)) {
			name = nameReg.matched(1);
			s = s.substr(name.length+1);
		}
		return new Term(TermNode.fromString(s), name);
	}
	
	public inline function bind(bindings:Map<String, Term>):Void // <-- TODO: more easy api to use here
	{
		this.bindings = bindings;
		node.bind([for (k in bindings.keys()) k => bindings.get(k).node]);
	}
	
	public inline function simplify():Term
	{	
		node.simplify();
		return this;
	}
	
	public inline function derivate(p:String):Term
	{	
		return new Term(node.derivate(p), bindings);
	}
}

@:forward(name, result, bind)
abstract Formula(Term) from Term to Term
{	
	inline public function new(s:String) {
		this = Term.fromString(s);
	}
	
	public inline function simplify():Formula return this.simplify();
	public inline function derivate(p:String):Formula return this.derivate(p);
	
	inline public function toString(?depth:Null<Int>):String return this.node.toString(depth);
	
	@:to inline public function toStr():String return this.node.toString(0);
	@:to inline public function toFloat():Float   return this.node.result;
	
	@:from static public function fromString(a:String):Formula return Term.fromString(a);
	@:from static public function fromFloat(a:Float):Formula return Term.newValue(a);
	/*
	@:op(C + D) static public function addStringToFormula( a:String,  b:Formula ):String return a + b.toString();
	@:op(C + D) static public function addFormulaToString( a:Formula, b:String  ):String return a.toString() + b;
	*/
	static inline function twoSideOp(op:String, a:Formula, b:Formula ):Formula {
		return Term.newOperation(op,
			(a.name != null ) ? Term.newParam(a.name, a) : a ,
			(b.name != null ) ? Term.newParam(b.name, b) : b
		);
	}
	@:op(A + B) static public function add     (a:Formula, b:Formula):Formula return twoSideOp('+', a, b);
	@:op(A - B) static public function subtract(a:Formula, b:Formula):Formula return twoSideOp('-', a, b);
	@:op(A * B) static public function multiply(a:Formula, b:Formula):Formula return twoSideOp('*', a, b);
	@:op(A / B) static public function divide  (a:Formula, b:Formula):Formula return twoSideOp('/', a, b);
	@:op(A ^ B) static public function potenz  (a:Formula, b:Formula):Formula return twoSideOp('^', a, b);
	@:op(A % B) static public function modulo  (a:Formula, b:Formula):Formula return twoSideOp('%', a, b);

	public static inline function atan2(a:Formula, b:Formula):Formula return twoSideOp('atan2', a, b);
	public static inline function log  (a:Formula, b:Formula):Formula return twoSideOp('log',   a, b);
	public static inline function max  (a:Formula, b:Formula):Formula return twoSideOp('max',   a, b);
	public static inline function min  (a:Formula, b:Formula):Formula return twoSideOp('min',   a, b);

	static inline function oneParamOp(op:String, a:Formula):Formula {
		return Term.newOperation(op, (a.name != null ) ? Term.newParam(a.name, a) : a );
	}
	public static inline function abs (a:Formula):Formula return oneParamOp('abs', a);
	public static inline function ln  (a:Formula):Formula return oneParamOp('ln', a);
	public static inline function sin (a:Formula):Formula return oneParamOp('sin', a);
	public static inline function cos (a:Formula):Formula return oneParamOp('cos', a);
	public static inline function tan (a:Formula):Formula return oneParamOp('tan', a);
	public static inline function cot (a:Formula):Formula return oneParamOp('cot', a);
	public static inline function asin(a:Formula):Formula return oneParamOp('asin', a);
	public static inline function acos(a:Formula):Formula return oneParamOp('acos', a);
	public static inline function atan(a:Formula):Formula return oneParamOp('atan', a);
	
}
