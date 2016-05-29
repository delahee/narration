package n;

import n.Types;

class Gram
{

	public function new() 
	{
		
	}

	public function parse(str:Array<Lexem>) : Ast {
		return _parse(str, 0);
	}
	
	public static inline function isChar( l:Lexem ) {
		return switch( l ) {
			case Char(_):true;
			default:false;
		}
	}
	
	public static inline function getChar( l:Lexem ) {
		return switch( l ) {
			case Char(c):c;
			default:throw "assert";
		}
	}
	
	function _parse(str:Array<Lexem>, pos:Int) : Ast {
		if ( pos >= str.length)
			return Nop;
		else
		return
		switch( str[pos]) {
			case Char(i):
				var b = new StringBuf();
				var pp = pos;
				while( pp < str.length && isChar(str[pp])) {
					b.addChar( getChar( str[pp] ));
					pp++;
				}
				var l = b.toString();
				if ( pp >= str.length) 
					return Sentence(l);
				else 
					return Seq( Sentence(l), _parse( str, pp ));
			case Star, DoubleStar, Pipe:
				var elem = str[pos];
				var lit = switch(elem) {
					default: throw "error";
					case Star: "*";
					case DoubleStar: "*";
					case Pipe: "*";
				}
				var res = -1;
				for ( i in pos+1...str.length)
					if ( str[i] == Star){
						res = i;
						break;
					}
				if ( res == -1) {
					trace("corresponding * not found");
					return Seq( Sentence("*"), _parse( str, pos + 1));
				}
				else {
					var sub = str.slice(pos + 1, res);
					var rest = str.slice(res + 1, str.length);
					if ( rest.length == 0) {
						return Em( _parse(sub, 0));
					}
					else 
						return Seq( Em( _parse(sub,0)), _parse(rest,0));
				}
				
			case AccClose, BrackClose, TagClose:
				trace( "unexpected " + str[pos]);
				return Seq( Sentence(n.Lex.lexemToString(str[pos])), _parse(str, pos + 1));
				
			case TagOpen:
				//find end bracket
				//find end tag
				//parse subcontent
				return Nop;
				
			case Literal(str):
				return Sentence( str );
				
			case BrackOpen, AccOpen, AccCondOpen:
				var elem = str[pos];
				var close = switch(elem) {
					default:throw "asert";
					case BrackOpen: BrackClose;
					case AccOpen: AccClose;
					case AccCondOpen: AccClose;
				}
				var closure = function(content) {
					var str = n.Lex.lexemsToString(Lambda.list(content));
					return switch(elem) {
						default:throw "asert";
						case BrackOpen: 	Ast.Event(str);
						case AccOpen: 		Ast.UniqueEvent(str);
						case AccCondOpen: 	Ast.CondUniqueEvent(str);
					}
				}
				var res = seek( str, pos + 1, close );
				if ( res == -1) {
					trace("corresponding ] not found");
					return Seq( Sentence("["), _parse( str, pos + 1));
				}
				else {
					var sub = str.slice(pos + 1, res);
					var rest = str.slice(res + 1, str.length);
					if ( rest.length == 0) {
						return closure( sub );
					}
					else 
						return Seq( closure(sub), _parse(rest,0));
				}
		};
	}
	
	inline function seek(str:Array<Lexem>, start:Int, tok:Lexem) : Int {
		var res = -1;
		for ( i in start...str.length)
			if ( str[i] == tok){
				res = i;
				break;
			}
		return res;
	}
}