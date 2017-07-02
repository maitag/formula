package;
import Term;
/**
 * puts Math Formular into a Tree Structure of Terms
 * to calculate at runtime
 * 
 * by Sylvio Sell 2017
 */

typedef F = Formula; // shortkey

abstract Formula(Term)
{	
	inline public function new(t:String) {
		this = new Term();
		// TODO
	}
	//@:from static public function fromString(a:String):Formula return new Formula(a);
}