package n;

class Types { }


enum Lexem {
	Char(c:Int)	;
	Pipe		;
	Literal(str:String);
	AccOpen		;
	AccCondOpen	;
	AccClose	;
	TagOpen(str:String);
	TagClose(str:String);
	TagSelfClosed(str:String);
	BrackOpen	;
	BrackClose	;
	BrackCondOpen;
	Star		;
	DoubleStar	;
	DoubleSemiColon;
	BrackPosOpen;
}

enum Ast {
	Seq( s0:Ast, s1:Ast );
	Sentence( l : String);
	Em( sub : Ast ); //*
	Strong( sub : Ast ); //**
	Event(str:String);
	CondEvent(str:String);
	UniqueEvent(str:String);
	CondUniqueEvent(str:String);
	Tag(tag:String, sub:Ast);
	TagFrom(tag:String,isRestEmpty:Bool); 
	Nop;
	Script( str:String );
}