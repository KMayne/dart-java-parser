import 'dart:ffi';

import 'package:antlr4/antlr4.dart';
import 'package:java_parser/ast/block.dart';
import 'package:java_parser/ast/class_body_declaration.dart';
import 'package:java_parser/ast/class_like_declaration.dart';

import 'antlr/Java20Lexer.dart';
import 'antlr/Java20Parser.dart';
import 'antlr/Java20ParserBaseVisitor.dart';
import 'ast/annotation.dart';
import 'ast/ast.dart';
import 'ast/compilation_unit.dart';
import 'ast/expression.dart';
import 'ast/import_declaration.dart';
import 'ast/type_name.dart';

Future<AstNode> buildJavaAst(String filePath) async {
  Java20Lexer.checkVersion();
  Java20Parser.checkVersion();
  final input = await InputStream.fromPath(filePath);
  final lexer = Java20Lexer(input);
  final tokens = CommonTokenStream(lexer);
  final parser = Java20Parser(tokens);
  // parser.addErrorListener(DiagnosticErrorListener());
  final tree = parser.start_();
  var ast = JavaAstBuilder().visit(tree);
  if (ast == null) throw Exception("Failed to build AST");
  return ast;
}

B? mapNullable<A, B>(A? nullable, B? Function(A) function) =>
    nullable != null ? function(nullable) : null;

class JavaAstBuilder extends Java20ParserBaseVisitor<AstNode> {
  @override
  AstNode? visitStart_(Start_Context ctx) =>
      mapNullable(ctx.compilationUnit(), visitCompilationUnit);

  @override
  OrdinaryCompilationUnit visitOrdinaryCompilationUnit(
          OrdinaryCompilationUnitContext ctx) =>
      OrdinaryCompilationUnit(
          mapNullable(ctx.packageDeclaration(), visitPackageDeclaration),
          ctx
              .importDeclarations()
              .map(visitImportDeclaration)
              .whereType<ImportDeclaration>()
              .toList(),
          ctx
              .topLevelClassOrInterfaceDeclarations()
              .map(visitTopLevelClassOrInterfaceDeclaration)
              .whereType<ClassLikeDeclaration>()
              .toList());

  @override
  PackageDeclaration visitPackageDeclaration(PackageDeclarationContext ctx) =>
      PackageDeclaration(
          ctx
              .packageModifiers()
              .map(visitPackageModifier)
              .whereType<Annotation>()
              .toList(),
          TypeName(ctx.Identifiers()
              .map((tn) => tn.text)
              .whereType<String>()
              .toList()));

  @override
  Annotation? visitPackageModifier(PackageModifierContext ctx) =>
      mapNullable(ctx.annotation(), visitAnnotation);

  // TODO
  @override
  Annotation visitAnnotation(AnnotationContext ctx) => Annotation(ctx.text);

  @override
  ImportDeclaration? visitSingleTypeImportDeclaration(
          SingleTypeImportDeclarationContext ctx) =>
      mapNullable(
          ctx.typeName(),
          (typeName) => ImportDeclaration(visitTypeName(typeName),
              onDemand: false, static: false));

  @override TypeVariableTypeDescriptor visitTypeVariable(TypeVariableContext ctx) =>
      TypeVariableTypeDescriptor(visitTypeIdentifier(ctx.typeIdentifier() as TypeIdentifierContext));

  @override
  ImportDeclaration? visitTypeImportOnDemandDeclaration(
          TypeImportOnDemandDeclarationContext ctx) =>
      mapNullable(
          ctx.packageOrTypeName(),
          (typeName) => ImportDeclaration(visitPackageOrTypeName(typeName),
              onDemand: true, static: false));

  @override
  ImportDeclaration? visitSingleStaticImportDeclaration(
          SingleStaticImportDeclarationContext ctx) =>
      mapNullable(
          ctx.typeName(),
          (typeName) => ImportDeclaration(visitTypeName(typeName),
              onDemand: false, static: true));

  @override
  ImportDeclaration? visitStaticImportOnDemandDeclaration(
          StaticImportOnDemandDeclarationContext ctx) =>
      mapNullable(
          ctx.typeName(),
          (typeName) => ImportDeclaration(visitTypeName(typeName),
              onDemand: true, static: true));

