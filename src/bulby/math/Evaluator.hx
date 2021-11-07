package bulby.math;

import bulby.math.Lexer.Token;

class Evaluator {
    static var functions:Map<String, haxe.Constraints.Function> = [
        "sin" => Math.sin,
        "cos" => Math.cos,
        "tan" => Math.tan,
        "max" => Math.max,
        "min" => Math.min,

    ];
    static var argCount:Map<String, Int> = [
        "sin" => 1,
        "cos" => 1,
        "tan" => 1,
        "max" => 2,
        "min" => 2,
    ];
    public static function evaluate(expr:bulby.math.Parser.Expr):Float {
        switch (expr.children.length) {
            case 2 | 1: 
                final left = expr.children[0];
                final right = expr.children[1];
                switch (expr.value) {
                    case Add: 
                        return evaluate(left) + evaluate(right);
                    case Sub:
                        return evaluate(left) - evaluate(right);
                    case Mul:
                        return evaluate(left) * evaluate(right);
                    case Div:
                        return evaluate(left) / evaluate(right);
                    case Pow:
                        return Math.pow(evaluate(left), evaluate(right));
                    case Mod: 
                        return Std.int(evaluate(left)) % Std.int(evaluate(right));
                    case Call(name, args): 
                        if (!functions.exists(name)) {
                            throw "Unknown function: " + name;
                        }
                        switch (argCount[name]) {
                            case 1: 
                                return functions[name](evaluate(right));
                            case 2: 
                                return functions[name](evaluate(left), evaluate(right));
                            default: 
                                throw "Invalid Argument Count (internal error, fix this dumbass)";
                        }
                    default: 
                        throw "Evaluation Error: Expected operator in node, got " + expr.value;
                }
            case 0:
                switch (expr.value) {
                    case Number(value): 
                        return value;
                    default: 
                        throw "Expected number in leaf";
                }
            default: 
                switch (expr.value) {
                    case Call(name, args): 
                        if (!functions.exists(name)) {
                            throw "Unknown function: " + name;
                        }
                        switch (argCount[name]) {
                            case 1: 
                                return functions[name](evaluate(args[0]));
                            case 2: 
                                return functions[name](evaluate(args[0]), evaluate(args[1]));
                            default: 
                                throw "Invalid Argument Count (internal error, fix this)";
                        }
                    default: 
                        throw "Evaluation Error: Expected function call in node, got " + expr.value;
                }
        }
    }
}