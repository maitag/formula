package;

import TermNode;
/**
 * wrappers around TermNode
 * 
 * by Sylvio Sell, Rostock 2017
 */

class TermRoot
{
	public var name:String;
	public var node:TermNode;
	public var bindings:Map<String, TermRoot>;
	
	static var paramReg:EReg = ~/^([a-z]+):/i;

	public var result(get, null):Float; // result of tree calculation
	inline function get_result() return node.result;
	
	public function new(formula:String)
	{
		if (paramReg.match(formula)) {
			name = paramReg.matched(1);
			formula = formula.substr(name.length+1);
		}
		
		node = TermNode.fromString(formula);
	}
	
	public function bind(bindings:Map<String, TermRoot>):Void // <-- TODO: more easy api to use here
	{
		this.bindings = bindings;
		node.bind([for (k in bindings.keys()) k => bindings.get(k).node]);
	}
	
}

@:forward(name, result, bind)
abstract Formula(TermRoot) from TermRoot to TermRoot
{	
	inline public function new(formula:String) {
		this = new TermRoot(formula);
	}

	@:to inline public function toString():String return this.node.toString(0);
	@:to inline public function toFloat():Float   return this.node.result;
	
	@:from static public function fromString(formula:String):Formula return new TermRoot(formula);
	@:from static public function fromFloat(a:Float):Formula return new Formula(Std.string(a));

	//@:op(A + B) static public function add( a:Formula, b:Formula ):Formula return new Formula( . . . );
}