  @override
  TypeName visitTypeName(TypeNameContext ctx) {
    return (mapNullable(ctx.packageName(), visitPackageName) ??
            TypeName.empty())
        .prependPart(ctx.typeIdentifier()?.Identifier()?.text);
  }

  @override
  TypeName visitPackageName(PackageNameContext ctx) => TypeName([
        ctx.Identifier()?.text,
        ...?mapNullable(ctx.packageName(), visitPackageName)?.typeNameParts
      ].whereType<String>().toList());

  @override
  TypeName visitPackageOrTypeName(PackageOrTypeNameContext ctx) => TypeName([
        ctx.Identifier()?.text,
        mapNullable(ctx.packageOrTypeName(), visitPackageOrTypeName)
      ].whereType<String>().toList());

  @override
  ClassType visitClassType(ClassTypeContext ctx) => ClassType();

  @override
  NormalClassDeclaration visitNormalClassDeclaration(
      NormalClassDeclarationContext ctx) {
    return NormalClassDeclaration(
        ctx.classModifiers().map(visitClassModifier).toList(),
        ctx.typeIdentifier()?.text ?? "<ERROR>",
        ctx
                .typeParameters()
                ?.typeParameterList()
                ?.typeParameters()
                .map(visitTypeParameter)
                .whereType<TypeParameter>()
                .toList() ??
            [],
        mapNullable(ctx.classExtends()?.classType(), visitClassType),
        ctx
                .classImplements()
                ?.interfaceTypeList()
                ?.interfaceTypes()
                .map((i) => mapNullable(i.classType(), visitClassType))
                .whereType<ClassType>()
                .toList() ??
            [],
        ctx.classPermits()?.typeNames().map(visitTypeName).toList() ?? [],
        ctx
                .classBody()
                ?.classBodyDeclarations()
                .map(visitClassBodyDeclaration)
                .whereType<ClassBodyDeclaration>()
                .toList() ??
            []);
  }

  @override
  ClassModifierType visitClassModifier(ClassModifierContext ctx) {
    var maybeAnnotation = ctx.annotation();
    return maybeAnnotation != null
        ? AnnotationClassModifier(visitAnnotation(maybeAnnotation))
        : BasicClassModifier(ClassModifier.values
            .firstWhere((element) => ctx.text == element.name));
  }

  @override
  TypeParameter visitTypeParameter(TypeParameterContext ctx) => TypeParameter(
      ctx
          .typeParameterModifiers()
          .map((tpm) => mapNullable(tpm.annotation(), visitAnnotation))
          .whereType<Annotation>()
          .toList(),
      ctx.typeIdentifier()?.Identifier()?.text ?? "<ERROR>",
      mapNullable(ctx.typeBound(), visitTypeBound));

  @override
  TypeBound visitTypeBound(TypeBoundContext ctx) => TypeBound();

  @override
  FieldDeclaration visitFieldDeclaration(FieldDeclarationContext ctx) {
    final modifiers = ctx.fieldModifiers().map(visitFieldModifier);
    final typeCtx = ctx.unannType();
    if (typeCtx == null) throw Exception("Bad field type");
    return FieldDeclaration(
        modifiers.whereType<Annotation>().toList(),
        modifiers.whereType<ModifierNode<FieldModifier>>().toList(),
        visitUnannType(typeCtx) as TypeDescriptor,
        ctx
                .variableDeclaratorList()
                ?.variableDeclarators()
                .map(visitVariableDeclarator)
                .toList() ??
            []);
  }

  @override
  VariableDeclarator visitVariableDeclarator(VariableDeclaratorContext ctx) {
    var identifier = ctx.variableDeclaratorId() as VariableDeclaratorIdContext;
    return VariableDeclarator(
        identifier.Identifier()?.text ?? '<ERROR>',
        mapNullable(identifier.dims(), visitDims),
        mapNullable(ctx.variableInitializer(),
            (vi) => vi.accept(this) as VariableInitializer));
  }

  @override
  ExpressionInitializer visitExpressionVariableInitializer(
          ExpressionVariableInitializerContext ctx) =>
      ExpressionInitializer(
          visitExpression(ctx.expression() as ExpressionContext));

