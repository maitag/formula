package;

/**
 * extending TermNode with various math operations transformation and more.
 * by Sylvio Sell, Rostock 2017
 * 
 **/

class TermTransform {

	static var newOperation:String->?TermNode->?TermNode->TermNode = TermNode.newOperation;
	static var newValue:Float->TermNode = TermNode.newValue;
	
	/*
	 * Simplify: trims the length of a math expression
	 * 
	 */
	static public inline function simplify(t:TermNode):TermNode {
		t.set(expand(t));
		var len:Int = -1;
		var len_old:Int = 0;
		while (len != len_old) {
			if (t.isName && t.left != null) {
				simplifyStep(t.left);
			}
			else {
				simplifyStep(t);
			}
			len_old = len;
			len = t.length();
		}
		return t;
	}
	
	// TODO: take care, simplify changes both TermNodes on call !!!
	// TODO: removing this ugly function and using "isEqual()" rather then !!!
	static function isEqualAfterSimplify(t1:TermNode, t2:TermNode):Bool {
		// old method: if (this.simplify().toString() == t.simplify().toString()) return true else return false;
		return t1.simplify().isEqual(t2.simplify(), false, true);
	}
	
	static function simplifyStep(t:TermNode):Void {	
		if (!t.isOperation) return;
		
		if (t.left != null) {
			if (t.left.isValue) {
				if (t.right == null) {
					// setValue(result); // calculate operation with one value
					return;
				}
				else if (t.right.isValue) {
					t.setValue(t.result); // calculate operation with values on both sides
					return;
				}
			}
		}

		switch(t.symbol) {
			case '+':
				if (t.left.isValue && t.left.value == 0) t.copyNodeFrom(t.right);       // 0+a -> a
				else if (t.right.isValue && t.right.value == 0) t.copyNodeFrom(t.left); // a+0 -> a
				else if (t.left.symbol == 'ln' && t.right.symbol == 'ln') {         // ln(a)+ln(b) -> ln(a*b)
					t.setOperation('ln',
						newOperation('*', t.left.left.copy(), t.right.left.copy())
					);
				}                                         
				else if (t.left.symbol == '/' && t.right.symbol == '/' && isEqualAfterSimplify(t.left.right, t.right.right)) {
					t.setOperation('/',                                           // a/b+c/b -> (a+c)/b
						newOperation('+', t.left.left.copy(), t.right.left.copy()),
						t.left.right.copy()
					);
				}
				else if (t.left.symbol == '/' && t.right.symbol == '/') {            // a/b+c/d -> (a*d+c*b)/(b*d)
					t.setOperation('/',
						newOperation('+',
							newOperation('*', t.left.left.copy(), t.right.right.copy()),
							newOperation('*', t.right.left.copy(), t.left.right.copy())
						),
						newOperation('*', t.left.right.copy(), t.right.right.copy())
					);
				}
				arrangeAddition(t);
				if(t.symbol == '+') {
					factorize(t);
				}

			case '-':
				if (t.right.isValue && t.right.value == 0) t.copyNodeFrom(t.left);  // a-0 -> a
				else if (t.left.symbol == 'ln' && t.right.symbol == 'ln') {     // ln(a)-ln(b) -> ln(a/b)
					t.setOperation('ln',
						newOperation('/', t.left.left.copy(), t.right.left.copy())
					);
				}
				else if (t.left.symbol == '/' && t.right.symbol == '/' && isEqualAfterSimplify(t.left.right, t.right.right)) {
					t.setOperation('/',                                        // a/b-c/b -> (a-c)/b
						newOperation('-', t.left.left.copy(), t.right.left.copy()),
						t.left.right.copy()
					);
				}
				else if (t.left.symbol == '/' && t.right.symbol == '/') {        //a/b-c/d -> (a*d-c*b)/(b*d)
					t.setOperation('/', 
						newOperation('-',
							newOperation('*', t.left.left.copy(), t.right.right.copy()),
							newOperation('*', t.right.left.copy(), t.left.right.copy())
						),
						newOperation('*', t.left.right.copy(), t.right.right.copy())
					);
				}
				arrangeAddition(t);
				if(t.symbol == '-') {
					factorize(t);
				}

			case '*':
				if (t.left.isValue) {
					if (t.left.value == 1) t.copyNodeFrom(t.right); // 1*a -> a
					else if (t.left.value == 0) t.setValue(0);    // 0*a -> 0
				}
				else if (t.right.isValue) {
					if (t.right.value == 1) t.copyNodeFrom(t.left); // a*1 -> a
					else if (t.right.value == 0) t.setValue(0);   // a*0 -> a
				}
				else if (t.left.symbol == '/') {                // (a/b)*c -> (a*c)/b
					t.setOperation('/',
						newOperation('*', t.right.copy(), t.left.left.copy()),
						t.left.right.copy()
					);
				}
				else if (t.right.symbol == '/') {               // a*(b/c) -> (a*b)/c
					t.setOperation('/',
						newOperation('*', t.left.copy(), t.right.left.copy()),
						t.right.right.copy()
					);
				}
				else {
					arrangeMultiplication(t);
				}

		case '/':
				if (isEqualAfterSimplify(t.left, t.right)) { // x/x -> 1
					t.setValue(1);
				}
				else {
					if (t.left.isValue && t.left.value == 0) t.setValue(0);  // 0/a -> 0
					else if (t.right.symbol == '/') {
						t.setOperation('/',
							newOperation('*', t.right.right.copy(), t.left.copy()),
							t.right.left.copy()
						);
					} 
					else if (t.right.isValue && t.right.value == 1) t.copyNodeFrom(t.left); // a/1 -> a
					else if (t.left.symbol == '/') {                     // (1/x)/b -> 1/(x*b)
						t.setOperation('/', t.left.left.copy(),
							newOperation('*', t.left.right.copy(), t.right.copy())
						);
					}
					else if (t.right.symbol == '/') {                    // b/(1/x) -> b*x
						t.setOperation('/',
							newOperation('*', t.right.right.copy(), t.left.copy()),
							t.right.left.copy()
						);
					}
					else if (t.left.symbol == '-' && t.left.left.isValue && t.left.left.value == 0)
					{
						t.setOperation('-', newValue(0),
							newOperation('/', t.left.right.copy(), t.right.copy())
						);
					}
					else{ // a*b/b -> a
						simplifyfraction(t);
					}
				}

			case '^':
				if (t.left.isValue) {
					if (t.left.value == 1) t.setValue(1);         // 1^a -> 1
					else if (t.left.value == 0) t.setValue(0);    // 0^a -> 0
				} else if (t.right.isValue) {
					if (t.right.value == 1) t.copyNodeFrom(t.left); // a^1 -> a 
					else if (t.right.value == 0) t.setValue(1);   // a^0 -> 1
				}
				else if (t.left.symbol == '^') {                // (a^b)^c -> a^(b*c)
					t.setOperation('^', t.left.left.copy(),
						newOperation('*', t.left.right.copy(), t.right.copy())
					);
				}

			case 'ln':
				if (t.left.symbol == 'e') t.setValue(1);
			case 'log':
				if (isEqualAfterSimplify(t.left, t.right)) {
					t.setValue(1);
				}
				else {
					t.setOperation('/',                         // log(a,b) -> ln(b)/ln(a)
						newOperation('ln', t.right.copy()),
						newOperation('ln', t.left.copy())
					);
				}
		}
		if (t.left != null) simplifyStep(t.left);
		if (t.right != null) simplifyStep(t.right);
	}
		
