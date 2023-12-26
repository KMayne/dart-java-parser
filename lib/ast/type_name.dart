import 'ast.dart';

class TypeName extends AstNode {
  final List<String> typeNameParts;

  @override String? get symbolName => typeNameParts.join(".");

  TypeName(this.typeNameParts);

  TypeName.empty() : this([]);

  TypeName prependPart(String? part) => part == null ? this : TypeName([part, ...typeNameParts]);
}
