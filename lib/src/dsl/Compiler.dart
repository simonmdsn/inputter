// ignore_for_file: constant_identifier_names

class Compiler {}

class Parser {}

class Lexer {
  final String code;
  late final int codeLength = code.length;
  int currentLine = 0;

  int index = 0;
  late Token currentToken;
  late Token previousToken;

  Lexer(this.code);

  bool get finished => index > codeLength;

  bool nextToken() {
    while (!finished) {
      final String currentChar = code[index];
      if ([' ', '\r', '\t', '\n'].contains(currentChar)) {
        while (!finished) {
          if ([' ', '\r', '\t', '\n'].contains(currentChar)) {
            index++;
            if (['\n', '\r'].contains(currentChar)) {
              currentLine++;
            }
          } else {
            break;
          }
        }
      }

      switch (currentChar) {
        case '(':
          currentToken = Token(
              tokenType: TokenType.LEFT_PAREN, length: 1, line: currentLine);
          break;
        case ')':
          currentToken = Token(
              tokenType: TokenType.RIGHT_PAREN, length: 1, line: currentLine);
          break;
        case '{':
          currentToken = Token(
              tokenType: TokenType.LEFT_CURLY_BRACKET,
              length: 1,
              line: currentLine);
          break;
        case '}':
          currentToken = Token(
              tokenType: TokenType.RIGHT_CURLY_BRACKET,
              length: 1,
              line: currentLine);
          break;
        case '[':
          currentToken = Token(
              tokenType: TokenType.LEFT_SQUARE_BRACKET,
              length: 1,
              line: currentLine);
          break;
        case ']':
          currentToken = Token(
              tokenType: TokenType.RIGHT_SQUARE_BRACKET,
              length: 1,
              line: currentLine);
          break;

        default:
          throw Exception('Unknown token "$currentToken" at line:$currentLine');
      }

      return true;
    }
    return false;
  }
}

enum TokenType {
  LEFT_PAREN,
  RIGHT_PAREN,
  LEFT_CURLY_BRACKET,
  RIGHT_CURLY_BRACKET,
  LEFT_SQUARE_BRACKET,
  RIGHT_SQUARE_BRACKET,
  DOT,
  PLUS,
  MINUS,
  MULTIPLY,
  DIVIDE,
  EQ,
  LT,
  GT,
  LT_EQ,
  GT_EQ,
  EQ_EQ,
  FOR,
  BREAK,
  CONTINUE,
  WHILE,
  IN,
  LET,
  TRUE,
  FALSE,
  IDENTIFIER,
  NUMBER,
  STRING,
  INTERPOLATION;
}

class Token {
  final TokenType tokenType;
  final int length;
  final int line;

  Token({
    required this.tokenType,
    required this.length,
    required this.line,
  });

  String get memberString => "type: $tokenType, length: $length, line: $line";

  @override
  String toString() => "Token { $memberString }";
}

class ValueToken<T> extends Token {
  final T value;

  ValueToken({
    required super.tokenType,
    required super.length,
    required super.line,
    required this.value,
  });
}
