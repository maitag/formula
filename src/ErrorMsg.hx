package;

/**
 * collect all error messages
 * 
 * by Sylvio Sell, Rostock 2022
 */

class ErrorMsg
{
	static inline function error(msg:String, pos:Int = 0) {
		#if (haxe_ver >= "4.1.0")
			throw new FormulaException(msg, pos);
		#else
			throw({msg:msg, pos:pos});
		#end
	}
		
	
	// --------------- Formula ----------------
	
	public static inline function cantBindUnnamed(formula:Formula, bindFormula:Formula)
		error('Can\'t bind unnamed formula: \'${bindFormula.toString()}\'. Specify the available parameter: \'${formula.params().join("\' ,\'")}\' or name the formula to one.');
		
	public static inline function bindArrayWrongLengths(nf:Int, np:Int)
		error('The array-length of formulas ($nf) have to be the same as paramNames ($np) for bindArray().');

	
		
	// --------------- TermNode ---------------
	
	public static inline function noValidOperation(s:String)
		error('"$s" is no valid operation.');

	public static inline function wrongCharInsideName(name:String)
		error('Wrong character inside name "$name".');
	
	public static inline function emptyFunction(s:String)
		error('Empty function "$s".');
	
	public static inline function missingParameter(s:String)
		error('Missing parameter "$s".');
	
	
	// formula parsing
	public static inline function cantParseFromEmptyString(pos:Int)
		error("Can't parse Term from empty string.", pos);
	
	public static inline function operatorNeedTwoArgs(op:String, pos:Int)
		error('Operation "$op()" needs two arguments separated by comma.', pos);
	
	public static inline function missingLeftOperand(pos:Int)
		error("Missing left operand.", pos);
	
	public static inline function noOpeningBracket(pos:Int)
		error("No opening bracket.", pos);
	
	public static inline function wrongChar(pos:Int)
		error("Wrong char.", pos);
	
	public static inline function missingOperation(pos:Int)
		error("Missing operation.", pos);
	
	public static inline function missingRightOperand(pos:Int)
		error("Missing right operand.", pos);
	
	public static inline function emptyBrackets(pos:Int)
		error("Empty brackets.", pos);
	
	public static inline function wrongBracketNesting(pos:Int)
		error("Wrong bracket nesting.", pos);
		
	
	// by en/decoding to/from Bytes
	public static inline function intoBytes()
		error("Can't encode into Bytes.");
		
	public static inline function fromBytes()
		error("Can't decode from Bytes.");
	
		
			
	// --------------- TermDerivate ---------------
	
	public static inline function notImplementedFor(s:String)
		error('Derivation of "$s" is not implemented.');
	
	
}