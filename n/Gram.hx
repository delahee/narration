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
			case Star, DoubleStar, Pipe,DoubleSemiColon:
				var elem = str[pos];
				var lit = switch(elem) {
					default: throw "error";
					case Star: "*";
					case DoubleStar: "**";
					case Pipe: "|";
					case DoubleSemiColon:"::";
				}
				inline function closure(str:Array<Lexem>) {
					return 
					switch(elem) {
						default: Sentence(restring(str));
						case Star: Em( _parse(str , 0 ));
						case DoubleStar: Strong( _parse(str , 0 ));
						case DoubleSemiColon,Pipe: Script( restring(str) );
					}
				}
				var res = -1;
				for ( i in pos+1...str.length)
					if ( str[i] == elem){
						res = i;
						break;
					}
				if ( res == -1) {
					trace("corresponding "+elem+" not found");
					return mkSeq( Sentence(lit), _parse( str, pos + 1));
				}
				else {
					var sub = str.slice(pos + 1, res);
					var rest = str.slice(res + 1, str.length);
					return mkSeq( closure( sub ), _parse(rest,0));
				}
				
			case AccClose, BrackClose, TagClose(_):
				trace( "unexpected " + str[pos]);
				return mkSeq( Sentence(restringOne(str[pos])), _parse(str, pos + 1));
			
			case TagSelfClosed(s): return Tag( s , n.Ast.Nop );
			
			case TagOpen(s):
				var res = seek( str, pos + 1, TagClose(s) );
				if ( res == -1) return mkSeq( Sentence(restringOne(str[pos])), _parse( str, pos + 1));
				
				var content : Ast = _parse( str.slice( pos+1, res), 0);
				return mkSeq(Tag( s , content), _parse( str, res + 1) );
				
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
					trace("corresponding "+close+" not found");
					return mkSeq( Sentence(restringOne(str[pos])), _parse( str, pos + 1));
				}
				
				var sub = str.slice(pos + 1, res);
				var rest = str.slice(res + 1, str.length);
				return mkSeq( closure(sub), _parse(rest,0));
		};
	}
	
	inline function mkSeq( ast, rest ) {
		if ( rest == Nop )
			return ast;
		else 
			return Seq( ast, rest);
	}
	
	inline function restringOne(elem) return  n.Lex.lexemToString(elem);
	
	inline function restring(str:Array<Lexem>) {
		return  n.Lex.lexemsToString(Lambda.list(str));
	}
	
	function seek(str:Array<Lexem>, start:Int, tok:Lexem) : Int {
		var res = -1;
		for ( i in start...str.length)
			if ( Type.enumEq(str[i],tok)){
				res = i;
				break;
			}
		return res;
	}
}