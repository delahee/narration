package n;

import n.Types;
using StringTools;

class Lex {

	static var SPECIAL_CHARS :String = "|[]{}<>*:";
	
	public static inline var DEBUG = true;
	
	public function new() {
		
	}
	
	public inline function isSpecialChar(cc:Int) : Bool {
		var r = false;
		for ( s in 0...strlen(SPECIAL_CHARS))
			if ( haxe.Utf8.charCodeAt(SPECIAL_CHARS,s) == cc ){
				r = true;
				break;
			}
		return r;
	}
	
	static inline function fromCharCode(code:Int):String{
		var utf = new haxe.Utf8();
		utf.addChar(code);
		return utf.toString();
	}
	
	public static inline function lexemToString(l:Lexem ) : String {
		return 
			switch(l) {
				case Char(c)			: fromCharCode(c);//use new utf8.add?
				case Pipe				: '|';
				case Literal(str)		: str;
				case AccOpen			: "}";
				case AccCondOpen		: "{?";
				case AccClose			: "}";
				case TagOpen(str)		: "<"+str+">";
				case TagClose(str)		: "</"+str+">";
				case TagSelfClosed(str)	: "<"+str+"/>";
				case BrackOpen			: "[";
				case BrackCondOpen		: "[?";
				case BrackClose			: "]";
				case Star				: "*";
				case DoubleStar			: "**";
				case DoubleSemiColon	: "::";
				
				case BrackPosOpen		: "[>";
			}
	}
	
	public static function utf8Append( inout:haxe.Utf8, str : String){
		haxe.Utf8.iter( str, function(code){
			inout.addChar(code);
		});
	}
	
	public static function lexemsToString(l:Array<Lexem> ) : String {
		var b = new haxe.Utf8();
		for ( p in l) {
			switch(p) {
				case Char(c)			: b.addChar(c);
				case Pipe				: b.addChar('|'.code);
				case Literal(str)		: utf8Append(b,str);
				case AccOpen			: b.addChar("}".code);
				case AccCondOpen		: utf8Append(b,"{?");
				case AccClose			: b.addChar("}".code);
				case TagOpen(_)			: utf8Append(b,lexemToString(p));
				case TagClose(_)		: utf8Append(b,lexemToString(p));
				case TagSelfClosed(_)	: utf8Append(b,lexemToString(p));
				case BrackOpen			: b.addChar("[".code);
				case BrackCondOpen		: utf8Append(b,"[?");
				case BrackClose			: b.addChar("]".code);
				case Star				: b.addChar("*".code);
				case DoubleStar			: b.addChar("*".code); b.addChar("*".code);
				case DoubleSemiColon	: b.addChar(":".code); b.addChar(":".code);
				case BrackPosOpen		: b.addChar("[".code); b.addChar(">".code);
			}
				
		}
		return b.toString();
	}
	
	public inline function isSentenceChar(cc:Int) : Bool {
		return !isSpecialChar(cc);
	}
	
	public inline function parse(str:String ) : List<Lexem> {
		var l = new List();
		_parse( str, 0, l);
		return l;
	}
	
	function charCodeAt(str:String, pos:Int):Int{
		return haxe.Utf8.charCodeAt(str, pos);
	}
	
	function charAt(str:String, pos:Int):String{
		return haxe.Utf8.sub(str, pos,1);
	}
	
	function strlen( str:String){
		return haxe.Utf8.length(str);
	}
	
	function sub( str:String,pos:Int,len:Int){
		return haxe.Utf8.sub(str,pos,len);
	}
	
