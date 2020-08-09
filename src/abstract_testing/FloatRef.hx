package;
import haxe.ds.Vector;

/**
 * ...
 * @author 
 */
abstract FloatRef(haxe.ds.Vector<Float>) {
  public var value(get, set):Float;
  
  inline function new() this = new haxe.ds.Vector(1);
  
  @:to inline function get_value():Float return this[0];
  inline function set_value(param:Float) return this[0] = param;
  
  public function toString():String return '@[' + Std.string(value)+']';
  
  @:noUsing @:from static inline public function to(v:Float):FloatRef {
    var f = new FloatRef();
    f.value = v;
    return f;
  }
}
/*
abstract TermParam(Vector<Float>) 
{
	public var allowed:Array<String>;
	public var term:MathTerm;
	
	public function new(t:MathTerm, s:Array<String>) {
		allowed = s;
		term = t;
		this = new Vector<Float>(s.length);
	}
	
	public function set(index:Int, value:MathTerm) {
		this.set(index, value);
		// calculate new Term Value
		term.calc();
	}
	
}
*/