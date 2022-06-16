package;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;

/**
 * symbolic derivation
 * by Sylvio Sell, Rostock 2017
 * 
 **/

class TermDerivate {

	static var newOperation:String->?TermNode->?TermNode->TermNode = TermNode.newOperation;
	static var newValue:Float->TermNode = TermNode.newValue;

	/*
	 * creates a new term that is derivate of a given term 
	 * 
	 */
	static public inline function derivate(t:TermNode, p:String):TermNode {	
		return switch (t.symbol) 
		{
			case s if (t.isName): TermNode.newName( t.symbol, derivate(t.left, p) );
			case s if (t.isValue || TermNode.constantOpRegFull.match(s)): newValue(0);
			case s if (t.isParam): (t.symbol == p) ? newValue(1) : newValue(0);
			case '+' | '-':
				newOperation(t.symbol, derivate(t.left, p), derivate(t.right, p));
			case '*':
				newOperation('+',
					newOperation('*', derivate(t.left, p), t.right.copy()),
					newOperation('*', t.left.copy(), derivate(t.right, p))
				);
			case '/':
				newOperation('/',
					newOperation('-',
						newOperation('*', derivate(t.left, p), t.right.copy()),
						newOperation('*', t.left.copy(), derivate(t.right, p))
					),
					newOperation('^', t.right.copy(), newValue(2) )
				);
			case '^':
				if (t.left.symbol == 'e')
					newOperation('*', derivate(t.right, p),
						newOperation('^', newOperation('e'), t.left.copy())
					);
				else
					newOperation('*', 
						newOperation('^', t.left.copy(), t.right.copy()),
						newOperation('*',
							t.right.copy(),
							newOperation('ln', t.left.copy())
						).derivate(p)
					);
			case 'sin':
				newOperation('*', derivate(t.left, p),
					newOperation('cos', t.left.copy())
				);
			case 'cos':
				newOperation('*', derivate(t.left, p),
					newOperation('-', newValue(0),
						newOperation('sin', t.left.copy() )
					)
				);
			case 'tan':
				newOperation('*', derivate(t.left, p),
					newOperation('+', newValue(1),
						newOperation('^',
							newOperation('tan', t.left.copy() ),
							newValue(2)
						)
					)
				);
			case 'cot':
				newOperation('/',
					newValue(1),
					newOperation('tan', t.left.copy())
				).derivate(p);				
			case 'atan':
				newOperation('*', derivate(t.left, p),
					newOperation('/', newValue(1),
						newOperation('+', newValue(1),
							newOperation('^', t.left.copy(), newValue(2))
						)
					)
				);
			case 'atan2':
				newOperation('/', 
					newOperation('-',
						newOperation('*', t.right.copy(), derivate(t.left, p)),
						newOperation('*', t.left.copy(), derivate(t.right, p))
					),
					newOperation('+',
						newOperation('*', t.left.copy(), t.left.copy()),
						newOperation('*', t.right.copy(), t.right.copy())
					)
				);
			case 'asin':
				newOperation('*', derivate(t.left, p),
					newOperation('/', newValue(1),
						newOperation('^',
							newOperation('-', newValue(1),
								newOperation('^', t.left.copy(), newValue(2))
							), newOperation('/', newValue(1), newValue(2))
						)
					)
				);
			case 'acos':
				newOperation('*', derivate(t.left, p),
					newOperation('-', newValue(0),
						newOperation('/', newValue(1),
							newOperation('^',
								newOperation('-', newValue(1),
									newOperation('^', t.left.copy(), newValue(2))
								), newOperation('/', newValue(1), newValue(2))
							)
						)
					)
				);
			case 'log':
				newOperation('/',
					newOperation('ln', t.right.copy()),
					newOperation('ln', t.left.copy())
				).derivate(p);
			case 'ln':
				newOperation('*', derivate(t.left, p),
					newOperation('/', newValue(1), t.left.copy())
				);
			case 'abs':
				newOperation('*', derivate(t.left, p),
					newOperation('/', t.left.copy(), newOperation('abs', t.left.copy()) )
				);
				
			default: ErrorMsg.notImplementedFor(t.symbol); null;
		}

	}
	
	

}