  @override
  ArrayInitializer visitArrayVariableInitializer(
          ArrayVariableInitializerContext ctx) =>
      ArrayInitializer(ctx
              .arrayInitializer()
              ?.variableInitializerList()
              ?.variableInitializers()
              .map((e) => e.accept(this) as VariableInitializer)
              .toList() ??
          []);

  @override
  Expression visitExpression(ExpressionContext ctx) => Expression();

  @override
  TypeIdentifier visitTypeIdentifier(TypeIdentifierContext ctx) =>
      TypeIdentifier(ctx.Identifier()?.text ?? "<ERROR>");

  //#region Primitive types

  @override
  PrimitiveTypeDescriptor visitBooleanType(BooleanTypeContext ctx) =>
      PrimitiveTypeDescriptor(PrimitiveTypeName.jBoolean);

  @override
  PrimitiveTypeDescriptor visitByteType(ByteTypeContext ctx) =>
      PrimitiveTypeDescriptor(PrimitiveTypeName.jByte);

  @override
  PrimitiveTypeDescriptor visitShortType(ShortTypeContext ctx) =>
      PrimitiveTypeDescriptor(PrimitiveTypeName.jShort);

  @override
  PrimitiveTypeDescriptor visitIntType(IntTypeContext ctx) =>
      PrimitiveTypeDescriptor(PrimitiveTypeName.jInt);

  @override
  PrimitiveTypeDescriptor visitLongType(LongTypeContext ctx) =>
      PrimitiveTypeDescriptor(PrimitiveTypeName.jLong);

  @override
  PrimitiveTypeDescriptor visitCharType(CharTypeContext ctx) =>
      PrimitiveTypeDescriptor(PrimitiveTypeName.jChar);

  @override
  PrimitiveTypeDescriptor visitFloatType(FloatTypeContext ctx) =>
      PrimitiveTypeDescriptor(PrimitiveTypeName.jFloat);

  @override
  PrimitiveTypeDescriptor visitDoubleType(DoubleTypeContext ctx) =>
      PrimitiveTypeDescriptor(PrimitiveTypeName.jDouble);

  //#endregion

  //#region Reference type

  @override
  ClassOrInterfaceTypeDescriptor visitUnannClassOrInterfaceType(
          UnannClassOrInterfaceTypeContext ctx) =>
      ClassOrInterfaceTypeDescriptor(
          mapNullable(ctx.packageName(), visitPackageName),
          ctx.annotations().map(visitAnnotation).toList(),
          visitTypeIdentifier(ctx.typeIdentifier() as TypeIdentifierContext),
          ctx
                  .typeArguments()
                  ?.typeArgumentList()
                  ?.typeArguments()
                  .map((a) => a.accept(this))
                  .whereType<TypeArgument>()
                  .toList() ??
              [],
          null
          // TODO
          // mapNullable(ctx.uCOIT(), visitUCOIT)
          );

  @override
  ReferenceTypeArgument visitReferenceTypeArgument(
          ReferenceTypeArgumentContext ctx) =>
      ReferenceTypeArgument(
          visitReferenceType(ctx.referenceType() as ReferenceTypeContext)
              as ReferenceTypeDescriptor);

  @override
  WildcardTypeArgument visitWildcardTypeArgument(
      WildcardTypeArgumentContext ctx) {
    final wildcard = ctx.wildcard() as WildcardContext;
    return WildcardTypeArgument(
        wildcard.annotations().map(visitAnnotation).toList(),
        wildcard.wildcardBounds()?.accept(this) as WildcardBounds?);
  }

  @override
  ExtendsWildcardBounds visitExtendsWildcardBounds(
          ExtendsWildcardBoundsContext ctx) =>
      ExtendsWildcardBounds(
          visitReferenceType(ctx.referenceType() as ReferenceTypeContext)
              as ReferenceTypeDescriptor);

  @override
  SuperWildcardBounds visitSuperWildcardBounds(
          SuperWildcardBoundsContext ctx) =>
      SuperWildcardBounds(
          (visitReferenceType(ctx.referenceType() as ReferenceTypeContext))
              as ReferenceTypeDescriptor);

