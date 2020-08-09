package;
import haxe.ds.Vector;

/**
 * ...
 * @author 
 */
/*abstract TermParam(haxe.ds.Vector<Float>)
{
	inline function new() this = new haxe.ds.Vector(2);

	public var value(get, set):Float;
	@:to inline function get_value():Float return this[0];
	inline function set_value(f:Float) return this[0] = f;

	public var name(get, set):String;
	inline function get_name():String {
		return String.fromCharCode(Math.floor(this[1]));
	}
	inline function set_name(s:String) {
		this[1] = s.charCodeAt(0);
		return String.fromCharCode(Math.floor(this[1]));
	}

	public function toString():String return '@[' + Std.string(value)+']';

	@:noUsing @:from static inline public function to(v:Float):TermParam {
		var ret = new TermParam();
		ret.value = v; trace("TO");
		return ret;
	}
	
	@:op(A + B) static function add( a:TermParam, b:TermParam ):TermParam {
		
	}
}*/
class TParam {
	public var value:Float;
	public function new(v:Float) value = v;
}
abstract TermParam(TParam)
{
	public var value(get, set):Float;
	inline function get_value():Float return this.value;
	inline function set_value(a:Float) return this.value = a;
	
	inline public function new(a:Float)	this = new TParam(a);
	inline public function get():Float return this.value;
	
	@:to inline public function toString():String return Std.string(this.value);
	@:to inline public function toFloat():Float   return this.value;
	
	@:from static public function fromString(a:String):TermParam return new TermParam(Std.parseFloat(a));
	@:from static public function fromFloat(a:Float):TermParam return new TermParam(a);
		
	@:op(A + B) static public function add( a:TermParam, b:TermParam ):TermParam return new TermParam(a.get()+b.get());
	@:op(A - B) static public function sub( a:TermParam, b:TermParam ):TermParam return new TermParam(a.get()-b.get());
	@:op(A * B) static public function mul( a:TermParam, b:TermParam ):TermParam return new TermParam(a.get()*b.get());
	@:op(A / B) static public function div( a:TermParam, b:TermParam ):TermParam return new TermParam(a.get()/b.get());
	
}
