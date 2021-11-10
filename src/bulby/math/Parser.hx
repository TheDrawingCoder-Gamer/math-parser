package bulby.math;

import bulby.math.Lexer.Token;
using bulby.math.Helper.ArrayTools;
enum Associativity {
    Left;
    Right;
    None;
}
enum EExpr {
    Number(value:Float);
    Add(left:Expr, right:Expr);
    Sub(left:Expr, right:Expr);
    Div(left:Expr, right:Expr);
    Mul(left:Expr, right:Expr);
    Mod(left:Expr, right:Expr);
    Pow(left:Expr, right:Expr);
    Call(name:String, args:Array<Expr>);
    Negate(expr:Expr);
    LParen;
    RParen;
}
enum OpKind {
    Prefix;
    Infix;
    Postfix;

}
class Expr {
    // public var children:Array<Expr>;
    public final value:EExpr;
    public function new(value:EExpr /*, ?children:Array<Expr> */):Void {
        this.value = value;
        // this.children = children == null ? [] : children;
    }
    function toString():String {
        return value + "";
    }
}
class Parser {
    
    static function eexprFromToken(token:Token):EExpr {
        switch (token) {
            case Token.Number(value): 
                return Number(value);
            case Add: 
                return Add(null, null);
            case Sub:
                return Sub(null, null);
            case Mul:
                return Mul(null, null);
            case Div:
                return Div(null, null);
            case Mod:
                return Mod(null, null);
            case Pow:
                return Pow(null, null);
            case LParen:
                return LParen;
            case RParen:
                return RParen;
            case Function(name):
                return Call(name, []);
        }
    }
    public static function parse(tokens:Array<Token>) {
        var operatorStack:Array<EExpr> = [];
        final operandStack:Array<Expr> = [];
        var pos = 0;
        while (pos < tokens.length) {
            var token = tokens[pos];
            switch (token) {
                case Number(value): 
                    operandStack.push(new Expr(Number(value)));
                // If this is the first operator OR the previous operator was a binop or the start of a parentesis
				case Sub
					if (pos == 0
						|| ((tokens[pos - 1] == LParen || opkind(eexprFromToken(tokens[pos - 1])) == Infix ) && operandStack.peek().value.match(Number(_)))): 
					while (operatorStack.length > 0) {
						var top = operatorStack.peek();
						if (top != LParen
							&& (precedence(top) < precedence(Negate(null)))) {
							switch (opkind(top)) {
								case Infix:
									final right = operandStack.pop();
									final left = operandStack.pop();
									operandStack.push(new Expr(fillEnumValue(operatorStack.pop(), [left, right])));
								case Prefix:
									final arg = operandStack.pop();
									operandStack.push(new Expr(fillEnumValue(operatorStack.pop(), [arg])));
								case Postfix:
									// TODO: Implement postfix
							}
						} else {
							break;
						}
					}
                    operatorStack.push(Negate(null));
                case _ if (opkind(eexprFromToken(token)) != null): 
                    while (operatorStack.length > 0) {
                        var top = operatorStack.peek();
                        if (top != LParen && (precedence(top) < precedence(eexprFromToken(token)) || (precedence(top) == precedence(eexprFromToken(token)) && associativity(eexprFromToken(token)) == Left))) {
                            switch (opkind(top)) {
                                case Infix:
									final right = operandStack.pop();
									final left = operandStack.pop();
									operandStack.push(new Expr(fillEnumValue(operatorStack.pop(), [left, right])));
                                case Prefix:
                                    final arg = operandStack.pop();
                                    operandStack.push(new Expr(fillEnumValue(operatorStack.pop(), [arg])));
                                case Postfix:
                                    // TODO: Implement postfix
                            }   
                            
                        } else {
                            break;
                        }
                    }
                    operatorStack.push(eexprFromToken(token));
                case Function(_): 
                    operatorStack.push(eexprFromToken(token));
                case LParen:
                    operatorStack.push(eexprFromToken(token));
                case RParen: 
                    var hasParen = false;
                    while (operatorStack.length > 0) {
                        var top = operatorStack.peek();
                        if (top != LParen) {
                            final right = operandStack.pop();
                            final left = operandStack.pop();
                            operandStack.push(new Expr(fillEnumValue(operatorStack.pop(), [left, right])));
                        } else {
                            hasParen = true;
                            operatorStack.pop();
                            break;
                        }
                    }
                    if (!hasParen)
                        throw "Unmatched Parenthesis";
                    var top = operatorStack.peek();
                    switch (top) {
                        case Call(name, _): 
                            var args = [];
                            while (operandStack.length > 0) {
                                args.push(operandStack.pop());
                            }
                            operandStack.push(new Expr(Call(name, args)));
                        default: 

                    }
                    

            }
            pos++;
        }

        trace(operandStack);
        while (operatorStack.length > 0) {
            var top = operatorStack.peek();
            switch (opkind(top)) {
                case Prefix:
                    final arg = operandStack.pop();
                    operandStack.push(new Expr(fillEnumValue(operatorStack.pop(), [arg])));
                case Infix:
                    final right = operandStack.pop();
                    final left = operandStack.pop();
                    operandStack.push(new Expr(fillEnumValue(operatorStack.pop(), [left, right])));
                case Postfix:
                    // TODO
            }
        }
        trace(operandStack.peek());
        return operandStack.pop();

    }
    public static function precedence(eexpr:EExpr):Null<Int> {
        switch (eexpr) {
            case Sub(_, _) | Add(_, _):
                return 4;
            case Mul(_, _) | Div(_, _):
                return 3;
            case Pow(_, _):
                return 2;
            case Negate(_):
                return 1;
            default:
                return null;
        }
    }
    public static function associativity(eexpr:EExpr):Null<Associativity> {
        switch (eexpr) {
            case Sub(_, _) | Add(_, _) | Mul(_, _) | Div(_, _):
                return Left;
            case Pow(_, _) | Negate(_):
                return Right;
            default:
                return null;
        }
    }
    public static function opkind(eexpr:EExpr):Null<OpKind> {
        switch (eexpr) {
            case Sub(_, _) | Add(_, _) | Mul(_, _) | Div(_, _) | Pow(_, _):
                return Infix;
            case Negate(_):
                return Prefix;
            default: 
                return null;
        }
    }
    public static function fillEnumValue(eexpr:EExpr, args:Array<Dynamic>) {
        switch (eexpr) {
            case Sub(_, _):
                return Sub(args[0], args[1]);
            case Add(_, _):
                return Add(args[0], args[1]);
            case Mul(_, _):
                return Mul(args[0], args[1]);
            case Div(_, _):
                return Div(args[0], args[1]);
            case Pow(_, _):
                return Pow(args[0], args[1]);
            case Negate(_):
                return Negate(args[0]);
            case Call(name, _):
                // Why do I have to cast here; dynamic should do that automatically
                return Call(name, cast args);
            case Number(_):
                return Number(args[0]);
            default:
                return null;
        }

    }
}

