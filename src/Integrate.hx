package;

/**
 * solving one-dimensional, definite integrals RAM-efficiently using the trapezoidal rule
 * by samusake
 * 
 **/


class Integrate {

	static public inline function trapz(f:Formula, int_var:String, lower_bound:Float, higher_bound:Float, int_points:Int):Float {
		var x:Formula, int:Float, x_low:Float, dx:Float, helper:Float;
		x_low = lower_bound;
		x=1.0;//x_low;
		x.name = int_var;
		f.bind(x);
		int = 0;
		dx = (higher_bound - lower_bound) / int_points;

		for (i in 0...int_points) {
			helper = f.result;
			x_low += dx;
			x.set(x_low);
			int += (helper + f.result) / 2.0 * dx;
		}

		return(int);
	}







}
