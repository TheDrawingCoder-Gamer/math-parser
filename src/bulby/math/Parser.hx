package bulby.math;

import bulby.math.Lexer.Token;
enum Side {
    Left;
    Right;
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
    public static var precedence:Map<EExpr, Int> = [
        Add => 2,
        Sub => 2,
        Mul => 3,
        Div => 3,
        Mod => 3,
        Pow => 4
    ];
    public static var associativity:Map<EExpr, Side> = [
        Add => Left,
        Sub => Left,
        Mul => Left,
        Div => Left,
        Mod => Left,
        Pow => Right
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
                case Add | Sub | Mul | Div | Mod | Pow: 
                    while (operatorStack.length > 0) {
                        var top = operatorStack[operatorStack.length - 1];
                        if (top != LParen && (precedence[top] > precedence[eexprFromToken(token)] || (precedence[top] == precedence[eexprFromToken(token)] && associativity[eexprFromToken(token)] == Left))) {
                            final right = operandStack.pop();
                            final left = operandStack.pop();
                            operandStack.push(new Expr(operatorStack.pop(), [left, right]));
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
                        var top = operatorStack[operatorStack.length - 1];
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
                    var top = operatorStack[operatorStack.length - 1];
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
            final right = operandStack.pop();
            final left = operandStack.pop();
            operandStack.push(new Expr(operatorStack.pop(), [left, right]));
        }
        return operandStack.pop();

    }
}