package n;

class Builder {
	
	static function fromCharCode(charcode:Int):String{
		var utf =  new haxe.Utf8();
		utf.addChar(charcode);
		return utf.toString();
	}
	
	public static function make(str:String) :n.Types.Ast{
		var inspect = false;
		#if debug
		//if ( str.indexOf("stupides ou bien") >= 0 ){
			//trace("B:"+str);
			//haxe.Utf8.iter( str, function(code){
				//trace( code+" " + fromCharCode(code));
			//});
			//inspect = true;
		//}
		#end
		
		var l = new Lex();
		var lexs = l.parse( str );
		var g = new n.Gram();
		var t = g.parse(Lambda.array(lexs));
		#if debug
		//if ( inspect )
			//trace(t);
		#end
		return t;
	}
}