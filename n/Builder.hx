package n;

class Builder {
	
	public static function make(str:String) :n.Types.Ast{
		
		#if debug
		trace(str);
		#end
		
		var l = new Lex();
		var lexs = l.parse( str );
		var g = new n.Gram();
		var t = g.parse(Lambda.array(lexs));
		return t;
	}
}