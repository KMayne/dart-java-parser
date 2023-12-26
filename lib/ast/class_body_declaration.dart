import 'ast.dart';
import 'class_like_declaration.dart';

abstract class ClassBodyDeclaration extends AstNode {}

class InstanceInitializer extends TodoNode {}
class StaticInitializer extends TodoNode {}
class ConstructorDeclaration extends TodoNode {}

abstract class ClassMemberDeclaration extends TodoNode {}

class FieldDeclaration extends ClassMemberDeclaration {}
class MethodDeclaration extends ClassMemberDeclaration {}
class InnerClassLikeDeclaration extends ClassMemberDeclaration {
  final ClassLikeDeclaration declaration;

  InnerClassLikeDeclaration(this.declaration);
}