import 'package:java_parser/ast/type_name.dart';

import 'annotation.dart';
import 'ast.dart';
import 'class_like_declaration.dart';
import 'import_declaration.dart';

sealed class CompilationUnit extends AstNode {}

class OrdinaryCompilationUnit extends CompilationUnit {
  @override
  Iterable<AstNode> get children => [package, ...imports, ...classLikeDeclarations].whereType<AstNode>();

  final PackageDeclaration? package;
  final List<ImportDeclaration> imports;
  final List<ClassLikeDeclaration> classLikeDeclarations;

  OrdinaryCompilationUnit(this.package, this.imports, this.classLikeDeclarations);
}

class PackageDeclaration extends AstNode {
  @override Iterable<AstNode> get children => [...annotations];
  @override String? get symbolName => packageName.symbolName;

  final List<Annotation> annotations;
  final TypeName packageName;
  PackageDeclaration(this.annotations, this.packageName);
}