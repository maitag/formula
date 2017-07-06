package;


class Utility{

	static public function isNumber(x:String):Bool{
		for(i in 0...x.length){
				if(!((x.charAt(i)>="0")&&(x.charAt(i)<="9"))){
					return(false);
				}
		}
		return(true);
	}


	static public function isOperator(x:String):Bool{
		if(x=="+"||x=="-"||x=="*"||x=="/"||x=="^"||x=="%"||x=="abs"||x=="ln"||x=="sin"||x=="cos"||x=="tan"||x=="asin"||x=="acos"||x=="atan"||x=="atan2"||x=="log"||x=="max"||x=="min"){
			return(true);
		}
		return(false);
	}

}

