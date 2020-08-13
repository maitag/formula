package;
import haxe.io.Bytes;

/**
 * abstract wrapper around TermNode
 * 
 * by Sylvio Sell, Rostock 2017
 */


@:forward( name, result, depth, params, hasParam, hasBinding, resolveAll, unbindAll, toBytes, debug, copy, derivate, simplify, expand, factorize)
abstract Formula(TermNode) from TermNode to TermNode
{	
    /**
        Creates a new formula from a String, e.g. new("1+2") or new("f: 1+2") where "f" is the name of formula

        @param  formulaString the String that representing the math expression
    **/
	inline public function new(formulaString:String) {
		this = TermNode.fromString(formulaString);
	}
	
    /**
        Copy all from another Formula to this (keeps the own name if it is defined)
		Keeps the bindings where this formula is linked into by a parameter.

        @param  formula the source formula from where the value is copyed
    **/
	public inline function set(formula:Formula):Formula return this.set(formula);

    /**
        Link a variable inside of this formula to another formula

        @param  formula formula that will be linked into
        @param  paramName (optional) name of the variable to link with (e.g. if formula have no or different name) 
    **/
	public function bind(formula:Formula, ?paramName:String):Formula {
		if (paramName != null) {
			TermNode.checkValidName(paramName);
			return this.bind( [paramName => formula] );
		}
		else {
			if (formula.name == null) throw 'Can\'t bind unnamed formula:"${formula.toString()}" as parameter.';
			return this.bind( [formula.name => formula] );
		}
	}
	
    /**
        Link variables inside of this formula to another formulas

        @param  formulas array of formulas to link to variables
        @param  paramNames (optional) names of the variables to link with (e.g. if formulas have no or different names) 
    **/
	public function bindArray(formulas:Array<Formula>, ?paramNames:Array<String>):Formula {
		var map = new Map<String, Formula>();
		if (paramNames != null) {
			if (paramNames.length != formulas.length) throw 'paramNames need to have the same length as formulas for bindArray().';
			for (i in 0...formulas.length) {
				TermNode.checkValidName(paramNames[i]);
				map.set(paramNames[i], formulas[i]);
			}
		}
		else {
			for (formula in formulas) {
				if (formula.name == null) throw 'Can\'t bind unnamed formula:"${formula.toString()}" as parameter.';
				map.set(formula.name, formula);
			} 
		}
		return this.bind(map);			
	}
	
    /**
        Link variables inside of this formula to another formulas

        @param  formulaMap map of formulas where the keys have same names as the variables to link with
    **/
	public inline function bindMap(formulaMap:Map<String, Formula>):Formula {
		return this.bind(formulaMap);
	}
	
	// ------------ unbind -------------
	
    /**
        Delete all connections of the linked formula

        @param  formula formula that has to be unlinked
    **/
	public inline function unbind(formula:Formula):Formula {
		return this.unbindTerm( [formula] );
	}
	
    /**
        Delete all connections of the linked formulas

        @param  formulas array of formulas that has to be unlinked
    **/
	public function unbindArray(formulas:Array<Formula>):Formula {
		return this.unbindTerm(formulas);
	}

    /**
        Delete all connections to linked formulas for a given variable name

        @param  paramName name of the variable where the connected formula has to unlink from
    **/
	public inline function unbindParam(paramName:String):Formula {
		TermNode.checkValidName(paramName);
		return this.unbind( [paramName] );
	}
	
    /**
        Delete all connections to linked formulas for the given variable names

        @param  paramNames array of variablenames where the connected formula has to unlink from
    **/
	public inline function unbindParamArray(paramNames:Array<String>):Formula {
		return this.unbind(paramNames);
	}

	// -----------------------------------

    /**
        Creates a new formula from a String, e.g. new("1+2") or new("f: 1+2") where "f" is the name of formula

        @param  depth (optional) how deep the variable-bindings should be resolved
        @param  plOut (optional) creates formula for a special language (only "glsl" at now)
    **/
	inline public function toString(?depth:Null<Int> = null, ?plOut:String = null):String return this.toString(depth, plOut);

    /**
        Creates a formula from a packet Bytes representation
    **/
	inline public static function fromBytes(b:Bytes):Formula return TermNode.fromBytes(b);
	
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
