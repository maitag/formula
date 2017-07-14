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

	public var result(get, null):Float; // result of tree calculation
	inline function get_result() return node.result;
	
	public function new(node:TermNode, ?name:String)
	{
		this.node = node;
		this.name = name;
	}

	public static inline function newValue(f:Float):Term {
		return new Term(TermNode.newValue(f));
	}
	
	public static inline function newParam(id:String, ?term:Term):Term {
		return new Term(TermNode.newParam(id, term.node));
	}
	
	public static inline function newOperation(s:String, ?left:Term, ?right:Term):Term {
		return new Term(TermNode.newOperation(s, left.node, right.node));
	}
	
	public static inline function fromString(s:String):Term {
		var name:String = null;
		
		if (nameReg.match(s)) {
			name = nameReg.matched(1);
			s = s.substr(name.length+1);
		}
		return new Term(TermNode.fromString(s), name);
	}
	
	public function bind(bindings:Map<String, Term>):Void // <-- TODO: more easy api to use here
	{
		this.bindings = bindings;
		node.bind([for (k in bindings.keys()) k => bindings.get(k).node]);
	}
	
}

@:forward(name, result, bind)
abstract Formula(Term) from Term to Term
{	
	inline public function new(formula:String) {
		this = Term.fromString(formula);
	}

	@:to inline public function toString():String return this.node.toString(0);
	@:to inline public function toFloat():Float   return this.node.result;
	
	@:from static public function fromString(a:String):Formula return Term.fromString(a); // TODO: try to keep old instanze( name etc)
	
	@:from static public function fromFloat(a:Float):Formula return Term.newValue(a);
	
	@:op(A + B) static public function add     ( a:Formula, b:Formula ):Formula return Term.newOperation('+', a, b);
	@:op(A - B) static public function subtract( a:Formula, b:Formula ):Formula return Term.newOperation('-', a, b);
	@:op(A * B) static public function multiply( a:Formula, b:Formula ):Formula return Term.newOperation('*', a, b);
	@:op(A / B) static public function divide  ( a:Formula, b:Formula ):Formula return Term.newOperation('/', a, b);
	@:op(A % B) static public function modulo  ( a:Formula, b:Formula ):Formula return Term.newOperation('%', a, b);

}
