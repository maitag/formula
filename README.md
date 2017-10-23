# Formula
handle mathematical expressions at [haxe-runtime](https://haxe.org).  

This tool has its roots in [old C symbolic math stuff](https://github.com/maitag/lyapunov-c)  

It can do simplification, forming derivative and  
handling parameters to connect Formulas together.  

### Installation
```
haxelib git Formula https://github.com/maitag/formula.git
```

### Documentation
```
	// Formula is an abstract class from TermNode for operator-overloading,
	// prefer this one

	// instantiation
	var f:Formula;
	
	// set a TermNode for your object by using the "="-operator
	// supported types are: String, Int
	f = 3.14;
	f = "(sqrt(5)-1)/2";
	
	// you can use variables inside of a Formula
	f = "sin(b)";
	// and also connect them to another Formula object later on
	var x:Formula;
	x = 0;
	// name of variable is neither the name of the Formula-object nor the name of the formula-object known by the other formula-objects
	// set the name the Formula object should be known to other Formula objects
	x.name = "x";
	// also possible in definition of x
	x = "x: 0";
	// it does not necessarily has to be the same name
	// bind the variable b of Formula f to formula x
	f.bind(["b" => x]); 
	// if you want to bind more than one variable proceed like this: f.bind(["b" => x, "c" => c])
	
	// result() will calculate everything, use this if no undefined variables are left in your term
	trace(f.result()); // 0
	
	// in String context now Formula will return the in x contained mathmatical expression
	trace(f); // "sin(0)"
	
	// unbind a parameter
	f.unbind(x);
	// or f.unbind("x"), and if you have more than one parameter you want to unbind f.unbind["x", "y") or f.unbindAll()
	trace(f); // "sin(b)"

	// supported operator for Formula definitions are -, +, *, /, ^, %
	// supported mathmatical functions are +, -, *, /, ^, %, log(a, b), ln(a), sin(a), cos(a), tan(a), e, pi, abs(a), cot(a), asin(a), acos(a), atan(a), atan2(a,b), max(a,b), min(a,b)
	// useful other functions:
	f.derivate(x)
	f.expandall();
	f.simplify();

```

	
### Formula API
```
	new(s:String, ?params:Dynamic)
		creates an Formula object based on the string s

	set(a:Formula)
		this Formula gets the same properties as a

	bind(params:Dynamic):Formula
		link a variable inside of this Formula to another Formula

	unbind(params:Dynamic)
		delete the connection between a variable and the linked Formula

	unbindAll()
		deletes the connection between all variables of the Formula and all linked Formulas
	
	copy()
		returns a copy of this Formula

	derivate(p:String)
		returns the derivate of this mathmatical expression

	toString(?depth:Null<Int>)
		returns the mathmatical expression in form of a string
		depth specifies how deep variables should be replaced by their corresponding Formulas
	
	simplify()
		tries with various ways to make the term appear simpler
		also normalizes it
		unstable, use with caution

	debug()
		some debugging output
	
	expandAll()
		expands the term

```


### Examples
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

- position of error while thrown string-parsing-error
- more useful unit tests
- more ways to simplify and transform terms
- comparing terms for equality
- remove unnecessary parentheses
- !-operator

### Possible tasks in future

- handling complex numbers
- other datatypes for values (integer, fixed-point numbers, vectors, matrices)
- handle recursive parameter bindings (something like x(n+1) = x(n) ...)
- definite integrals (or even indefinite later on)
- gpu-optimization for parallel calculations
