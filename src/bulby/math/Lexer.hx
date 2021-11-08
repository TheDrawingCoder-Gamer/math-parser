package bulby.math;

using bulby.math.Helper.ArrayTools;
enum Token {
    Number(value:Float);
    Add;
    Sub;
    Div;
    Mul;
    Mod;
    LParen;
    RParen;
    Pow;
    Function(name:String);
    Negate;
}
typedef Options = {
    var ?powAstreisk:Bool;
}
class Lexer {
    public static function tokenize(input:String, ?options:Options):Array<Token> {
        if (options == null) {
            options = {
                powAstreisk: false
            };
        } else {
            options = {
                powAstreisk: options.powAstreisk == true
            };
        }

        var constr = new ConsumableString(input);
        var tokens:Array<Token> = [];
        var curChar = "";
        while (!constr.empty) {
            switch (curChar = constr.consume()) {
                case _ if (Helper.isFloatNumeric(curChar)): 
                    tokens.push(Number(constr.consumeFloat()));
                case "+": 
					tokens.push(Add);
                case "/": 
                    tokens.push(Div);
                case "*":
                    if (!options.powAstreisk) {
                        tokens.push(Mul);
                    } else {
                        if (constr.peek() == "*") {
                            constr.consume();
                            tokens.push(Pow);
                        } else {
                            tokens.push(Mul);
                        }
                    }
                case "%":
                    tokens.push(Mod);
                case "(":
                    tokens.push(LParen);
                case ")":
                    tokens.push(RParen);
                // If options.powAstreisk is true, this falls to the default, which throws an error
                case "^" if (!options.powAstreisk):
                    tokens.push(Pow);
                case "-": 
                    // Parser will handle negative numbers; 
                    // It will ensure that if the next token is a number
                    //  and the previous is an operator
                    // it will be negative
                    if (tokens.length == 0 || tokens.peek().match(Add | Sub | Div | Mul | Mod |Pow)) {
                        tokens.push(Negate);
                    } else 
					    tokens.push(Sub);
                case " " | "\t" | "\n" | "\r" | ",":
                    // Do nothing
                case _ if (Helper.isAlpha(curChar)):
                    var name = constr.consumeName();
                    switch (name) {
                        case "pi": 
                            tokens.push(Number(Math.PI));
                        case "e": 
                            tokens.push(Number(Math.exp(1)));
                        default: 
                            tokens.push(Function(name));
                    }
                default: 
                    throw "Unexpected Character: " + curChar;
            }
        }
        return tokens;
    }
}

class ConsumableString {
    public var string:String;
    public var pos:Int;
    public var empty(get, never):Bool;
    public function new(str:String) {
        string = str;
        pos = 0;
    }

    public function consume() {
        // Skips over characters
        return string.charAt(pos++);
    }
    public function consumeString(n:Int = 1) {
		var ret = string.substr(pos, n);
		pos += n;
		return ret;
    }
    @:pure
    public function peek(n:Int = 0) {
        return string.charAt(pos + n);
    }
    @:pure
    public function peekString(n:Int = 1) {
        return string.substr(pos, n);
    }
    function get_empty() {
        return pos >= string.length;
    }
    public function consumeInt() {
        var num = peek(-1);
        if (num != "+" && num != "-" && !Helper.isNumeric(num)) 
            throw "Expected Integer";
		var curChar = "";
		while (!empty && Helper.isNumeric(curChar = consume())) {
			num += curChar;
		}
        return Std.parseInt(num);
    }
    public function consumeFloat() {
        var num = peek(-1);
        if (num != "+" && num != "-" && !Helper.isFloatNumeric(num)) 
            throw "Expected Float";
        var curChar = "";
        while (!empty && Helper.isFloatNumeric(curChar = consume())) {
            num += curChar;
        }
        return Std.parseFloat(num);
    }
    public function consumeName() {
        var name = peek(-1);
        if (!Helper.isAlpha(name))
            throw "Start of name must be a letter.";
        var curChar = "";
        while (!empty && Helper.isAlphaNumeric(curChar = consume())) {
            name += curChar;
        }
        return name;
    }

    // Thank you copilot for giving me this idea
    public function consumeWhile(fun:String -> Bool) {
        var ret = peek(-1);
        var curChar = "";
        while (!empty && fun(curChar = consume())) {
            ret += curChar;
        }
        return ret;
    } 
}