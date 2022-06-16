package;

/**
 * expetions for try/catch errorhandling
 * 
 * by Sylvio Sell, Rostock 2022
 */

#if (haxe_ver >= "4.1.0")

class FormulaException extends haxe.Exception
{
	public function new(msg:String, pos:Int) {
		super(msg);
		this.pos = pos;
	}
	
	public var msg(get, never):String;
	inline function get_msg() return message;
	
	public var pos:Int;
}

#else

typedef FormulaException = Dynamic;

#end