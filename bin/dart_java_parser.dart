import 'package:dart_java_parser/dart_java_parser.dart' as dart_java_parser;

void main(List<String> arguments) async {
  final ast = await dart_java_parser.buildJavaAst(arguments[0]);
  print(ast.toTreeString());
}
