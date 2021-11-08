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
            case 2: 
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
                        if (args.length != argCount[name])
                            throw "Evaluation Error: Invalid Argument Count";
						return Reflect.callMethod(null, functions[name], args.map((e) -> evaluate(e)));
                    default: 
                        throw "Evaluation Error: Expected operator in node, got " + expr.value;
                }
            case 1: 
                final left = expr.children[0];
                switch (expr.value) {
                    case Call(name, args): 
						if (!functions.exists(name)) {
							throw "Unknown function: " + name;
						}
						if (args.length != argCount[name])
							throw "Evaluation Error: Invalid Argument Count";
						return Reflect.callMethod(null, functions[name], args.map((e) -> evaluate(e)));
                    case Negate:
                        return -evaluate(left);
                    default: 
                        throw "Evaluation Error: Expected Unary Operator";
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
                        if (args.length != argCount[name]) {
                            throw "Evaluation Error: Invalid Argument Count";
                        }
                        return Reflect.callMethod(null, functions[name], args.map((e) -> evaluate(e)));
                    default: 
                        throw "Evaluation Error: Expected function call in node, got " + expr.value;
                }
        }
    }
}