import 'package:java_parser/java_parser.dart' as java_parser;

void main(List<String> arguments) async {
  final ast = await java_parser.buildJavaAst(arguments[0]);
  print(ast.toTreeString());
}
