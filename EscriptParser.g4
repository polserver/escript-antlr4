parser grammar EscriptParser;

options { tokenVocab=EscriptLexer; }

@header
{
}

@parser::members
{
}

compilationUnit
    : topLevelDeclaration* unitExpression? EOF
    ;

moduleUnit
    : moduleDeclarationStatement* EOF
    ;

moduleDeclarationStatement
    : moduleFunctionDeclaration
    | constStatement
    ;

moduleFunctionDeclaration
    : IDENTIFIER '(' variableDeclarationList? ')' ';'
    ;

unitExpression
    : expression ';'?
    ;

topLevelDeclaration
    : useDeclaration
    | includeDeclaration
    | programDeclaration
    | functionDeclaration
    | statement
    ;


functionDeclaration
    : EXPORTED? FUNCTION IDENTIFIER functionParameters block ENDFUNCTION
    ;

stringIdentifier
    : STRING_LITERAL
    | IDENTIFIER
    ;

useDeclaration
    : USE stringIdentifier ';'
    ;

includeDeclaration
    : INCLUDE stringIdentifier ';'
    ;

programDeclaration
    : PROGRAM IDENTIFIER programParameters block ENDPROGRAM
    ;

// Some ignored / to-be-handled things:
//  - Labels can only come before DO, WHILE, FOR, FOREACH, REPEAT, and CASE statements.
//  - Const expression must be optimizable

// TODO maybe split these all into individual statements?
statement
    : ifStatement
    | gotoStatement
    | returnStatement
    | constStatement
    | varStatement
    | doStatement
    | whileStatement
    | exitStatement
    | declareStatement
    | breakStatement
    | continueStatement
    | forStatement
    | foreachStatement
    | repeatStatement
    | caseStatement
    | enumStatement
    | SEMI
    | statementExpression=expression ';'
    | IDENTIFIER ':' statement
    ;

ifStatement
    : IF parExpression THEN? block (ELSEIF parExpression block)* (ELSE block)? ENDIF
    ;

gotoStatement
    : GOTO IDENTIFIER ';'
    ;

returnStatement
    : RETURN expression? ';'
    ;

constStatement
    : CONST variableDeclaration ';' 
    ;

varStatement
    : VAR variableDeclarationList ';'
    ;

doStatement
    : DO block DOWHILE parExpression ';'
    ;

whileStatement
    : WHILE parExpression block ENDWHILE
    ;

exitStatement
    : EXIT ';'
    ;

declareStatement
    : DECLARE FUNCTION identifierList ';' 
    ;

breakStatement
    : BREAK IDENTIFIER? ';'
    ;

continueStatement
    : CONTINUE IDENTIFIER? ';'
    ;

forStatement
    : FOR forGroup ENDFOR
    ;

foreachStatement
    : FOREACH IDENTIFIER IN expression block ENDFOREACH
    ;

repeatStatement
    : REPEAT block UNTIL expression ';'
    ;

caseStatement
    : CASE '(' expression ')' switchBlockStatementGroup+ ENDCASE
    ;

enumStatement
    : ENUM IDENTIFIER enumList? ENDENUM
    ;

block
    : statement*
    ;

variableDeclarationInitializer
    : ':=' expression
    | ARRAY
    ;

enumList
    : enumListEntry+ ','?
    ;

enumListEntry
    : IDENTIFIER (':=' expression)? (',' enumListEntry)*
    ;

switchBlockStatementGroup
    : switchLabel+ block
    ;

switchLabel
    : (integerLiteral | IDENTIFIER | STRING_LITERAL) ':'
    | DEFAULT ':'
    ;

forGroup
    : cstyleForStatement 
    | basicForStatement
    ;

basicForStatement
    : IDENTIFIER ':=' expression TO expression block 
    ;

cstyleForStatement
    : '(' expression ';' expression ';' expression ')' block
    ;
identifierList
    : IDENTIFIER (',' identifierList)?
    ;
variableDeclarationList
    : variableDeclaration (',' variableDeclaration)*
    ;

variableDeclaration
    : IDENTIFIER variableDeclarationInitializer?
    ;

// PARAMETERS
programParameters
    : '(' programParameterList? ')'
    ;

programParameterList
    : programParameter (','? programParameter)*
    ;

programParameter
    : UNUSED IDENTIFIER
    | IDENTIFIER (':=' expression)?
    ;

functionParameters
    : '(' functionParameterList? ')'
    ;

functionParameterList
    : functionParameter (',' functionParameter)*
    ;

functionParameter
    : BYREF? IDENTIFIER (':=' expression)?
    | UNUSED IDENTIFIER
    ;

// EXPRESSIONS

scopedMethodCall
    : IDENTIFIER '::' methodCall
    ;

expression
    : primary
    | expression bop='.'
      ( IDENTIFIER
      | STRING_LITERAL
      | methodCall
      )
    | expression '[' expressionList ']'
    | methodCall
    | scopedMethodCall
    | ARRAY arrayInitializer?
    | STRUCT structInitializer?
    | DICTIONARY dictInitializer?
    | ERROR structInitializer?
    | '{' expressionList* '}'
    | '@' IDENTIFIER
    | expression postfix=('++' | '--')
    | prefix=('+'|'-'|'++'|'--') expression
    | prefix=('~'|'!'|'not') expression
    | expression bop=('*'|'/'|'%') expression
    | expression bop=('+'|'-') expression
    | expression ('<<' | '>>') expression
    | expression bop=('<=' | '>=' | '>' | '<') expression
    | expression bop=('==' | '!=' | '<>') expression
    | expression bop='&' expression
    | expression bop='^' expression
    | expression bop='|' expression
    | expression bop='in' expression
    | expression bop=('&&' | 'and') expression
    | expression bop=('||' | 'or') expression
    | <assoc=right> expression
      bop=( ':=' | '+=' | '-=' | '*=' | '/=' | '%=' | '.+' | '.-' | '.?')
      expression
    ;

primary
    : '(' expression ')'
    | literal
    | IDENTIFIER
    ;

parExpression
    : '(' expression ')'
    ;

expressionList
    : expression (',' expression)*
    ;

methodCall
    : IDENTIFIER '(' expressionList? ')'
    ;

structInitializerExpression
    : IDENTIFIER (':=' expression)?
    | STRING_LITERAL (':=' expression)?
    ;

structInitializerExpressionList
    : structInitializerExpression (',' structInitializerExpression)*
    ;

structInitializer
    : '{' structInitializerExpressionList* '}'
    ;

dictInitializerExpression
    : expression ('->' expression)?
    ;

dictInitializerExpressionList
    : dictInitializerExpression (',' dictInitializerExpression)*
    ;

dictInitializer
    : '{' dictInitializerExpressionList* '}'
    ;

arrayInitializer
    : '{' expressionList* '}'
    | '(' expressionList* ')'
    ;

// Literals

literal
    : integerLiteral
    | floatLiteral
    | CHAR_LITERAL
    | STRING_LITERAL
    | NULL_LITERAL
    ;

integerLiteral
    : DECIMAL_LITERAL
    | HEX_LITERAL
    | OCT_LITERAL
    | BINARY_LITERAL
    ;

floatLiteral
    : FLOAT_LITERAL
    | HEX_FLOAT_LITERAL
    ;
