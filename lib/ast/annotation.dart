import 'ast.dart';

class Annotation extends TodoNode {
  final String text;

  Annotation(this.text) : super("Annotation");
}
