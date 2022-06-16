# Formula
handle mathematical expressions at [haxe](https://haxe.org)-runtime.  

This tool has its roots in [old C symbolic math stuff](https://github.com/maitag/lyapunov-c).  

It can form derivatives, simplify terms and  
handle parameters to connect Formulas together.  


## Installation
```
haxelib install formula
```

or use the latest developement version from github:
```
haxelib git formula https://github.com/maitag/formula.git
```


## Testing

To perform benchmarks or unit-tests call the `text.hx` [hxp](https://lib.haxe.org/p/hxp) script. 
  
install [hxp](https://lib.haxe.org/p/hxp) via:
```
haxelib install hxp
haxelib run hxp --install-hxp-alias
```

then simple call `hpx help` into projectfolder to see options.
  
If you use `hxp bench` to compare performance versus hscripts math-expression parsing  
you need to install [hscript](https://lib.haxe.org/p/hscript) from haxelib first!


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
f.bind( x, "b" );
```

Formula `x` does not necessarily has to have the same name as the variable inside `f`,  
but if Formula `x` has the same name, it's easier:
```
x.name = "b";
f.bind(x);
```

To bind more than one variable at once you can proceed like this: `f.bindMap( ["b" => x, "c" => c] );`  
Alternatively use arrays of formulas and to what parameters it should bind: `f.bindArray( [x, c], ["b", "c"] );`
or if all formulas have the same names as expected: `f.bindArray( [x, c] );`

### Unbinding of parameters:
```
// unbind a connected formula
f.unbind(x);

// unbind the formula thats connected to a variable name
f.unbindParam("b");

// unbind more than one formula with array usage:
f.unbindArray( [x, c] );
f.unbindParamArray( ["b", "c"] );

// unbind all with:
f.unbindAll();
trace(f); // "sin(b)"
```


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

The result of a formula expression can be calculated with the `result` getter method.  
Use this if no unbound variables are left:
```
trace( f.result ); // 0
```


## Formula API
```
new(formula:String)
	creates an Formula object based on the string formula

name:String (get and set)
	Formula name
	
result:Float (get only)
	calculation result of the math expression
	
bind(formula:Formula, ?paramName:String):Formula
	link a variable inside of this Formula to another Formula

bindArray(formulas:Array<Formula>, ?paramNames:Array<String>):Formula
	link variables inside of this Formula to another Formulas

bindMap(formulaMap:Map<String, Formula>):Formula
	link variables inside of this Formula to another Formulas
	where the mapkey is equal to the name of the variable

unbind(formula:Formula):Formula
	delete all connections of the linked Formula

unbindArray(formulas:Array<Formula>):Formula
	delete all connections of the linked Formulas

unbindParam(paramName:String):Formula
	delete all connections to linked formulas for a given variable name

unbindParamArray(paramNames:Array<String>):Formula
	delete all connections to linked formulas for the given variable names

unbindAll():Formula
	deletes the connection between all variables of the Formula and all linked Formulas

resolveAll(?depth:Int):Formula
	resolves all bindings into formula or optional to a specified the depth level,
	removes parameters and replaces it with copies of the linked formulas

hasBinding(formula:Formula):Bool
	returns true if this contains a binding to formula

hasParam(paramName:String):Bool
	returns true if formula contains a param with specified name

params():Array<String>
	returns an array of parameter-names

depth():Int
	returns the max depth of parameter bindings

set(a:Formula):Formula
	copy all from another Formula to this (keeps it's own name if defined)

copy(?depth:Int):Formula
	returns a full copy of this Formula or optional to a specified depth level

toString(?depth:Null<Int>, ?plOut:String):String
	returns the mathmatical expression in form of a string
	parameters:
		depth: specifies how deep variables should be replaced by their corresponding Formulas
		plOut: to generate output syntax for different programming languages ( only 'glsl' yet )

debug()
	debugging output to see all bindings

derivate(paramName:String):Formula
	returns new formula that is derivate to the variable paramName

simplify():Formula
	tries various ways to make the term appear simpler and also normalizes it
	(use with caution because this process is not trivial and could be changed in later versions)
	returns the result as new formula

expand():Formula
	mathematically expands into a polynomial and returns it as new formula

factorize():Formula
	factorizes and returns it as new formula

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
f.bindMap(["x" => x, "a" => a]);

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
f.unbind(a);                    // unbind a Formula
f.unbindParam("x");             // unbind by param-name
// or alternatively: 
//f.unbindArray([a , x]);         // unbind array of Formulas
//f.unbindParamArray(["a", "x"]); // unbind array of param-names
//f.unbindAll();                  // or unbind all params

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
try f.bind(c) catch(e:FormulaException) trace(e.msg); // Error: Can't bind to unnamed parameter...

var s:String = "4 + (3 - )";
try {
	f = s;
} catch (e:FormulaException) {
	trace(e.msg); // Error: Missing right operand.
	var spaces = ""; for (i in 0...e.pos) spaces += " ";
	trace(s);
	trace(spaces + "^");
}

```
More can be found in [formula-samples](https://github.com/maitag/formula-samples) repository.  


## Todo

- remove of unnecessary parentheses in string output
- option for parsing in/out to reduce notation of number-params multiplication like: "2x + 3y"
- cleaner algorithms for term-transformations
- more ways to customize the simplification of terms
- comparing terms for math-equality


### Possible tasks in future

- handling other datatypes for values (integer, fixed-point numbers, vectors, matrices, complex numbers)
- more math operations (hyperbolic functions, logic operators)
- handle recursive parameter bindings (something like x(n+1) = x(n) ...)
- definite integrals (or even indefinite later on)
- gpu-optimization for parallel calculations