	/*
	 * put all subterms separated by * into an array
	 * 
	 */
	static function traverseMultiplication(t:TermNode, p:Array<TermNode>)
	{
		if (t.symbol != "*") {
			p.push(t);
		}
		else {
			traverseMultiplication(t.left, p);
			traverseMultiplication(t.right, p);
		}
	}
	
	/*
	 * build tree consisting of multiple * from array
	 * 
	 */
	static function traverseMultiplicationBack(t:TermNode, p:Array<TermNode>)
	{
		if (p.length > 2) {
			t.setOperation('*', newValue(1), p.pop());
			traverseMultiplicationBack(t.left, p);
		}
		else if (p.length == 2) {
			t.setOperation('*', p[0].copy(), p[1].copy());
			p.pop();
			p.pop();
		}
		else {
			t.set(p.pop());
		}
	}

	/*
	 * put all subterms separated by * into an array
	 *
	 */
	static function traverseAddition(t:TermNode, p:Array<TermNode>, ?negative:Bool=false)
	{
		if (t.symbol == "+" && negative == false) {
			traverseAddition(t.left, p);
			traverseAddition(t.right, p);
		}
		else if (t.symbol == "-" && negative == false) {
			traverseAddition(t.left, p);
			traverseAddition(t.right, p, true);
		}
		else if (t.symbol == "+" && negative == true) {
			traverseAddition(t.left, p, true);
			traverseAddition(t.right, p, true);
		}
		else if (t.symbol == "-" && negative == true) {
			traverseAddition(t.left, p, true);
			traverseAddition(t.right, p);
		}
		else if (negative == true && !t.isValue || negative == true && t.isValue && t.value != 0) {
			p.push(newOperation('-', newValue(0), t));
		}
		else if (!t.isValue || t.isValue && t.value != 0) {
			p.push(t);
		}
		return(p);
	}

