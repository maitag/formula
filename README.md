# formula
to play with mathematical formulas at haxe-runtime

This work is >in progress<  
to recode old [symbolic Math Stuff](https://github.com/maitag/lyapunov-c)  
in haxe language.  

### How to use
```
	var x:Formula, a:Formula, b:Formula, c:Formula, f:Formula;

	x = 7.0;
	a = "a: 1+2*3";
	
	f = "2.5 * sin(x-a)^2";
	f.bind(["x" => x, "a" => a]);
		
	trace( f.toString(0) );	// 2.5*(sin(x-a)^2)
	trace( f.result );      // 0
	
	a = "a: 1-2";
	x = "x: 3*4";
	c = "c: 5";
	
	// operations with Formulas
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

- derivatation of atan2
- more useful unit tests
- more easy typing/constructing with Formula
- handle recursive parameter bindings (something like x(n+1) = x(n) ...)
- more ways to simplify and transform terms
- comparing terms for equality
