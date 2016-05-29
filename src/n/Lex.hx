package n;

import n.Types;
using StringTools;

class Lex {

	static var SPECIAL_CHARS :String = "|[]{}<>*";
	
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
				case Char(c)		: String.fromCharCode(c);
				case Pipe			: '|';
				case Literal(str)	: str;
				case AccOpen		: "}";
				case AccCondOpen	: "{!";
				case AccClose		: "}";
				case TagOpen		: "<";
				case TagClose		: ">";
				case BrackOpen		: "[";
				case BrackClose		: "]";
				case Star			: "*";
				case DoubleStar		: "**";
			}
	}
	
	public static inline function lexemsToString(l:List<Lexem> ) {
		var b = new StringBuf();
		for ( p in l) {
			switch(p) {
				case Char(c)		: b.addChar(c);
				case Pipe			: b.addChar('|'.code);
				case Literal(str)	: b.add(str);
				case AccOpen		: b.addChar("}".code);
				case AccCondOpen	: b.add("{!");
				case AccClose		: b.addChar("}".code);
				case TagOpen		: b.addChar("<".code);
				case TagClose		: b.addChar(">".code);
				case BrackOpen		: b.addChar("[".code);
				case BrackClose		: b.addChar("]".code);
				case Star			: b.addChar("*".code);
				case DoubleStar		: b.addChar("*".code);b.addChar("*".code);
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
					result.add(Literal(sub));
					_parse( str, end + 1, result);
				}
			case '{':	
				var pp = pos+1;
				if ( (pos + 1 < str.length) 
				&& str.charCodeAt(pp) == '!'.code){
					result.add( AccCondOpen );
					pp++;
				}
				else 
					result.add( AccOpen );
				_parse( str, pp, result);
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
					case '<'.code:	result.add( TagOpen );
					case '>'.code:	result.add( TagClose );
					case '{'.code:	result.add( AccOpen );
					case '}'.code:	result.add( AccClose );
					case '['.code:	result.add( BrackOpen );
					case ']'.code:	result.add( BrackClose );
				}
				_parse( str, pp, result);
			}
		}
		
	}
	
}