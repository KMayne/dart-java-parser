import 'package:java_parser/ast/type_name.dart';

import 'ast.dart';

class ImportDeclaration extends AstNode {
  TypeName typeName;
  bool static;
  bool onDemand;

  ImportDeclaration(this.typeName,
      {required this.onDemand, required this.static});

  @override
  String toString() => "${super.toString()}<import: $typeName, static: $static, onDemand: $onDemand>";
}
