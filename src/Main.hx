package;

function main() {
    var input = sys.io.File.getContent("input.txt");
    var tokens = bulby.math.Lexer.tokenize(input);
    var parser = bulby.math.Parser.parse(tokens);
    var result = bulby.math.Evaluator.evaluate(parser);
    trace(result);
}