
import n.Lex;
class Test {

	public static function main()
	{
		var lrs = [];
		var l = new n.Lex();
		var lr = l.parse(" yo *dude* ");
		trace(Lex.lexemsToString(lr));
		lrs.push(lr);
		
		var lr = l.parse(" yo **dude** ");
		trace(Lex.lexemsToString(lr));
		lrs.push(lr);
		
		var lr = l.parse(" yo **dude**");
		trace(Lex.lexemsToString(lr));
		lrs.push(lr);
		
		var lr = l.parse(" yo **dude**\\");
		trace(Lex.lexemsToString(lr));
		lrs.push(lr);
		
		var lr = l.parse("\\*");
		trace(lr);
		lrs.push(lr);
		
		var lr = l.parse("*");
		trace(lr);
		lrs.push(lr);
		
		var lr = l.parse("yo |dude a*b|");
		trace(lr);
		trace(Lex.lexemsToString(lr));
		lrs.push(lr);
		
		var lr = l.parse("yo {dude} ");
		trace(lr);
		trace(Lex.lexemsToString(lr));
		lrs.push(lr);
		
		var lr = l.parse("yo {!dude} ");
		trace(lr);
		trace(Lex.lexemsToString(lr));
		lrs.push(lr);
		
		var lr = l.parse("yo {!dude");
		trace(lr);
		trace(Lex.lexemsToString(lr));
		lrs.push(lr);
		
		var lr = l.parse("<> {} []");
		trace(lr);
		lrs.push(lr);
		
		var lr = l.parse("|var a = 0; var b=1; var c = a*b;|");
		trace(lr);
		trace(Lex.lexemsToString(lr));
		lrs.push(lr);
		
		var g = new n.Gram();
		var t = g.parse(Lambda.array(lrs[0]));
		trace(t);
	}
	
}