	/*
	 * build tree consisting of multiple - and + from array
	 *
	 */
	static function traverseAdditionBack(t:TermNode, p:Array<TermNode>)
	{
		if(p.length > 1) {
			if (p[p.length-1].symbol == "-") {
				t.set(p.pop());
			}
			else {
				t.setOperation("+", newValue(0), p.pop());
			}	
			traverseAdditionBack(t.left, p);
		}
		else if(p.length == 1){
			t.set(p.pop());
		}
	}

	/*
	 * reduce a fraction 
	 * 
	 */
	static public function simplifyfraction(t:TermNode)
	{
		var numerator:Array<TermNode> = new Array();
		traverseMultiplication(t.left, numerator);
		var denominator:Array<TermNode> = new Array();
		traverseMultiplication(t.right, denominator);
		for (n in numerator) {
			for (d in denominator) {
				if (isEqualAfterSimplify(n, d)) {
					numerator.remove(n);
					denominator.remove(d);
				}
			}
		}
		if (numerator.length > 1) {
			traverseMultiplicationBack(t.left, numerator);
		}
		else if (numerator.length == 1) {
			t.setOperation('/', numerator.pop(), newValue(1));
		}
		else if (numerator.length == 0) {
			t.left.setValue(1);
		}
		if (denominator.length > 1) {
			traverseMultiplicationBack(t.right, denominator);
		}
		else if (denominator.length == 1) {
			t.setOperation('/', t.left.copy(), denominator.pop());
		}
		else if (denominator.length == 0) {
			t.right.setValue(1);
		}
	}
	
	/*
	 * expands a mathmatical expression recursivly into a polynomial
	 *
	 */
	static public function expand(t2:TermNode):TermNode {
		var t:TermNode=new TermNode();
		t.set(t2.copy());
		var len:Int = -1;
		var len_old:Int = 0;
		while(len != len_old) {
			if (t.symbol == '*') {
				expandStep(t);
			}
			else {
				if(t.left != null) {
					t.left.set(expand(t.left));
				}
				if(t.right != null) {
					t.right.set(expand(t.right));
			
				}
			}
			len_old = len;
			len = t.length();
		}
		return t;
	}

