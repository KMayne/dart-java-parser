import 'annotation.dart';
import 'ast.dart';
import 'class_like_declaration.dart';

abstract class ClassBodyDeclaration extends AstNode {}

class InstanceInitializer extends ClassBodyDeclaration {}
class StaticInitializer extends ClassBodyDeclaration {}
class ConstructorDeclaration extends ClassBodyDeclaration {}

abstract class ClassMemberDeclaration extends ClassBodyDeclaration {}

class AnnotationFieldModifier extends AstNode {
  final Annotation annotation;

  AnnotationFieldModifier(this.annotation);
}

class BasicFieldModifier extends AstNode {
}
enum FieldModifierEnum {
  jPublic("public"),
  jProtected("protected"),
  jPrivate("private"),
  jStatic("static"),
  jFinal("final"),
  jSealed("transient"),
  jNonSealed("volatile");

  final String name;

  const FieldModifierEnum(this.name);
}

class FieldDeclaration extends ClassMemberDeclaration {
  final List<FieldModifier> modifiers;

  FieldDeclaration(this.modifiers);
}

class MethodDeclaration extends ClassMemberDeclaration {}
class InnerClassLikeDeclaration extends ClassMemberDeclaration {
  final ClassLikeDeclaration declaration;

  InnerClassLikeDeclaration(this.declaration);
}