	function _parse(str:String, pos:Int, result : List<Lexem>)  {
		
		#if !prod
		//if ( DEBUG ) trace( "cur res stack:" + result + " upon " + str + " pos:" + pos );
		#end
		
		var len = strlen(str);
		if ( pos >= len )
			return;
			
		switch( charAt(str,pos)) {

			case ':':
				var pp = pos + 1;
				if ( (pp < len) && ( charCodeAt(str,pp) == ':'.code) ){
					result.add( DoubleSemiColon );
					
					pp++;
					var opp = pp;
					while (pp < len&& charCodeAt(str,pp) != ':'.code && charCodeAt(str,pp+1) != ':'.code)
						pp++;
						
					var endpp = pp+1;
					var subLen = endpp - opp;
					var lit = haxe.Utf8.sub( str,opp, subLen);
					result.add(Literal(lit));
					result.add( DoubleSemiColon );
					_parse( str, pp+3, result);
				}
				else {
					result.add( Char(':'.code) );
					_parse( str, pos + 1, result);
				}
			case '\\': 
				if( (pos + 1 < len ) 
				&&	isSpecialChar( charCodeAt(str,pos + 1)) ) {
					result.add( Char( charCodeAt(str,pos + 1)) );
					_parse( str, pos + 2, result);
				}
				else {
					result.add( Char('\\'.code) );
					_parse( str, pos + 1, result);
				}
			case '|':
				var start = pos;
				var end = pos + 1;
				while ( end < len && charCodeAt(str,end) != '|'.code) {
					end++;
				}
				if ( end == len ) {
					result.add( Char('|'.code) );
				}
				else {
					var subLen = end - (start + 1);
					var sub = haxe.Utf8.sub( str, start + 1, subLen);
					result.add(Pipe);
					result.add(Literal(sub));
					result.add(Pipe);
					_parse( str, end + 1, result);
				}
			case '{':	
				var pp = pos+1;
				if ( (pos + 1 < len) 
				&& charCodeAt(str,pp) == '?'.code){
					result.add( AccCondOpen );
					pp++;
				}
				else 
					result.add( AccOpen );
				_parse( str, pp, result);
				
			case '[':	
				var pp = pos + 1;
				var len = strlen(str);
				
				if ( (pos + 1 < len) 
				&& charCodeAt(str,pp) == '>'.code)
				{
					result.add( BrackPosOpen );
					pp++;
				}
				else
				if ( (pos + 1 < len) 
				&& charCodeAt(str,pp) == '?'.code){
					result.add( BrackCondOpen );
					pp++;
				}
				else 
					result.add( BrackOpen );
				_parse( str, pp, result);
				
			case '<':	
				var pp = pos +1;
				if ( (pp < len) 
				&& charCodeAt(str,pp) == '/'.code){
					pp++;
					
					while ( pp< len && charCodeAt(str,pp) != '>'.code)
						pp++;
						
					if ( pp == len ) { //not found cancel
						result.add( Char('<'.code ));
						_parse( str, pos + 1, result);
						return;
					}
					else {
						var sublen = pp - (pos + 2);
						var lit = haxe.Utf8.sub(str,pos+2, sublen);
						result.add(TagClose(lit));
						_parse( str, pp + 1, result);
					}
				}
				else {
					while (pp < len && charCodeAt(str,pp) != '>'.code)
						pp++;
						
					if ( pp == len ) { //not found cancel
						result.add( Char('<'.code ) );
						_parse( str, pos + 1, result);
						return;
					} else {
						
						if ( charCodeAt(str, pp - 1) == '/'.code) {
							var subLen = (pp - 1) - (pos + 1);
							var lit = haxe.Utf8.sub(str,pos + 1, subLen);
							result.add(TagSelfClosed(lit));
							_parse( str, pp + 1, result);
						}
						else {
							var subLen = pp - (pos + 1);
							var lit = haxe.Utf8.sub(str,pos + 1, subLen);
							result.add(TagOpen(lit));
							_parse( str, pp + 1, result);
						}
					}
				}
				
			case '>':
				result.add( Char('>'.code) );
				
			default:
				var c = charAt(str,pos);
				if( isSentenceChar( charCodeAt(c,0))){
					result.add(Char(charCodeAt(str,pos)));
					_parse( str, pos + 1, result);
				}
				else {
					var pp = pos + 1;
				
					var code = charCodeAt(c,0);
					switch(code) {
						default: 
							throw "unsuported special "+code+" "+String.fromCharCode(code)+" reading from "+c;
						case '*'.code:
							if ( pp< len && charCodeAt(str,pp) == '*'.code){
								result.add( DoubleStar );
								pp++;
							}
							else 
								result.add( Star );
						//case '|'.code:	result.add( Pipe );
						//case '<'.code:	result.add( TagOpen );
						//case '>'.code:	result.add( TagClose );
						
						case '}'.code:	result.add( AccClose );
						case ']'.code:	result.add( BrackClose );
					}
					_parse( str, pp, result);
				}
			}
		
	}
	
}