	/*
	 * expands a mathmatical expression into a polynomial -> use only if top symbol=*
	 * 
	 */
	static function expandStep(t:TermNode)
	{
		var left:TermNode = t.left;
		var right:TermNode = t.right;

		if (left.symbol == "+" || left.symbol == "-") {
			if (right.symbol == "+" || right.symbol == "-") {
				if (left.symbol == "+" && right.symbol == "+") { //(a+b)*(c+d)
					t.setOperation('+',
						newOperation('+',
							newOperation('*', left.left.copy(), right.left.copy()),
							newOperation('*', left.left.copy(), right.right.copy())
						),
						newOperation('+',
							newOperation('*', left.right.copy(), right.left.copy()),
							newOperation('*', left.right.copy(), right.right.copy())
						)
					);
				}	
				else if (left.symbol == "+" && right.symbol == "-") { //(a+b)*(c-d)
					t.setOperation('+',
						newOperation('-',
							newOperation('*', left.left.copy(), right.left.copy()),
							newOperation('*', left.left.copy(), right.right.copy())
						),
						newOperation('-',
							newOperation('*', left.right.copy(), right.left.copy()),
							newOperation('*', left.right.copy(), right.right.copy())
						)
					);
				}
				else if (left.symbol == "-" && right.symbol == "+") { //(a-b)*(c+d)
					t.setOperation('-',
						newOperation('+',
							newOperation('*', left.left.copy(), right.left.copy()),
							newOperation('*', left.left.copy(), right.right.copy())
						),
						newOperation('+',
							newOperation('*', left.right.copy(), right.left.copy()),
							newOperation('*', left.right.copy(), right.right.copy())
						)
					);
				}
				else if (left.symbol == "-" && right.symbol == "-") { //(a-b)*(c-d)
					t.setOperation('-',
						newOperation('-',
							newOperation('*', left.left.copy(), right.left.copy()),
							newOperation('*', left.left.copy(), right.right.copy())
						),
						newOperation('-',
							newOperation('*', left.right.copy(), right.left.copy()),
							newOperation('*', left.right.copy(), right.right.copy())
						)
					);	
				}
			}
			else
			{
				if (left.symbol == "+") { //(a+b)*c
					t.setOperation('+',
						newOperation('*', left.left.copy(), right.copy()),
						newOperation('*', left.right.copy(), right.copy())
					);
				}
				else if (left.symbol == "-") { //(a-b)*c
					t.setOperation('-',
						newOperation('*', left.left.copy(), right.copy()),
						newOperation('*', left.right.copy(), right.copy())
					);
				}
			}
		}
		else if (right.symbol == "+" || right.symbol == "-") {
			if (right.symbol == "+") { //a*(b+c)
				t.setOperation('+',
					newOperation('*', left.copy(), right.left.copy()),
					newOperation('*', left.copy(), right.right.copy())
				);
			}
			else if (right.symbol == "-") { //a*(b-c)
				t.setOperation('-',
					newOperation('*', left.copy(), right.left.copy()),
					newOperation('*', left.copy(), right.right.copy())
				);
			}
		}
	}

	/*
	 * factorize a term -> a*c+a*b=a*(c+b)
	 *
	 */
	static public function factorize(t:TermNode) {
	  	var mult_matrix:Array<Array<TermNode>> = new Array();
	 	var add:Array<TermNode> = new Array();
		
		//build matrix - addition in columns - multiplication in rows 
		traverseAddition(t, add);
		var add_length_old:Int = 0;
		for(i in add) {
			if(i.symbol == "-") {
				mult_matrix.push(new Array());
				traverseMultiplication(add[mult_matrix.length-1].right, mult_matrix[mult_matrix.length-1]);
			}
			else {
				mult_matrix.push(new Array());
				traverseMultiplication(add[mult_matrix.length-1], mult_matrix[mult_matrix.length-1]);
			}
		}
		
		//find and extract common factors
		var part_of_all:Array<TermNode> = new Array();
		factorize_extract_common(mult_matrix, part_of_all);
		if(part_of_all.length != 0) {
			var new_add:Array<TermNode> = new Array();
			var helper:TermNode = TermNode.fromString("42");
			for(i in mult_matrix) {
				traverseMultiplicationBack(helper, i);
				var v:TermNode = TermNode.fromString("42");
				v.set(helper);
				new_add.push(v);
			}
			for(i in 0...add.length) {
				if(add[i].symbol == '-' && add[i].left.value == 0) {
					new_add[i].setOperation('-', newValue(0), new_add[i].copy());
				}
			}

			t.setOperation('*', newValue(42), newValue(42));
			traverseMultiplicationBack(t.left, part_of_all);
			traverseAdditionBack(t.right, new_add);
		}
	}
	
