import 'ast.dart';
import 'statement.dart';

class Block extends AstNode {
  final ListNode<BlockStatement> statements;

  @override Iterable<AstNode> get children => statements.elements;

  Block(this.statements);
}

sealed class BlockStatement extends AstNode {}
class LocalClassLikeDeclaration extends BlockStatement {}
class LocalVariableDeclaration extends BlockStatement {}

class NormalStatement extends BlockStatement {
  final Statement statement;

  NormalStatement(this.statement);
}