  @override
  TypeVariableTypeDescriptor visitUnannTypeVariable(
          UnannTypeVariableContext ctx) =>
      TypeVariableTypeDescriptor(ctx.typeIdentifier() as TypeIdentifier);

  @override
  ArrayTypeDescriptor visitUnannPrimitiveArrayType(
          UnannPrimitiveArrayTypeContext ctx) =>
      ArrayTypeDescriptor(
          ctx.unannPrimitiveType()?.accept(this) as TypeDescriptor,
          visitDims(ctx.dims() as DimsContext));

  @override
  ArrayTypeDescriptor visitUnannCoitArrayType(UnannCoitArrayTypeContext ctx) =>
      ArrayTypeDescriptor(
          ctx.unannClassOrInterfaceType()?.accept(this) as TypeDescriptor,
          visitDims(ctx.dims() as DimsContext));

  @override
  ArrayTypeDescriptor visitUnannTypeVarArrayType(
          UnannTypeVarArrayTypeContext ctx) =>
      ArrayTypeDescriptor(
          ctx.unannTypeVariable()?.accept(this) as TypeDescriptor,
          visitDims(ctx.dims() as DimsContext));

  @override
  Dimensions visitDims(DimsContext ctx) => Dimensions(
      ctx.LBRACKs().length, ctx.annotations().map(visitAnnotation).toList());

//#endregion

  @override
  AstNode? visitFieldModifier(FieldModifierContext ctx) {
    var maybeAnnotation = ctx.annotation();
    return maybeAnnotation != null
        ? visitAnnotation(maybeAnnotation)
        : ModifierNode(FieldModifier.values
            .firstWhere((element) => ctx.text == element.name));
  }

  @override
  MethodDeclaration visitMethodDeclaration(MethodDeclarationContext ctx) {
    final modifiers = ctx.methodModifiers().map(visitMethodModifier);
    final headerCtx = ctx.methodHeader() as MethodHeaderContext;
    final typeParameters = headerCtx
            .typeParameters()
            ?.typeParameterList()
            ?.typeParameters()
            .map(visitTypeParameter)
            .toList() ??
        [];
    final methodDeclaratorCtx =
        headerCtx.methodDeclarator() as MethodDeclaratorContext;
    return MethodDeclaration(
        ListNode(modifiers.whereType<Annotation>().toList()),
        ListNode(modifiers.whereType<ModifierNode<MethodModifier>>().toList()),
        ListNode(typeParameters),
        mapNullable(headerCtx.result()?.unannType(),
            (t) => visitUnannType(t) as TypeDescriptor),
        methodDeclaratorCtx.Identifier()?.text ?? "<ERROR>",
        null,
        ListNode([]),
        mapNullable(headerCtx.throwsT(), visitThrowsT) ?? ListNode([]),
        mapNullable(ctx.methodBody()?.block(), visitBlock));
  }

  @override
  ListNode<TypeDescriptor> visitThrowsT(ThrowsTContext ctx) => ListNode(ctx
          .exceptionTypeList()
          ?.exceptionTypes()
          .map(visitExceptionType)
          .whereType<TypeDescriptor>()
          .toList() ??
      []);

  @override
  Block visitBlock(BlockContext ctx) =>
      // TODO
      Block(ListNode([]));

  @override
  AstNode? visitMethodModifier(MethodModifierContext ctx) {
    var maybeAnnotation = ctx.annotation();
    return maybeAnnotation != null
        ? visitAnnotation(maybeAnnotation)
        : ModifierNode(MethodModifier.values
            .firstWhere((element) => ctx.text == element.name));
  }

  @override
  InnerClassLikeDeclaration? visitInnerClassDeclaration(
      InnerClassDeclarationContext ctx) {
    final child = visitChildren(ctx);
    return child is ClassLikeDeclaration
        ? InnerClassLikeDeclaration(child)
        : null;
  }

  @override
  InstanceInitializer visitInstanceInitializer(
          InstanceInitializerContext ctx) =>
      InstanceInitializer();

  @override
  StaticInitializer visitStaticInitializer(StaticInitializerContext ctx) =>
      StaticInitializer();

  @override
  ConstructorDeclaration visitConstructorDeclaration(
          ConstructorDeclarationContext ctx) =>
      ConstructorDeclaration();
}
