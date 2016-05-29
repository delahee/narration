
import n.Lex;
class Test {

	public static function main()
	{
		var tests = [
			
			" yo *dude* ",
			" yo **dude** ",
			"\\*",
			"*",
			
			"yo |dude a*b|",
			
			"yo <",
			"yo <lol",
			"yo <lol>",
			"yo <lol> dude",
			
			"yo <lol/>",
			"yo <lol> FU </lol>",
			"yo <lol> $ </lol",
			
			"yo {dude}",
			"yo {!dude}",
			"yo {!dude",
			"yo[dude]yo",
			"tp[]tp",
			"<> {} []",
			"|var a = 'sapin'; var b=1; var c = a*b;|",
			"yo [foo]",
			
		];
		
		for ( txt in tests) {
			var l = new Lex();
			var lexs = l.parse( txt );
			var g = new n.Gram();
			var t = g.parse(Lambda.array(lexs));
			
			trace("src: "+txt);
			trace("res: "+Lex.lexemsToString(lexs));
			trace("lex: "+lexs);
			trace("gram:"+t);
		}
	}
	
}