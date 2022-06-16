package;
import haxe.Exception;

/**
 * collect all error messages
 * 
 * by Sylvio Sell, Rostock 2022
 */


class ErrorMsg 
{

	static inline function msg(s) {
		#if (haxe_ver >= "4.1.0")
			throw new Exception("Error: " + s);
		#else
			throw(s);
		#end
	}
	
	
	
	// ----- Formula ------
	public static inline function cantBindUnnamed(formula:Formula, bindFormula:Formula)
		msg('Can\'t bind unnamed formula: \'${bindFormula.toString()}\'. Specify the available parameter: \'${formula.params().join("\' ,\'")}\' or name the formula to one.');
		
	public static inline function bindArrayWrongLengths(nf:Int, np:Int)
		msg('The array-length of formulas ($nf) have to be the same as paramNames ($np) for bindArray().');

	
	
	
	// ----- TermNode -----
	public static inline function noValidOperation(s:String)
		msg('"$s" is no valid operation.');

		
	// TODO:	
	
	//('Not allowed characters for name $name".');
	
	//('Empty function "${t.symbol}".');
	
	//('Missing parameter "${t.symbol}".');
	
	
	
	//({"msg":"Can't parse Term from empty string.","pos":errPos});
	
	//({"msg":"Can't parse Term from empty string.","pos":errPos})
	
	//({"msg":f+"() needs two parameter separated by comma.","pos":errPos});
	
	//({"msg":"Missing left operand.","pos":errPos});
	
	//({"msg":"No opening bracket.","pos":errPos});
	
	//({"msg":"Wrong char.","pos":errPos});
	
	//({"msg":"Missing operation.","pos":errPos});
	
	//({"msg":"Missing right operand.","pos":errPos-spaces});
	
	//({"msg":"Empty brackets.", "pos":errPos});
	
	//({"msg":"Wrong bracket nesting.","pos":errPos});
	
	//({"msg":"No opening bracket.", "pos":errPos});
	
	//({"msg":"Wrong char.","pos":errPos});
	
	
	
	// internal errors by en/decoding to/from Bytes
	
	//("Error in _toBytes");
	//("Error in _fromBytes");
	
	
	
	
	
	// ----- TermDerivate -----
	
	//('derivation of "${t.symbol}" not implemented');	
}