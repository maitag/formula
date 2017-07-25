package;

/**
 * abstract wrapper around TermNode
 * 
 * by Sylvio Sell, Rostock 2017
 */


@:forward( name, result, bind, debug )
abstract Formula(TermNode) from TermNode to TermNode
{	
	inline public function new(s:String, ?bindings:Map<String, TermNode>) {
		this = TermNode.fromString(s, bindings);
	}
	
	//public function debugBindings() this.debugBindings();
	
	public inline function set(a:Formula):Formula return this = a.copy(); // TODO: do not destroy the node-Reference!

	public inline function bind(params:Dynamic):Formula {
		var map:Map<String, Formula> = new Map();
		var arr:Array<Formula> = new Array();
		
		if( Std.is(params, Type.getClass(map)) ) {
			map = cast params;
		}
		else if ( Std.is(params, Type.getClass(arr)) ) {
			arr = cast params;
			for (p in arr) if (p.name == null) throw "Can't bind to unnamed parameters";
			map = [ for (p in arr) p.name => p ];
		} 
		else if ( Std.is(params, TermNode) || Std.is(params, Formula) ) {
			var val:Formula = cast params;
			if (val.name == null) throw "Can't bind to unnamed parameter";
			map = [ val.name => val ];
		} 
		else {
			throw "The value isn't an Formula, Array or Map";
		}
		return this.bind(map);
	}
	
	public inline function unbind(params:Dynamic):Formula {
		var arr:Array<String> = new Array();
		
		if( Std.is(params, Type.getClass(arr)) ) {
			arr = cast params;
		}
		else if ( Std.is(params, String)) {
			var val:String = cast params;
			arr = [ val ];
		} 
		else {
			throw "The value isn't an String or Array<String>";
		}
		return this.unbind(arr);
	}
	//public inline function unbindAll():Formula return this.unbindAll();
	
	public inline function copy():Formula return this.copy();
	public inline function simplify():Formula return this.simplify();
	public inline function derivate(p:String):Formula return this.derivate(p);
	
	inline public function toString(?depth:Null<Int>):String return this.toString(depth);
	
	@:to inline public function toStr():String return this.toString(0);
	@:to inline public function toFloat():Float return this.result;
	
	@:from static public function fromString(a:String):Formula return TermNode.fromString(a);
	@:from static public function fromFloat(a:Float):Formula return TermNode.newValue(a);

	static inline function twoSideOp(op:String, a:Formula, b:Formula ):Formula {
		return TermNode.newOperation( op,
			(a.name != null ) ? TermNode.newParam(a.name, a) : a,
			(b.name != null ) ? TermNode.newParam(b.name, b) : b 
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
		return TermNode.newOperation( op,
			(a.name != null ) ? TermNode.newParam(a.name, a) : a
		);
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
