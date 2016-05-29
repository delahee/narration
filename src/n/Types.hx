package n;

class Types { }

typedef PosInfo = { line:Int, char:Int };

enum Condition {
	Gt( varName0 : String, varName1: String);
	Ge( varName0 : String, varName1: String);
	Not( varName0 : String);
	And( c0:Condition, c1:Condition );
	Or( c0:Condition, c1:Condition );
}

enum Sentence {
	Comment(str:String);
	Literal(str:String);
	If( cond:Condition, lit:Sentence);
	IfNot( cond:Condition, lit:Sentence);
	Dialog( body : String, arr:Array<Sentence> );
}

enum Paragraph  {
	Didascaly(str:String);
	Body(str:String);
	Dialog(content:Sentence);
	End;
}

typedef Story = {
	var paragraphs : Array<{content:Paragraph,pos:PosInfo}>;
	var variables : Array<String>;
}

typedef Context = {
	var gBools : Map<String,Bool>;
	var gInt : Map<String,Int>;
	
	var lBools : Map<String,Bool>;
	var lInt : Map<String,Int>;
	
	var chapters : Array<Story>;
}

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
	Star		;
	DoubleStar	;
}

enum Ast {
	Seq( s0:Ast, s1:Ast );
	Sentence( l : String);
	Em( sub : Ast ); //*
	Strong( sub : Ast ); //**
	Event(str:String);
	UniqueEvent(str:String);
	CondUniqueEvent(str:String);
	Tag(tag:String, sub:Ast);
	Nop;
	Script( str:String );
}