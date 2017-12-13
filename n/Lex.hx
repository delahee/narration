package n;

import n.Types;
using StringTools;

class Lex {

	static var SPECIAL_CHARS :String = "|[]{}<>*:";
	
	public function new() {
		
	}
	
	public inline function isSpecialChar(cc:Int) : Bool {
		var r = false;
		for ( s in 0...SPECIAL_CHARS.length)
			if ( SPECIAL_CHARS.fastCodeAt(s) == cc ){
				r = true;
				break;
			}
		return r;
	}
	
	
	public static inline function lexemToString(l:Lexem ) : String {
		return 
			switch(l) {
				case Char(c)			: String.fromCharCode(c);
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
	
	public static inline function lexemsToString(l:List<Lexem> ) : String {
		var b = new StringBuf();
		for ( p in l) {
			switch(p) {
				case Char(c)			: b.addChar(c);
				case Pipe				: b.addChar('|'.code);
				case Literal(str)		: b.add(str);
				case AccOpen			: b.addChar("}".code);
				case AccCondOpen		: b.add("{?");
				case AccClose			: b.addChar("}".code);
				case TagOpen(_)			: b.add(lexemToString(p));
				case TagClose(_)		: b.add(lexemToString(p));
				case TagSelfClosed(_)	: b.add(lexemToString(p));
				case BrackOpen			: b.addChar("[".code);
				case BrackCondOpen		: b.add("[?");
				case BrackClose			: b.addChar("]".code);
				case Star				: b.addChar("*".code);
				case DoubleStar			: b.addChar("*".code);b.addChar("*".code);
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
	
	function _parse(str:String, pos:Int, result: List<Lexem>)  {
		if ( pos >= str.length )
			return;
			
		switch(str.charAt(pos)) {

			case ':':
				var pp = pos + 1;
				if ( (pp<str.length) && (str.charCodeAt(pp) == ':'.code) ){
					result.add( DoubleSemiColon );
					
					pp++;
					var opp = pp;
					while (pp<str.length&&str.charCodeAt(pp) != ':'.code&&str.charCodeAt(pp+1) != ':'.code)
						pp++;
						
					var endpp = pp+1;
					var lit = str.substring(opp, endpp);
					result.add(Literal(lit));
					result.add( DoubleSemiColon );
					_parse( str, pp+3, result);
				}
				else {
					result.add( Char(':'.code) );
					_parse( str, pos + 1, result);
				}
			case '\\': 
				if( (pos + 1 < str.length) 
				&&	isSpecialChar(str.charCodeAt(pos + 1))) {
					result.add( Char(str.charCodeAt(pos + 1)) );
					_parse( str, pos + 2, result);
				}
				else {
					result.add( Char('\\'.code) );
					_parse( str, pos + 1, result);
				}
			case '|':
				var start = pos;
				var end = pos + 1;
				while ( end < str.length && str.charCodeAt(end) != '|'.code) {
					end++;
				}
				if ( end == str.length ) {
					result.add( Char('|'.code) );
				}
				else {
					var sub = str.substring( start + 1, end);
					result.add(Pipe);
					result.add(Literal(sub));
					result.add(Pipe);
					_parse( str, end + 1, result);
				}
			case '{':	
				var pp = pos+1;
				if ( (pos + 1 < str.length) 
				&& str.charCodeAt(pp) == '?'.code){
					result.add( AccCondOpen );
					pp++;
				}
				else 
					result.add( AccOpen );
				_parse( str, pp, result);
				
			case '[':	
				var pp = pos + 1;
				
				if ( (pos + 1 < str.length) 
				&& str.charCodeAt(pp) == '>'.code)
				{
					result.add( BrackPosOpen );
					pp++;
				}
				else
				if ( (pos + 1 < str.length) 
				&& str.charCodeAt(pp) == '?'.code){
					result.add( BrackCondOpen );
					pp++;
				}
				else 
					result.add( BrackOpen );
				_parse( str, pp, result);
				
			case '<':	
				var pp = pos +1;
				if ( (pp < str.length) 
				&& str.charCodeAt(pp) == '/'.code){
					pp++;
					
					while (pp<str.length&&str.charCodeAt(pp) != '>'.code)
						pp++;
						
					if ( pp == str.length) { //not found cancel
						result.add( Char('<'.code ));
						_parse( str, pos + 1, result);
						return;
					}
					else {
						var lit = str.substring(pos+2, pp);
						result.add(TagClose(lit));
						_parse( str, pp + 1, result);
					}
				}
				else {
					while (pp<str.length&&str.charCodeAt(pp) != '>'.code)
						pp++;
						
					if ( pp == str.length) { //not found cancel
						result.add( Char('<'.code ) );
						_parse( str, pos + 1, result);
						return;
					} else {
						
						if ( str.charCodeAt(pp - 1) == '/'.code) {
							var lit = str.substring(pos + 1, pp-1);
							result.add(TagSelfClosed(lit));
							_parse( str, pp + 1, result);
						}
						else {
							var lit = str.substring(pos + 1, pp);
							result.add(TagOpen(lit));
							_parse( str, pp + 1, result);
						}
					}
				}
				
			case '>':
				result.add( Char('>'.code) );
				
			default:
				var c = str.charAt(pos);
				if( isSentenceChar(c.fastCodeAt(0))){
					result.add(Char(str.charCodeAt(pos)));
					_parse( str, pos + 1, result);
				}
				else {
				var pp = pos + 1;
				switch(c.fastCodeAt(0)) {
					default: throw "unsuported special";
					case '*'.code:
						if ( pp<str.length && str.charCodeAt(pp) == '*'.code){
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