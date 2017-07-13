# formula
to play with mathematical formulas at haxe-runtime

This work is >in progress<  
to recode old [symbolic Math Stuff](https://github.com/maitag/lyapunov-c)  
in haxe language.  

### How to use
```
	var x: Formula;
	var a: Formula;
	var f: Formula;
	
	x = 7.0;
	a = "1 + 2 * 3";
	f = "2.5 * sin(x - a) ^ 2";
	f.bind(["x" => x, "a" => a]);
		
	trace( f , f.result );	//   2.5*(sin(x-a)^2)  ,  0
```

### Todo

- more useful unit tests
- full working derivatation (i feel bug ;)
- handle recursive parameter bindings (for something like x(n+1) = x(n) ...)
- more easy typing/constructing with Formular abstract
- comparing terms for equality (more algorithms for term transformations or for normalizations?)
- more ways to simplify formulas
