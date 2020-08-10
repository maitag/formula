import haxe.Timer;

class FormulaVersusHscript {

    public static function main() 
	{		
		// random formula to check math-expression performance
		var formula = "10.5/x+((127/x-2)*(384/3+x))/(5*x+1.6)/42*1/(x-1)/(21*x-101)*0.01";

		// --- hscript ---
 		var e = "
		  var x = 3.14;
		  for (i in 0...1000000) x = " + formula + ";
		  x;
		";
		var time = haxe.Timer.stamp();
		var result = new hscript.Interp().execute(new hscript.Parser().parseString( e ));
		haxe.Log.trace('Hscript:\t' + Std.int((Timer.stamp() - time)*1000) + "\tms \tresult: " + Std.string( result ), #if (haxe_ver >= "4.0.0") null #else {fileName:"",lineNumber:0,className:"",methodName:"",customParams:[]} #end);
 
		// --- formula ---
		var x:Formula = "x: 3.14";
		var f:Formula = formula;
		f.bind(x);
		var time = haxe.Timer.stamp();
		for (i in 0...1000000) x.set(f.result);
		haxe.Log.trace('Formula:\t' + Std.int((Timer.stamp() - time)*1000) + "\tms \tresult: " + x.result , #if (haxe_ver >= "4.0.0") null #else {fileName:"",lineNumber:0,className:"",methodName:"",customParams:[]} #end);
	}
	
}