	//delete common factors of mult_matrix and add them to part_of_all	
	static function factorize_extract_common(mult_matrix:Array<Array<TermNode>>, part_of_all:Array<TermNode>) {
		var bool:Bool = false;
		var matrix_length_old:Int = -1;
		var i:TermNode=TermNode.fromString("42");
		var exponentiation_counter:Int = 0;
		while(matrix_length_old != mult_matrix[0].length) {
			matrix_length_old = mult_matrix[0].length;
			for(p in mult_matrix[0]) {
				if(p.symbol == '^') {
					i.set(p.left);
					exponentiation_counter++;
				}
				else if(p.symbol == '-' && p.left.isValue && p.left.value == 0) {
					i.set(p.right);
				}
				else {
					i.set(p);
				}
				for(j in 1...mult_matrix.length) {
					bool = false;
					for(h in mult_matrix[j]) {
						if(isEqualAfterSimplify(h, i)) {
							bool = true;
							break;
						}
						else if(h.symbol == '^' && isEqualAfterSimplify(h.left , i)) {
							bool=true;
							exponentiation_counter++;
							break;
		
						}
						else if(h.symbol == '-' && h.left.isValue && h.left.value == 0 && isEqualAfterSimplify(h.right, i)) {
							bool=true;
							break;		
						}
					}
					if(bool == false) {
						break;
					}
				}
				if(bool == true && exponentiation_counter < mult_matrix.length) {
					part_of_all.push(newValue(42));
					part_of_all[part_of_all.length-1].set(i);
					var helper:TermNode = TermNode.fromString("42");
					helper.set(i);
					delete_last_from_matrix(mult_matrix, helper);
					break;
				}
			}
		}
	}
	
	//deletes d from every row in mult_matrix once
	static function delete_last_from_matrix(mult_matrix:Array<Array<TermNode>>, d:TermNode) {
		for(i in mult_matrix) {
			if(i.length>1) {
				for(j in 1...i.length+1) {
					if(isEqualAfterSimplify(i[i.length-j], d)) { //a*x -> a
						for(h in 0...j-1) {
							i[i.length-j+h].set(i[i.length-j+h+1]);
						}
						i.pop();
						break;
					}
					else if(i[i.length-j].symbol == '^' && isEqualAfterSimplify(i[i.length-j].left, d)) { //x^n -> x^(n-1)
						i[i.length-j].right.set(newOperation('-', i[i.length-j].right.copy(), newValue(1)));
						break;
					}
					else if(i[i.length-j].symbol == '-' && i[i.length-j].left.isValue && i[i.length-j].left.value == 0 && isEqualAfterSimplify(i[i.length-j].right, d)) {
					       i[i.length-j].right.set(newValue(1));
				       		break;
					}		
				}
			}
			else if(i[0].symbol == '^' && isEqualAfterSimplify(i[0].left, d)) { //x^n -> x^(n-1)
				i[0].right.set(newOperation('-', i[0].right.copy(), newValue(1)));
			}
			else {
				i[0].set(newValue(1));
			}
		}
	}
	
	//compare function for Array.sort()
	static function formsort_compare(t1:TermNode, t2:TermNode):Int
	{	
		if (formsort_priority(t1) > formsort_priority(t2)) {
			return -1;
		}
		else if (formsort_priority(t1) < formsort_priority(t2)) {
			return 1;
		}
		else{
			if (t1.isValue && t2.isValue) {
				if (t1.value >= t2.value) {
					return(-1);
				}
				else{
					return(1);
				}
			}
			else if (t1.isOperation && t2.isOperation) {
				if(t1.right != null && t2.right != null) {
					return(formsort_compare(t1.right, t2.right));
				}
				else {
					return(formsort_compare(t1.left, t2.left));
				}
			}
			else return 0;
		}
	}

