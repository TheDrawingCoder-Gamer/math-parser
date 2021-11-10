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
        switch (expr.value) {
            case Number(value):
                return value;
            case Add(left, right): 
                return evaluate(left) + evaluate(right);
            case Sub(left, right):
                return evaluate(left) - evaluate(right);
            case Mul(left, right):
                return evaluate(left) * evaluate(right);
            case Div(left, right):
                return evaluate(left) / evaluate(right);
            case Pow(left, right):
                return Math.pow(evaluate(left), evaluate(right));
            case Negate(expr):
                return -evaluate(expr);
            case Call(name, args): 
                if (!functions.exists(name))
                    throw "Unknown function: " + name;
                if (args.length != argCount[name])
                    throw "Invalid number of arguments for function " + name + ": " + args.length;
                return Reflect.callMethod(null, functions[name], args.map((e) -> evaluate(e)));
            default: 
                throw "Eval: Unexpected expr: " + expr.value;
        }
    }
}
