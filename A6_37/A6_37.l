%option noyywrap
%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "A6_37_translator.h"
    #include "A6_37.tab.h"
    extern YYSTYPE yylval;
    extern int line;
    int line = 1;
%}

%option noyywrap

/* Regular Expression Definations */
LETTER          [a-zA-Z]
DIGIT           [0-9]
NON_ZERO        [1-9]
DIGIT_SEQ       {DIGIT}{DIGIT}*
ESCAPE_SEQ      "\\\'"|"\\\""|"\\\?"|"\\\\"|"\\a"|"\\b"|"\\f"|"\\n"|"\\r"|"\\t"|"\\v"
C_CHAR          [^\'\\\n]|{ESCAPE_SEQ}
S_CHAR          [^\"\\\n]|{ESCAPE_SEQ}
CHAR_SEQ        {C_CHAR}{C_CHAR}*
STRING_SEQ      {S_CHAR}{S_CHAR}*

IDENTIFIER      ({LETTER}|"_")({LETTER}|{DIGIT}|"_")*

INT_CONST       {NON_ZERO}{DIGIT}*|"0"+
CHAR_CONST      \'{CHAR_SEQ}\'

STRING          \"{STRING_SEQ}\"|\"\"
COMMENT_LINE    "//".*
COMMENT_MULTI   "/*"([^*]|\*+[^/*])*\**(\*"/")? 
WS              [ \t]
NEWLINE         [\n]

CHAR		"char"
ELSE		"else"
FOR			"for"
IF			"if"
INT 		"int"
RETURN		"return"
VOID		"void"

PUNCT               [\[\]\(\)\{\}<>=&\*\+\-/%!?:;,]|"->"|"<="|">="|"=="|"!="|"&&"|"||"


%%
{COMMENT_LINE}          { /*printf("This single line comment will be ignored by the parser\n");*/ }
{COMMENT_MULTI}         { /*printf("This multi line comment will be ignored by the parser\n");*/  }


{CHAR}		return CHAR;
{ELSE}		return ELSE;
{FOR}		return FOR;
{IF}		return IF;
{INT}		return INT;
{RETURN}	return RETURN;
{VOID}		return VOID;

{INT_CONST}             { 
	                        yylval.intval = atoi(yytext);
							return INTEGER_CONSTANT; /* Constant Rule */ 
                        }
{CHAR_CONST}            { 
	                        yylval.char_value = yytext;
							return CHAR_CONSTANT; /* Constant Rule */ 
						}

{IDENTIFIER}            { 
	                        yylval.symp = ST->lookup(yytext);
							return IDENTIFIER; /* Identifier Rule */ 
						}

{STRING}                { 
	                        yylval.char_value = yytext;
							return STRING_LITERAL; /* String-literal */ 
						}

{WS}                    { /*White-space Rule*/ }

{NEWLINE}               { line++;/* printf("\n\n============================== Parsing line %d ============================== \n\n", ++line ); */ }



{PUNCT}                 {
                            if(!strncmp(yytext,"<=",2))  return LESS_THAN_EQUAL_TO;
                            if(!strncmp(yytext,">=",2))  return GREATER_THAN_EQUAL_TO;
                            if(!strncmp(yytext,"==",2))  return COMPARISON;
                            if(!strncmp(yytext,"!=",2))  return NOT_EQUAL;
                            if(!strncmp(yytext,"&&",2))  return LOGICAL_AND;
                            if(!strncmp(yytext,"||",2))  return LOGICAL_OR;
                            if(!strncmp(yytext,"->",2))  return ARROW;
                            if(!strncmp(yytext,"+",1))  {return PLUS;}
                            if(!strncmp(yytext,"-",1))  return MINUS;
                            if(!strncmp(yytext,"*",1))  return MULTIPLY;
                            if(!strncmp(yytext,"/",1))  return DIVIDE;
                            if(!strncmp(yytext,"%",1))  return MODULO;
                            if(!strncmp(yytext,"<",1))  return LESS_THAN;
                            if(!strncmp(yytext,">",1))  return GREATER_THAN;
                            if(!strncmp(yytext,"!",1))  return EXCLAMATION_MARK;
                            if(!strncmp(yytext,"?",1))  return QUESTION_MARK;
                            if(!strncmp(yytext,":",1))  return COLON;
                            if(!strncmp(yytext,"&",1))  return AND;
                            if(!strncmp(yytext,"|",1))  return OR;
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

[\t\v\f\r ]+            {  }; 
.                       { printf("unrecognized token %s\n",yytext);}



<<EOF>> {return EOF;}

%%