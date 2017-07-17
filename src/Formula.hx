package;

import TermNode;
/**
 * wrappers around TermNode
 * 
 * by Sylvio Sell, Rostock 2017
 */

private class Term
{
	public var name:String;
	
	public var node:TermNode;
	var bindings:Map<String, Term>;
	public var bindTo:Map<Term, String>;
	
	static var nameReg:EReg = ~/^([a-z]+):/i;

	public var result(get, null):Float;
	inline function get_result() return node.result;
	
	public function new(node:TermNode, ?name:String, ?bindings:Map<String, Term>)
	{
		this.node = node;
		this.name = name;
		this.bindings = new Map<String, Term>();
		this.bindTo = new Map<Term, String>();
		if (bindings != null) bind(bindings);
	}

	public function set(t:Term):Term
	{
		//if (t.name != null) name = t.name;
		node = t.node.copy();
		//if (t.bindings != null) bindings = [for (k in t.bindings.keys()) k => t.bindings.get(k)];
		for (t in bindTo.keys()) {
			t.bindings.set( bindTo.get(t), this);
			t.node.bind([for (k in t.bindings.keys()) k => t.bindings.get(k).node]);
		}
		t.unbindAll();
		return this;
	}

	public static inline function newValue(f:Float):Term {
		return new Term(TermNode.newValue(f));
	}
	
	public static inline function newParam(id:String, ?term:Term):Term {
		return new Term(TermNode.newParam(id, term.node));
	}
	
	public static inline function newOperation(s:String, ?left:Term, ?right:Term, ?params:Array<Term>):Term {
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
	
	public inline function bindToTerm(a:Term, ?b:Term):Term {
		if (a.name != null) bindParam(a.name, a) else bind(a.bindings);
		a.unbindAll();
		
		if (b != null) {
			if (b.name != null) bindParam(b.name, b)
			else bind(b.bindings);
			b.unbindAll();
		}
		return this;
	}
	
	public inline function bind(bindings:Map<String, Term>):Term // <-- TODO: more easy api to use here
	{
		for (name in bindings.keys()) bindParam( name, bindings.get(name) );
		return this;
	}

	inline function bindParam(name:String, param:Term):Void
	{
		param.bindTo.set(this, name);
		bindings.set(name, param);
		node.bind([name => param.node]);
	}
	
	public inline function unbind(params:Array<String>):Term // <-- TODO: more easy api to use here
	{	
		for (name in params) unbindParam(name);
		return this;
	}
	
	public inline function unbindAll():Term
	{	
		if (bindings != null) for (name in bindings.keys()) unbindParam(name);
		return this;
	}
	
	inline function unbindParam(name:String):Void
	{	
		bindings.get(name).bindTo.remove(this);
		bindings.remove(name);
		node.unbind([name]);
	}

	public inline function simplify():Term
	{	
		node.simplify();
		return this;
	}
	
	public inline function copy(?name:String):Term
	{	
		return new Term(node.copy(), (name != null) ? name : this.name,
			(name != null) ? [for (k in bindings.keys()) k => bindings.get(k)] : null
		);
	}
	
	public inline function derivate(p:String):Term
	{	
		return new Term(node.derivate(p), bindings);
	}
	
	public function debugBindings() {
		trace(name + ": " + node.toString(0));// + " -> " + node.toString());
		for (k in bindTo.keys()) trace("   " + bindTo.get(k) + " --> " + k.node.toString(0));
	}

}

@:forward( name, result )
abstract Formula(Term) from Term to Term
{	
	inline public function new(s:String) {
		this = Term.fromString(s);
	}
	
	public function debugBindings() this.debugBindings();
	
	public inline function set(a:Formula):Formula return this.set(a);

	public inline function bind(params:Dynamic):Formula {
		var ret:Map<String, Formula> = new Map();
		var arr:Array<Formula> = new Array();
		if( Std.is(params, Type.getClass(ret)) ) {
			ret = cast params;// cast(params, Map<String, Formula>);
		}
		else if ( Std.is(params, Type.getClass(arr)) ) {
			//ar arr:Array<Formula> = cast params;
			arr = cast params;
			for (p in arr) if (p.name == null) throw "Can't bind to unnamed parameters";
			ret = [ for (p in arr) p.name => p ];
		} else {
			throw "The value isn't an Array or Map";
		}
		return this.bind(ret);
	}
	public inline function unbind(_):Formula return this.unbind(_);
	public inline function unbindAll():Formula return this.unbindAll();
	
	public inline function copy():Formula return this.copy();
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
		).bindToTerm(a,b);
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
		return Term.newOperation(op, (a.name != null ) ? Term.newParam(a.name, a) : a ).bindToTerm(a);
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
