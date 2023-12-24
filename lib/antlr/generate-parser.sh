#!/bin/sh

java -Xmx500M -cp "antlr-4.13.1-complete.jar:$CLASSPATH" org.antlr.v4.Tool -Dlanguage=Dart -visitor -no-listener Java20Lexer.g4
java -Xmx500M -cp "antlr-4.13.1-complete.jar:$CLASSPATH" org.antlr.v4.Tool -Dlanguage=Dart -visitor -no-listener Java20Parser.g4
