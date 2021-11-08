package;

function main() {
    var input = Sys.args()[0];
    var tokens = bulby.math.Lexer.tokenize(input);
    var parser = bulby.math.Parser.parse(tokens);
    var result = bulby.math.Evaluator.evaluate(parser);
    trace(result);
}