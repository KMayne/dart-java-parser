import 'package:java_parser/ast/type_name.dart';

import 'annotation.dart';
import 'ast.dart';
import 'block.dart';
import 'class_like_declaration.dart';
import 'expression.dart';

sealed class ClassBodyDeclaration extends AstNode {}

class InstanceInitializer extends ClassBodyDeclaration {}

class StaticInitializer extends ClassBodyDeclaration {}

class ConstructorDeclaration extends ClassBodyDeclaration {}

sealed class ClassMemberDeclaration extends ClassBodyDeclaration {}

class ModifierNode<T> extends AstNode {
  final T modifier;

  @override
  get symbolName => modifier.toString();

  ModifierNode(this.modifier);
}

enum FieldModifier {
  jPublic("public"),
  jProtected("protected"),
  jPrivate("private"),
  jStatic("static"),
  jFinal("final"),
  jSealed("transient"),
  jNonSealed("volatile");

  final String name;

  @override
  String toString() => name;

  const FieldModifier(this.name);
}

class FieldDeclaration extends ClassMemberDeclaration {
  final List<Annotation> annotations;
  final List<ModifierNode<FieldModifier>> modifiers;
  final TypeDescriptor type;
  final List<VariableDeclarator> declarators;

  @override
  get children => [...annotations, ...modifiers, type, ...declarators];

  FieldDeclaration(
      this.annotations, this.modifiers, this.type, this.declarators);
}

enum MethodModifier {
  jPublic("public"),
  jProtected("protected"),
  jPrivate("private"),
  jAbstract("abstract"),
  jStatic("static"),
  jFinal("final"),
  jSynchronized("synchronized"),
  jNative("native"),
  jStrictFp("strictfp");

  final String name;

  @override
  String toString() => name;

  const MethodModifier(this.name);
}

class MethodDeclaration extends ClassMemberDeclaration {
  final ListNode<Annotation> annotations;
  final ListNode<ModifierNode<MethodModifier>> modifiers;
  final ListNode<TypeParameter> typeParameters;
  final TypeDescriptor? resultType;
  final String name;
  final ReceiverParameter? receiverParameter;
  final ListNode<FormalParameter> parameters;
  final ListNode<TypeDescriptor> throws;
  final Block? methodBody;

  @override
  String get symbolName => name;

  @override
  Iterable<AstNode> get children => [
        annotations,
        modifiers,
        typeParameters,
        resultType,
        receiverParameter,
        parameters,
        throws
      ].whereType<AstNode>();

  MethodDeclaration(
      this.annotations,
      this.modifiers,
      this.typeParameters,
      this.resultType,
      this.name,
      this.receiverParameter,
      this.parameters,
      this.throws,
      this.methodBody);
}

class ReceiverParameter extends AstNode {
  final ListNode<Annotation> annotations;
  final TypeDescriptor type;
  final String? classIdentifier;

  @override
  String? get symbolName => classIdentifier;

  @override
  Iterable<AstNode> get children => [annotations, type];

  ReceiverParameter(this.annotations, this.type, this.classIdentifier);
}

class FormalParameter extends AstNode {
  final ListNode<Annotation> annotations;
  final ModifierNode<bool> isFinal;
  final ModifierNode<bool> isVariableArity;
  final TypeDescriptor type;
  final String name;

  @override
  String get symbolName => name;

  @override
  Iterable<AstNode> get children => [annotations, isFinal, isVariableArity, type];

  FormalParameter(this.annotations, this.isFinal, this.isVariableArity, this.type, this.name);
}

class InnerClassLikeDeclaration extends ClassMemberDeclaration {
  final ClassLikeDeclaration declaration;

  InnerClassLikeDeclaration(this.declaration);
}

class VariableDeclarator extends AstNode {
  final String name;
  final Dimensions? dims;
  final VariableInitializer? initializer;

  @override
  get symbolName => name;

  @override
  get children => [dims, initializer].whereType<AstNode>();

  VariableDeclarator(this.name, this.dims, this.initializer);
}

sealed class VariableInitializer extends AstNode {}

class ExpressionInitializer extends VariableInitializer {
  final Expression expression;

  @override
  get children => [expression];

  ExpressionInitializer(this.expression);
}

class ArrayInitializer extends VariableInitializer {
  final List<VariableInitializer> elements;

  @override
  get children => elements;

  ArrayInitializer(this.elements);
}

class Dimensions extends AstNode {
  @override
  get children => annotations;

  final int count;
  final List<Annotation> annotations;

  Dimensions(this.count, this.annotations);
}
