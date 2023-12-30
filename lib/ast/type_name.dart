import 'annotation.dart';
import 'ast.dart';
import 'class_body_declaration.dart';

class TypeName extends AstNode {
  final List<String> typeNameParts;

  @override
  String? get symbolName => typeNameParts.join(".");

  TypeName(this.typeNameParts);

  TypeName.empty() : this([]);

  TypeName prependPart(String? part) =>
      part == null ? this : TypeName([part, ...typeNameParts]);
}

sealed class TypeArgument extends AstNode {}

class ReferenceTypeArgument extends TypeArgument {
  final ReferenceTypeDescriptor type;

  @override
  get children => [type];

  ReferenceTypeArgument(this.type);
}

class WildcardTypeArgument extends TypeArgument {
  final List<Annotation> annotations;
  final WildcardBounds? bounds;

  @override
  get children => [...annotations, bounds].whereType<AstNode>();

  WildcardTypeArgument(this.annotations, this.bounds);
}

sealed class WildcardBounds extends AstNode {}

class ExtendsWildcardBounds extends WildcardBounds {
  final ReferenceTypeDescriptor type;

  @override
  get children => [type];

  ExtendsWildcardBounds(this.type);
}

class SuperWildcardBounds extends WildcardBounds {
  final ReferenceTypeDescriptor type;

  @override
  get children => [type];

  SuperWildcardBounds(this.type);
}

sealed class TypeDescriptor extends AstNode {}

class PrimitiveTypeDescriptor extends TypeDescriptor {
  final PrimitiveTypeName typeName;

  @override
  get symbolName => typeName.name;

  PrimitiveTypeDescriptor(this.typeName);
}

enum PrimitiveTypeName {
  jBoolean("boolean"),
  jByte("byte"),
  jShort("short"),
  jInt("int"),
  jLong("long"),
  jChar("char"),
  jFloat("float"),
  jDouble("double");

  const PrimitiveTypeName(String name);
}

sealed class ReferenceTypeDescriptor extends TypeDescriptor {}

class ClassOrInterfaceTypeDescriptor extends ReferenceTypeDescriptor {
  final TypeName? packageName;
  final List<Annotation> annotations;
  final TypeIdentifier identifier;
  final List<TypeArgument> arguments;
  final InnerClassOrInterfaceTypeDescriptor? uCoit;

  ClassOrInterfaceTypeDescriptor(this.packageName, this.annotations,
      this.identifier, this.arguments, this.uCoit);
}

class InnerClassOrInterfaceTypeDescriptor extends AstNode {
  final List<Annotation> annotations;
  final TypeIdentifier identifier;
  final List<TypeArgument> arguments;
  final InnerClassOrInterfaceTypeDescriptor? uCoit;

  InnerClassOrInterfaceTypeDescriptor(
      this.annotations, this.identifier, this.arguments, this.uCoit);
}

class TypeVariableTypeDescriptor extends ReferenceTypeDescriptor {
  final TypeIdentifier typeVarName;

  TypeVariableTypeDescriptor(this.typeVarName);
}

class ArrayTypeDescriptor extends ReferenceTypeDescriptor {
  final TypeDescriptor elementTypeDescriptor;
  final Dimensions dimensions;

  ArrayTypeDescriptor(this.elementTypeDescriptor, this.dimensions);
}

class TypeIdentifier extends AstNode {
  final String name;

  TypeIdentifier(this.name);

  @override
  String get symbolName => name;
}

class AnnotatedTypeDescriptor extends AstNode {
  final ListNode<Annotation> annotations;
  final TypeDescriptor type;

  @override
  Iterable<AstNode> get children => [annotations, type];

  AnnotatedTypeDescriptor(this.annotations, this.type);
}