	// priority function for formsort_compare()
	static function formsort_priority(t:TermNode):Float
	{	
		return switch(t.symbol)
		{
			case s if (t.isParam): t.symbol.charCodeAt(0);
			case s if (t.isName):  t.symbol.charCodeAt(0);
			case s if (t.isValue): 1+0.00001*t.value;
			case s if (TermNode.twoSideOpRegFull.match(s)) : 
				if(t.symbol == '-' && t.left.value == 0) {
					formsort_priority(t.right);
				}
				else {													 
					formsort_priority(t.left)+formsort_priority(t.right)*0.001;
				}
			case s if (TermNode.oneParamOpRegFull.match(s)): -5 - TermNode.oneParamOp.indexOf(s);
			case s if (TermNode.twoParamOpRegFull.match(s)): -5 - TermNode.oneParamOp.length - TermNode.twoParamOp.indexOf(s);
			case s if (TermNode.constantOpRegFull.match(s)): -5 - TermNode.oneParamOp.length - TermNode.twoParamOp.length - TermNode.constantOp.indexOf(s);
			
			default: -5 - TermNode.oneParamOp.length - TermNode.twoParamOp.length - TermNode.constantOp.length;
		}
	}

	/*
	 * sort a Tree consisting of products
	 * 
	 */
	static public function arrangeMultiplication(t:TermNode)
	{
		var mult:Array<TermNode> = new Array();
		traverseMultiplication(t, mult);
		mult.sort(formsort_compare);
		traverseMultiplicationBack(t, mult);
	}

	/*
	 * sort a Tree consisting of addition and subtraction
	 *
	 */
	static public function arrangeAddition(t:TermNode)
	{
		var addlength_old:Int = -1;
		var add:Array<TermNode> = new Array();
		traverseAddition(t, add);
		add.sort(formsort_compare);
		while(add.length != addlength_old) {
			addlength_old = add.length;
			for(i in 0...add.length-1) {
				if(isEqualAfterSimplify(add[i], add[i+1])) {
					add[i].setOperation('*', add[i].copy(), newValue(2));
					for(j in 1...add.length-i-1) {
						add[i+j] = add[i+j+1];
					}
					add.pop();
					break;
				}
				if(add[i].symbol == '*' && add[i+1].symbol == '*' && add[i].right.isValue && add[i+1].right.isValue && isEqualAfterSimplify(add[i].left, add[i+1].left)) {
					add[i].right.setValue(add[i].right.value+add[i+1].right.value);
					for(j in 1...add.length-i-1) {
						add[i+j] = add[i+j+1];
					}
					add.pop();
					break;
				}
				if(add[i].isValue && add[i+1].isValue) {
					add[i].setValue(add[i].value+add[i+1].value);
					for(j in 1...add.length-i-1) {
						add[i+j] = add[i+j+1];
					}
					add.pop();
					break;
				}
				if((add[i].symbol == '-' && add[i].left.isValue && add[i].left.value == 0 && isEqualAfterSimplify(add[i].right, add[i+1])) || (add[i+1].symbol == '-' && add[i+1].left.isValue && add[i+1].left.value == 0 && isEqualAfterSimplify(add[i+1].right, add[i]))) {
					for(j in 0...add.length-i-2) {
						add[i+j] = add[i+j+2];
					}
					add.pop();
					add.pop();
					if(add.length == 0){
						add.push(newValue(0));
					}
					break;
				}
			}

			if(add[0].symbol == '-' && add[0].left.value == 0) {
				for(i in add) {
					if(i.symbol == '-' && i.left.value == 0) {
						i.set(i.right);
					}
					else {
						i.setOperation('-', newValue(0), i.copy());
					}
				}
				t.setOperation('-', newValue(0), newValue(42));
				traverseAdditionBack(t.right, add);
				return;
			}
				
		}

		traverseAdditionBack(t, add);
	}
		
	
		
}
