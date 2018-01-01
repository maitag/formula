# Formula
handle mathematical expressions at [haxe](https://haxe.org)-runtime.  

This tool has its roots in [old C symbolic math stuff](https://github.com/maitag/lyapunov-c).  

It can form derivatives, simplify terms and  
handle parameters to connect Formulas together.  


## Installation
```
haxelib install Formula
```

or use the latest developement version from github:
```
haxelib git Formula https://github.com/maitag/formula.git
```

## Documentation
__Formula__ class is a [haxe-abstract](https://haxe.org/manual/types-abstract.html) to support operator-overloading for the underlaying __TermNode__ class,  
therefore prefer this one for instantiation:
```
var f:Formula;
```

Set up a math expression from String with new or by using the "="-operator:
```
f = new Formula("1+2*3");
f = "1+2*3";
f = 7;  // supports Float too
```


### Math expressions:

two side operators:  
`+`, `-`, `*`, `/`, `^`, `%`  

mathmatical functions:  
`log(a, b)`, `ln(a)`, `abs(a)`, `max(a,b)`, `min(a,b)`  
`sin(a)`, `cos(a)`, `tan(a)`, `cot(a)`, `asin(a)`, `acos(a)`, `atan(a)`, `atan2(a,b)`  

constants: `e()` and `pi()`  


### Naming formulas:

To be known to 'others', you can give a Formula object a name:
```
f.name = "f";
```

or alternatively name it at first position in the definition (separated by a colon):
```
f = "f: 1+2*3";
```


### Parameter binding:

Bind Formulas together by using custom literals (like variable names):
```
f = "sin(b)";  // other formula can be bound to 'b' later
```

Now define another Formula object `x` to connect to variable `b` with the 'bind()' method:
```
var x:Formula = 0;
f.bind( ["b" => x] ); 
```

Formula `x` does not necessarily has to have the same name as the variable inside `f`,  
but if Formula `x` has the same name, it's easier:
```
x.name = "b";
f.bind(x);
```

To bind more than one variable at once, proceed like this: `f.bind( ["b" => x, "c" => c] );`  


### Output formulas:

In a String context Formula will return the full dissolved mathmatical expression (includes all bindings):
```
trace(f); // sin(0)
```

To dissolve only to a certain level of subterms, use the `toString` method:
```
trace( f.toString(0) ); // sin(b)
trace( f.toString(1) ); // sin(0)
```

Or print out all binding levels in order with the `debug()` method:
```
f.name = "f";
f.debug(); // f = sin(b) -> sin(0)
```


### Calculating results:

The result of a formula expression can be calculated with the `result()` method.  
Use this if no unbound variables are left:
```
trace( f.result() ); // 0
```


### Unbinding of parameters:
```
f.unbind(x);
// or f.unbind("b");

// unbind more than one with array usage:
f.unbind( [x, y] );
// or f.unbind( ["b", "c"] );

// unbind all with:
f.unbindAll();
trace(f); // "sin(b)"
```


## Formula API
```
new(s:String, ?params:Dynamic)
	creates an Formula object based on the string s

name:String (get and set)
	Formula name
	
result:Float (get only)
	calculation result of the math expression
	
bind(params:Dynamic):Formula
	link a variable inside of this Formula to another Formula

unbind(params:Dynamic):Formula
	delete the connection between a variable and the linked Formula

unbindAll():Formula
	deletes the connection between all variables of the Formula and all linked Formulas
	
depth():Int
	returns the max depth of parameter bindings

params():Array<String>
	returns an array of parameter-names

set(a:Formula):Formula
	copy all from another Formula to this (keeps the own name if it is defined)

copy():Formula
	returns a copy of this Formula

toString(?depth:Null<Int>, ?plOut:String):String
	returns the mathmatical expression in form of a string
	parameters:
		depth: specifies how deep variables should be replaced by their corresponding Formulas
		plOut: to generate output syntax for different programming languages ( only 'glsl' yet )

debug()
	debugging output to see all bindings

derivate(p:String):Formula
	returns the derivate of this mathmatical expression

simplify():Formula
	tries various ways to make the term appear simpler
	and also normalizes it
	(use with caution because this process is not trivial and could be changed in later versions)

expand():Formula
	mathematically expands the term into a polynomial

factorize():Formula
	factorizes a mathmatical expression

toBytes():Bytes
	packs Formula into haxe.io.Bytes for more efficiently storage

Formula.fromBytes(b:Bytes):Formula
	static function to extract a Formula from haxe.io.Bytes
```


## Samples
```
var x:Formula, a:Formula, b:Formula, c:Formula, f:Formula;

x = 7.0;
a = "a: 1+2*3";  // a has a defined name

f = "2.5 * sin(x-a)^2";

// change name of Formula
x.name = "x";

// bind Formulas as parameters to other Formula
f.bind(["x" => x, "a" => a]);

trace( f.toString(0) ); // 2.5*(sin(x-a)^2)

// fast calculation at runtime
trace( f.result );      // 0

// derivation           // 2.5*(((2*(sin(x-a)^2))*cos(x-a))/sin(x-a))
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
trace( f.params() );  // [ "a", "x" ]

// debugging Formulas
f.debug();  // f = a+(x/5) -> (1-2)+((3*4)/5)

// simplify reduces operations
a.set(a.simplify());
trace( f );  // -1+((3*4)/5)

// using math functions
f = Formula.sin(c * a) + Formula.max(f, 3);
f.name = "F";
f.debug();  // F = sin(5*a)+max(f,3) -> sin(5*-1)+max((a+(x/5)),3) -> sin(5*-1)+max((-1+((3*4)/5)),3)

// error handling
c = "4";
f = "3 * c";
try f.bind(c) catch(msg:String) trace('Error: $msg'); // Error: Can't bind to unnamed parameter.

var s:String = "4 + (3 - )";
trace(s);
try {
	f = s;
} catch (error:Dynamic) {
	var spaces:String = "";
	for (i in 0...error.pos) spaces += " ";
	trace(spaces + "^");
	trace('Error: ${error.msg}'); // Error: Missing right operand.
}

```
More can be found in [formula-samples](https://github.com/maitag/formula-samples) repository.  


## Todo

- remove of unnecessary parentheses in string output
- cleaner algorithms for term-transformations
- more ways to customize the simplification of terms
- comparing terms for math-equality


### Possible tasks in future

- handling other datatypes for values (integer, fixed-point numbers, vectors, matrices, complex numbers)
- more math operations (hyperbolic functions, logic operators)
- handle recursive parameter bindings (something like x(n+1) = x(n) ...)
- definite integrals (or even indefinite later on)
- gpu-optimization for parallel calculations
