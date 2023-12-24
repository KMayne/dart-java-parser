abstract class AstNode {
  Iterable<AstNode> get children => [];
  String? get symbolName => null;

  @override
  String toString() => "$runtimeType${symbolName == null ? "" : "[$symbolName]"}";

  String toTreeString() {
    var childString = children.map((c) => c.toTreeString()).join("\n");
    return toString() + (childString.isNotEmpty ? "\n${_indentChildString(childString)}" : "");
  }

  String _indentChildString(String childString) {
    final lines = childString.split("\n");
    final lastTopLevelLine = lines.lastIndexWhere((element) => element.startsWith(RegExp("[^ ]")));
    return lines.indexed
        .map((l) => " ${l.$1 < lastTopLevelLine ? (l.$2.startsWith(" ") ? "│" : "├") : (l.$2.startsWith(" ") ? " " : "└")} ${l.$2}")
        .join("\n");
  }
}

class TodoNode extends AstNode {
  final String typeName;

  TodoNode(this.typeName);
}
