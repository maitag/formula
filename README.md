# formula
to play with mathematical formulas at [haxe-runtime](https://haxe.org).  

This tool has arisen from [old C symbolic math stuff](https://github.com/maitag/lyapunov-c)  
to handle math expressions at runtime.  

It can do simplification, forming derivative and  
handling parameters to connect formulas together.  


### How to use
```
	var x:Formula, a:Formula, b:Formula, c:Formula, f:Formula;

	x = 7.0;
	a = "a: 1+2*3";  // a has a defined name
	
	f = "2.5 * sin(x-a)^2";

	// change name of Formula
	x.name = "x";

	// bind Formulas as parameter to other Formula
	f.bind(["x" => x, "a" => a]);
	
	trace( f.toString(0) );	// 2.5*(sin(x-a)^2)
	
	// fast calculation at runtime
	trace( f.result );      // 0
	
	// derivation           // 2.5*((sin(x-a)^2)*(2*(cos(x-a)/sin(x-a))))
	trace( f.derivate("x").simplify().toString(0) );
	
	// change value (keeps parameter bindings)
	x.set("atan(a)");
	x.bind(a);              // a has a defined name to bind to

	trace( f.toString(0) ); // 2.5*(sin(x-a)^2)
	trace( f.toString(1) ); // 2.5*(sin(atan(a)-(1+(2*3)))^2)
	trace( f.toString(2) ); // 2.5*(sin(atan((1+(2*3)))-(1+(2*3)))^2)
	
	// unbind parameter
	x.unbind("a");
	f.unbind(["a", "x"]); // unbind accepts array of param-names
	f.unbind(a);          // unbind accepts Formula
	f.unbind([x => "x", a => "x"]);  // unbind accepts Map<Formula,String>
	f.unbind([a , x]);    // unbind accepts array of Formulas
	f.unbindAll();        // or unbind all params
	
	trace( f );  // 2.5*(sin(x-a)^2)
	
	// operations with Formulas
	a = "a: 1-2"; 
	x = "x = 3*4";
	c = 5;
	
	f = a + x / c;
	f.name = "f";
	
	// show parameters
	// c has no name, so operation will not generate param for f
	trace( f.params() ); // [ "a", "x" ]
		
	// debugging Formulas
	f.debug(); // f = a+(x/5) -> (1-2)+((3*4)/5)
	
	// simplify reduce operations with values
	a.simplify();
	trace( f );             // -1+((3*4)/5)
	
	// using math functions
	f = Formula.sin(c * a) + Formula.max(f, 3);
	f.name = "F";
	f.debug(); // F = sin(5*a)+max(f,3) -> sin(5*-1)+max((a+(x/5)),3) -> sin(5*-1)+max((-1+((3*4)/5)),3)
```

### Todo

- api documentation
- position of error while thrown string-parsing-error
- more useful unit tests
- more ways to simplify and transform terms
- comparing terms for equality


### Possible tasks in future

- handling complex numbers
- other datatypes for values (integer, fixed-point numbers, vectors, matrices)
- handle recursive parameter bindings (something like x(n+1) = x(n) ...)
- integrally math
- gpu-optimization for parallel calculations
