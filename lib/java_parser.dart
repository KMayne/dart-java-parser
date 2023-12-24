import 'package:antlr4/antlr4.dart';
import 'package:java_parser/ast/class_like_declaration.dart';

import 'antlr/Java20Lexer.dart';
import 'antlr/Java20Parser.dart';
import 'antlr/Java20ParserBaseVisitor.dart';
import 'ast/annotation.dart';
import 'ast/ast.dart';
import 'ast/compilation_unit.dart';
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
              (typeName) =>
              ImportDeclaration(visitTypeName(typeName),
                  onDemand: false, static: false));

  @override
  ImportDeclaration? visitTypeImportOnDemandDeclaration(
      TypeImportOnDemandDeclarationContext ctx) =>
      mapNullable(
          ctx.packageOrTypeName(),
              (typeName) =>
              ImportDeclaration(visitPackageOrTypeName(typeName),
                  onDemand: true, static: false));

  @override
  ImportDeclaration? visitSingleStaticImportDeclaration(
      SingleStaticImportDeclarationContext ctx) =>
      mapNullable(
          ctx.typeName(),
              (typeName) =>
              ImportDeclaration(visitTypeName(typeName),
                  onDemand: false, static: true));

  @override
  ImportDeclaration? visitStaticImportOnDemandDeclaration(
      StaticImportOnDemandDeclarationContext ctx) =>
      mapNullable(
          ctx.typeName(),
              (typeName) =>
              ImportDeclaration(visitTypeName(typeName),
                  onDemand: true, static: true));

  @override
  TypeName visitTypeName(TypeNameContext ctx) {
    return (mapNullable(ctx.packageName(), visitPackageName) ??
        TypeName.empty())
        .prependPart(ctx
        .typeIdentifier()
        ?.Identifier()
        ?.text);
  }

  @override
  TypeName visitPackageName(PackageNameContext ctx) =>
      TypeName([
        ctx
            .Identifier()
            ?.text,
        ...?mapNullable(ctx.packageName(), visitPackageName)?.typeNameParts
      ].whereType<String>().toList());

  @override
  TypeName visitPackageOrTypeName(PackageOrTypeNameContext ctx) =>
      TypeName([
        ctx
            .Identifier()
            ?.text,
        mapNullable(ctx.packageOrTypeName(), visitPackageOrTypeName)
      ].whereType<String>().toList());

  @override
  ClassType visitClassType(ClassTypeContext ctx) => ClassType();

  @override
  NormalClassDeclaration visitNormalClassDeclaration(
      NormalClassDeclarationContext ctx) {
    return NormalClassDeclaration(
        ctx.classModifiers().map(visitClassModifier).toList(),
        ctx
            .typeIdentifier()
            ?.text ?? "<ERROR>",
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
        ctx.classPermits()?.typeNames().map(visitTypeName).toList() ?? []);
  }

  @override
  ClassModifierType visitClassModifier(ClassModifierContext ctx) {
    var maybeAnnotation = ctx.annotation();
    return maybeAnnotation != null
        ? AnnotationClassModifier(visitAnnotation(maybeAnnotation))
        : BasicClassModifier(
        ClassModifier.values.firstWhere((element) => ctx.text == element.name));
  }

  @override
  TypeParameter visitTypeParameter(TypeParameterContext ctx) =>
      TypeParameter(ctx.typeParameterModifiers().map((tpm) =>
          mapNullable(tpm.annotation(), visitAnnotation))
          .whereType<Annotation>()
          .toList(),
          ctx
              .typeIdentifier()
              ?.Identifier()
              ?.text ?? "<ERROR>",
          mapNullable(ctx.typeBound(), visitTypeBound)
      );

  @override
  TypeBound visitTypeBound(TypeBoundContext ctx) => TypeBound();
}
