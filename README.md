# formula
to play with mathematical formulas at haxe-runtime

This work is >in progress<  
to recode old [symbolic Math Stuff](https://github.com/maitag/lyapunov-c)  
in haxe language.  

### How to use
```
	var x:Formula, a:Formula, b:Formula, c:Formula, f:Formula;

	x = 7.0;
	a = "a: 1+2*3";  // a has a defined name
	
	f = "2.5 * sin(x-a)^2";
	
	// bind Formulas as parameter to other Formula
	f.bind(["x" => x, "a" => a]);
	
	trace( f.toString(0) );	// 2.5*(sin(x-a)^2)
	
	// fast calculation at runtime
	trace( f.result );      // 0
	
	// derivation           // 2.5*((sin(x-a)^2)*(2*(cos(x-a)*(1/sin(x-a)))))
	trace( f.derivate("x").simplify().toString(0) );
	
	// change value (keeps parameter bindings)
	x.set("atan(a)");
	x.bind(a);              // a has a defined name
	trace( f.toString(0) ); // 2.5*(sin(x-a)^2)
	trace( f.toString(1) ); // 2.5*(sin(atan(a)-(1+(2*3)))^2)
	
	// unbind parameter
	x.unbind("a");
	f.unbind(["a","x"]) // unbind accepts array
	f.unbindAll();      // or unbind all params
	
	trace( f );
	
	// operations with Formulas
	a = "a: 1-2";
	x = "x: 3*4";
	c = "c: 5";
	
	f = a + x / c;
	
	trace( f.toString(0) ); // a+(x/c)
	trace( f );             // (1-2)+((3*4)/5)
	trace( f.result );      // 1.4
	
	a.simplify();
	trace( f );             // -1+((3*4)/5)
	trace( f.result );      // 1.4
	
	f = Formula.sin(c * a) + Formula.max(f, 3);
	
	trace( f.toString(0) ); // sin(c*a)+max(a+(x/c),3)
	trace( f );             // sin(5*-1)+max(-1+((3*4)/5),3)
```

### Todo

- api documentation
- more useful unit tests
- handle recursive parameter bindings (something like x(n+1) = x(n) ...)
- more ways to simplify and transform terms
- comparing terms for equality
