package bulby.math;

@:pure
function isNumeric(str:String) {
	return switch (str) {
		case "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9":
			true;
		default:
			false;
	}
}
@:pure
function isFloatNumeric(str) {
    return switch (str) {
        case ".": 
            true;
        default: 
            isNumeric(str);
    }
}
@:pure
function isAlpha(str:String) {
	return switch (str) {
		case "a" | "b" | "c" | "d" | "e" | "f" | "g" | "h" | "i" | "j" | "k" | "l" | "m" | "n" | "o" | "p" | "q" | "r" | "s" | "t" | "u" | "v" | "w" | "x" |
			"y" | "z":
			true;
		case "A" | "B" | "C" | "D" | "E" | "F" | "G" | "H" | "I" | "J" | "K" | "L" | "M" | "N" | "O" | "P" | "Q" | "R" | "S" | "T" | "U" | "V" | "W" | "X" |
			"Y" | "Z":
			true;
		default:
			false;
	}
}
@:pure
function isAlphaNumeric(str:String ) {
    return isNumeric(str) || isAlpha(str);
}