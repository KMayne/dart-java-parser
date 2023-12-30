import 'ast.dart';

class Annotation extends TodoNode {
  final String text;

  @override String get symbolName => "TODO<$text>";

  Annotation(this.text);
}
