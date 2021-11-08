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
    Add;
    Sub;
    Div;
    Mul;
    Mod;
    Pow;
    Call(name:String, args:Array<Expr>);
    LParen;
    RParen;
    Negate;
    Identity;
}
enum OpKind {
    Prefix;
    Infix;
    Postfix;

}
class Expr {
    public var children:Array<Expr>;
    public var value:EExpr;
    public function new(value:EExpr, ?children:Array<Expr>):Void {
        this.value = value;
        this.children = children == null ? [] : children;
    }
    function toString() {
        return value + "(" + children.join(",") + ")";
    }
}
class Parser {
    // Unary operators MUST have higher precedence than binary operators.
    public static var precedence:Map<EExpr, Int> = [
        Add => 4,
        Sub => 4,
        Mul => 3,
        Div => 3,
        Mod => 3,
        Pow => 2,
        Negate => 1,
        Identity => 1

    ];
    public static var associativity:Map<EExpr, Associativity> = [
        Add => Left,
        Sub => Left,
        Mul => Left,
        Div => Left,
        Mod => Left,
        Pow => Right
    ];
    public static var opkind:Map<EExpr, OpKind> = [
        Add => Infix,
	    Sub => Infix,
	    Mul => Infix,
	    Div => Infix,
		Mod => Infix,
		Pow => Infix,
        Negate => Prefix,
        Identity => Prefix
    ];
    static function eexprFromToken(token:Token):EExpr {
        switch (token) {
            case Token.Number(value): 
                return Number(value);
            case Add: 
                return Add;
            case Sub:
                return Sub;
            case Mul:
                return Mul;
            case Div:
                return Div;
            case Mod:
                return Mod;
            case Pow:
                return Pow;
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
						|| ((tokens[pos - 1] == LParen || opkind[eexprFromToken(tokens[pos - 1])] == Infix ) && operandStack.peek().value.match(Number(_)))): 
					while (operatorStack.length > 0) {
						var top = operatorStack.peek();
						if (top != LParen
							&& (precedence[top] < precedence[Negate])) {
							switch (opkind[top]) {
								case Infix:
									final right = operandStack.pop();
									final left = operandStack.pop();
									operandStack.push(new Expr(operatorStack.pop(), [left, right]));
								case Prefix:
									final arg = operandStack.pop();
									operandStack.push(new Expr(operatorStack.pop(), [arg]));
								case Postfix:
									// TODO: Implement postfix
							}
						} else {
							break;
						}
					}
                    operatorStack.push(Negate);
                case Add if ((pos - 1 < 0 || tokens[pos - 1] == LParen || opkind[eexprFromToken(tokens[pos - 1])] == Infix) && operandStack.peek().value.match(Number(_))): 
					while (operatorStack.length > 0) {
						var top = operatorStack.peek();
						if (top != LParen
							&& (precedence[top] < precedence[Identity]
								|| (precedence[top] == precedence[Identity]
									&& associativity[eexprFromToken(token)] == Left))) {
							switch (opkind[top]) {
								case Infix:
									final right = operandStack.pop();
									final left = operandStack.pop();
									operandStack.push(new Expr(operatorStack.pop(), [left, right]));
								case Prefix:
									final arg = operandStack.pop();
									operandStack.push(new Expr(operatorStack.pop(), [arg]));
								case Postfix:
									// TODO: Implement postfix
							}
						} else {
							break;
						}
					}
                    operatorStack.push(Identity);
                case _ if (opkind.exists(eexprFromToken(token))): 
                    while (operatorStack.length > 0) {
                        var top = operatorStack.peek();
                        if (top != LParen && (precedence[top] < precedence[eexprFromToken(token)] || (precedence[top] == precedence[eexprFromToken(token)] && associativity[eexprFromToken(token)] == Left))) {
                            switch (opkind[top]) {
                                case Infix:
									final right = operandStack.pop();
									final left = operandStack.pop();
									operandStack.push(new Expr(operatorStack.pop(), [left, right]));
                                case Prefix:
                                    final arg = operandStack.pop();
                                    operandStack.push(new Expr(operatorStack.pop(), [arg]));
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
                            operandStack.push(new Expr(operatorStack.pop(), [left, right]));
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

        while (operatorStack.length > 0) {
            switch (opkind[operatorStack.peek()]) {
                case Infix: 
					final right = operandStack.pop();
					final left = operandStack.pop();
					operandStack.push(new Expr(operatorStack.pop(), [left, right]));
                case Prefix: 
                    final right = operandStack.pop();
                    operandStack.push(new Expr(operatorStack.pop(), [right]));
                case Postfix:
                    // todo
            }
            
        }
        trace(operandStack.peek());
        return operandStack.pop();

    }
}

