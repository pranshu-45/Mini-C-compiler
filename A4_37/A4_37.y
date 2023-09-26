%{

    #include <string.h>
	#include <stdio.h>
    extern int yylex();
    extern int yylineno;
    void yyerror(char *s);
%}

%union {
    int num;
    char sym;
}

%token EOL
%token<num> NUMBER
//%type<num> exp
%token PLUS
%token MINUS
%token MULTIPLY
%token DIVIDE
%token MODULO
%token LESS_THAN
%token GREATER_THAN
%token LESS_THAN_EQUAL_TO
%token GREATER_THAN_EQUAL_TO
%token NOT_EQUAL
%token LOGICAL_AND
%token LOGICAL_OR
%token EXCLAMATION_MARK
%token QUESTION_MARK
%token COLON
%token AND
%token OR
%token ARROW
%token ASSIGN
%token SEMICOLON
%token IDENTIFIER
%token INTEGER_CONSTANT
%token CHAR_CONSTANT
%token STRING_LITERAL
%token COMMENT
%token WHITESPACE
%token ROUND_BRACKET_OPEN
%token ROUND_BRACKET_CLOSE
%token CURLY_BRACKET_OPEN
%token CURLY_BRACKET_CLOSE
%token SQUARE_BRACKET_OPEN
%token SQUARE_BRACKET_CLOSE
%token COMMA
%token COMPARISON
%token IF
%token ELSE
%token FOR
%token RETURN
%token VOID
%token CHAR
%token INT
%start translation-unit-list
%%

// -------------------------------- 1. EXPRESSIONS ------------------------------
primary-expression:
    IDENTIFIER
|   CONSTANT
|   STRING_LITERAL
|   ROUND_BRACKET_OPEN expression ROUND_BRACKET_CLOSE
;

// TODO
CONSTANT:
    INTEGER_CONSTANT 
|   CHAR_CONSTANT 
;


postfix-expression:
    primary-expression
|   postfix-expression SQUARE_BRACKET_OPEN expression SQUARE_BRACKET_CLOSE
|   postfix-expression ROUND_BRACKET_OPEN argument-expression-listopt ROUND_BRACKET_CLOSE
|   postfix-expression ARROW IDENTIFIER
;

argument-expression-listopt:
    argument-expression-list
|
;

argument-expression-list:
    assignment-expression
|   argument-expression-list COMMA assignment-expression
;



unary-expression:
    postfix-expression
|   unary-operator unary-expression
;

unary-operator: 
    AND 
|   MULTIPLY 
|   PLUS 
|   MINUS 
|   EXCLAMATION_MARK
;

multiplicative-expression: 
    unary-expression
|   multiplicative-expression MULTIPLY unary-expression
|   multiplicative-expression DIVIDE unary-expression
|   multiplicative-expression MODULO unary-expression
;

additive-expression:
    multiplicative-expression
|   additive-expression PLUS multiplicative-expression
|   additive-expression MINUS multiplicative-expression
;

relational-expression:
    additive-expression
|   relational-expression LESS_THAN additive-expression
|   relational-expression GREATER_THAN additive-expression
|   relational-expression LESS_THAN_EQUAL_TO additive-expression
|   relational-expression GREATER_THAN_EQUAL_TO additive-expression
;

equality-expression:
    relational-expression
|   equality-expression COMPARISON relational-expression
|   equality-expression NOT_EQUAL relational-expression
;

logical-and-expression:
    equality-expression
|   logical-and-expression LOGICAL_AND equality-expression
;

logical-or-expression:
    logical-and-expression
|   logical-or-expression LOGICAL_OR logical-and-expression
;

conditional-expression:
    logical-or-expression
|   logical-or-expression QUESTION_MARK expression COLON conditional-expression
;

assignment-expression:
    conditional-expression
|   unary-expression ASSIGN assignment-expression
;

expression:
    assignment-expression
;
expressionopt:
    expression 
    |   
    ;

// -------------------------------- 2. DECLARATIONS ------------------------------

declaration:
    type-specifier init-declarator SEMICOLON
;

init-declarator:
    declarator
|   declarator ASSIGN initializer
;

type-specifier:
    VOID
|   CHAR
|   INT
;

declarator:
    pointeropt direct-declarator
;
    
direct-declarator:
    IDENTIFIER
|   IDENTIFIER SQUARE_BRACKET_OPEN INTEGER_CONSTANT SQUARE_BRACKET_CLOSE
|   IDENTIFIER ROUND_BRACKET_OPEN parameter-listopt ROUND_BRACKET_CLOSE
;

pointer:
    MULTIPLY
;

pointeropt:
    pointer
|
;

parameter-list:
    parameter-declaration
|   parameter-list COMMA parameter-declaration
;

parameter-listopt:
    parameter-list 
    |
    ;

parameter-declaration:
    type-specifier pointeropt IDENTIFIEROPT
;

IDENTIFIEROPT:
    IDENTIFIER
|
;

initializer:
    assignment-expression
;

// -------------------------------- 3. STATEMENTS ------------------------------
statement:
    compound-statement
|   expression-statement
|   selection-statement
|   iteration-statement
|   jump-statement
;

compound-statement:
    CURLY_BRACKET_OPEN block-item-listopt CURLY_BRACKET_CLOSE
;

block-item-list:
    block-item
|   block-item-list block-item
;

block-item-listopt:
    block-item-list
|   
;

block-item:
    declaration 
|   statement
;

expression-statement:
    expressionopt SEMICOLON
;

selection-statement:
    IF ROUND_BRACKET_OPEN expression ROUND_BRACKET_CLOSE statement
|   IF ROUND_BRACKET_OPEN expression ROUND_BRACKET_CLOSE statement ELSE statement
;

iteration-statement:
    FOR ROUND_BRACKET_OPEN expressionopt SEMICOLON expressionopt SEMICOLON expressionopt ROUND_BRACKET_CLOSE statement
;
    
jump-statement:
    RETURN expressionopt SEMICOLON
;

// -------------------------------- 4. TRANSLATION UNIT ------------------------------

translation-unit-list:
    translation-unit
|   translation-unit translation-unit-list
;

translation-unit:
    function-defination 
|   declaration
;

function-defination:
    type-specifier declarator compound-statement
;

declaration-list:
    declaration
|   declaration-list declaration
;

declaration-listopt:
    declaration-list
|
;


// ---------------------------------5. OLD CODE----------------------------------------

// input:
//|  line input
//;


//line: 
//    exp EOL 
//|   EOL
//;

//exp:
//    INTEGER_CONSTANT 
//|   exp PLUS exp  
//;    

%%


void yyerror(char* s){
    printf("Line %d: ERROR: %s\n",yylineno, s);

    return;
}