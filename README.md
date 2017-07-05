# formula
to play with mathematical formulas at haxe-runtime

This work is >in progress<  
to recode old [symbolic Math Stuff](https://github.com/maitag/lyapunov-c)  
in haxe language.  

###how to build up new math term
```
	var left:Term  = new Term();
	left.setOpValue(2);    trace(left.result); // -> 2

	var right:Term = new Term();
	right.setOpValue(3);   trace(right.result); // -> 3

	var f:Term = new Term();
	f.setOp("+", left , right); trace(f.result); // 2+3 -> 5
	trace("f="+f.toString());
	
	f.setOp("*", left ,right);  trace(f.result); // 2*3 -> 6
	trace("f="+f.toString());
	
	try	f.setOp("§", left , right) catch (msg:String) trace('Error: $msg'); // Error 20 (todo;)
	
	var x:Term = new Term();
	x.setOpValue(4);   trace(x.result); // -> 4
	
	var g:Term = new Term();
	g.setOp("+", x, f); trace(g.result); // 4+2*3 -> 10
	
	x.setOpValue(5);    trace(g.result); // 5+2*3 -> 11
	left.setOpValue(3); trace(g.result); // 5+3*3 -> 14
	trace("g=" + g.toString());

```




Sure, i did this to learn more haxe kung fu ~  

Please commit ideas here  
for what little tool this lib  
could be useful :)=

