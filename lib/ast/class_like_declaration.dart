import 'package:java_parser/ast/annotation.dart';
import 'package:java_parser/ast/type_name.dart';

import 'ast.dart';

sealed class ClassModifierType extends AstNode {}

class AnnotationClassModifier extends ClassModifierType {
  final Annotation annotation;
  AnnotationClassModifier(this.annotation);

  @override Iterable<AstNode> get children => [annotation];
}

class BasicClassModifier extends ClassModifierType {
  final ClassModifier modifier;

  BasicClassModifier(this.modifier);

  @override
  String get symbolName => modifier.name;
}

enum ClassModifier {
  jPublic("public"),
  jProtected("protected"),
  jPrivate("private"),
  jAbstract("abstract"),
  jStatic("static"),
  jFinal("final", allowedOnInterface: false),
  jSealed("sealed"),
  jNonSealed("non-sealed"),
  jStrictFp("strictFp");

  final String name;
  final bool allowedOnInterface;

  const ClassModifier(
    this.name, {
    this.allowedOnInterface = true,
  });
}

// TODO
class TypeBound extends TodoNode {
  TypeBound() : super("TypeBound");
}

// TODO
class ClassType extends TodoNode {
  ClassType() : super("ClassType");
}

class TypeParameter extends AstNode {
  final List<Annotation> annotations;
  final String paramName;
  final TypeBound? bound;

  TypeParameter(this.annotations, this.paramName, this.bound);

  @override String get symbolName => paramName;
  @override Iterable<AstNode> get children => [...annotations, bound].whereType<AstNode>();
}

sealed class ClassLikeDeclaration extends AstNode {
  final List<ClassModifierType> modifiers;
  final String typeName;

  ClassLikeDeclaration(this.modifiers, this.typeName);
}

class NormalClassDeclaration extends ClassLikeDeclaration {
  final List<TypeParameter> typeParameters;
  final ClassType? classExtends;
  final List<ClassType> classImplements;
  final List<TypeName> classPermits;

  @override String get symbolName => typeName;
  @override Iterable<AstNode> get children => [...super.children, ...modifiers, ...typeParameters, classExtends, classImplements, classPermits].whereType<AstNode>();

  NormalClassDeclaration(
      List<ClassModifierType> modifiers,
      String typeName,
      this.typeParameters,
      this.classExtends,
      this.classImplements,
      this.classPermits)
      : super(modifiers, typeName);
}

// TODO
// class EnumDeclaration extends ClassLikeDeclaration {}
//
// class RecordDeclaration extends ClassLikeDeclaration {}
//
// class InterfaceDeclaration extends ClassLikeDeclaration {}
//
// class AnnotationInterfaceDeclaration extends ClassLikeDeclaration {}
