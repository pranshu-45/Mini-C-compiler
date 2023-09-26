%option noyywrap
%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "A4_37.tab.h"
%}

CHAR		"char"
ELSE		"else"
FOR			"for"
IF			"if"
INT 		"int"
RETURN		"return"
VOID		"void"

DIGIT               [0-9]
PUNCT               [\[\]\(\)\{\}<>=&\*\+\-/%!?:;,]|"->"|"<="|">="|"=="|"!="|"&&"|"||"
KEYWORD             (char|else|for|if|int|return|void) 
IDENTIFIER          [a-zA-Z_][a-zA-Z0-9_]*
INT_CONST           [1-9]{DIGIT}*|{DIGIT}
CHAR_CONST          '([^'\\\n]|\\['"\\?abfnrtv])*'
STR_CONST           ([^"\\\n]|\\['"\\?abfnrtv])*
MULTILINE_COMMENT   \/\*([^*]|\*[^\/])*\*\/
SINGLELINE_COMMENT  "//"(.*)
ERROR               "+"


%%
{CHAR}		return CHAR;
{ELSE}		return ELSE;
{FOR}		return FOR;
{IF}		return IF;
{INT}		return INT;
{RETURN}	return RETURN;
{VOID}		return VOID;
\n          {yylineno++;}
{IDENTIFIER}            { return IDENTIFIER;}
{INT_CONST}*            { return INTEGER_CONSTANT;}
{CHAR_CONST}            { return CHAR_CONSTANT;}
\"{STR_CONST}*\"        { return STRING_LITERAL;}

{PUNCT}                 {
                            if(!strncmp(yytext,"+",1))  {return PLUS;}
                            if(!strncmp(yytext,"-",1))  return MINUS;
                            if(!strncmp(yytext,"*",1))  return MULTIPLY;
                            if(!strncmp(yytext,"/",1))  return DIVIDE;
                            if(!strncmp(yytext,"%",1))  return MODULO;
                            if(!strncmp(yytext,"<",1))  return LESS_THAN;
                            if(!strncmp(yytext,">",1))  return GREATER_THAN;
                            if(!strncmp(yytext,"<=",2))  return LESS_THAN_EQUAL_TO;
                            if(!strncmp(yytext,">=",2))  return GREATER_THAN_EQUAL_TO;
                            if(!strncmp(yytext,"==",2))  return COMPARISON;
                            if(!strncmp(yytext,"!=",2))  return NOT_EQUAL;
                            if(!strncmp(yytext,"&&",2))  return LOGICAL_AND;
                            if(!strncmp(yytext,"||",2))  return LOGICAL_OR;
                            if(!strncmp(yytext,"!",1))  return EXCLAMATION_MARK;
                            if(!strncmp(yytext,"?",1))  return QUESTION_MARK;
                            if(!strncmp(yytext,":",1))  return COLON;
                            if(!strncmp(yytext,"&",1))  return AND;
                            if(!strncmp(yytext,"|",1))  return OR;
                            if(!strncmp(yytext,"->",2))  return ARROW;
                            if(!strncmp(yytext,"=",1))  return ASSIGN;
                            if(!strncmp(yytext,";",1))  return SEMICOLON;
                            if(!strncmp(yytext,",",1))  return COMMA;
                            if(!strncmp(yytext,"[",1))  return SQUARE_BRACKET_OPEN;
                            if(!strncmp(yytext,"]",1))  return SQUARE_BRACKET_CLOSE;
                            if(!strncmp(yytext,"{",1))  return CURLY_BRACKET_OPEN;
                            if(!strncmp(yytext,"}",1))  return CURLY_BRACKET_CLOSE;
                            if(!strncmp(yytext,"(",1))  return ROUND_BRACKET_OPEN;
                            if(!strncmp(yytext,")",1))  return ROUND_BRACKET_CLOSE;
                        }

{SINGLELINE_COMMENT}    { }
{MULTILINE_COMMENT}     { }
[\t\v\f\r ]+            {  }; 
.                       { printf("unrecognized token %s\n",yytext);}


{ERROR}             {}
<<EOF>> {return EOF;}

%%