%{
%}

caps        [A-Z]       
small       [a-z]       
digits      [0-9]
brackets    [\[\]\(\)\{\}]
COMMENTST   "/*"
COMMENTEN   "*/"
ESCAPE_SEQUENCE				"\?"|"\\"|"\a"|"\b"|"\f"|"\n"|"\r"|"\t"|"\v"|"\\\""
ESCAPE_SEQUENCE1            {ESCAPE_SEQUENCE}|"\'"
ESCAPE_SEQUENCE2            {ESCAPE_SEQUENCE}|"\""
C_CHAR                  {ESCAPE_SEQUENCE}|[^("\'"|"\\"|"\n")]
C_CHAR_SEQUENCE              {C_CHAR}+
CHARACTER_CONSTANT			"\'"{C_CHAR_SEQUENCE}"\'"


/*STRING_LITERALS*/
S_CHAR  					{ESCAPE_SEQUENCE}|[^("\""|"\\"|"\n")]
S_CHAR_SEQUENCE				{S_CHAR}+
STRING_LITERAL 				"\""{S_CHAR_SEQUENCE}?"\""

%%

"int"                               { printf("<KEYWORD, %s >\n", yytext); /* Keyword Rule */ }
"void"                              { printf("<KEYWORD, %s >\n", yytext); /* Keyword Rule */ }
"char"                              { printf("<KEYWORD, %s >\n", yytext); /* Keyword Rule */ }
"else"|"for"|"if"|"return"          { printf("<KEYWORD, %s >\n", yytext); /* keyword rule */}

"//"(.*)                            { printf("<COMMENT, %s>\n",yytext); /*error in <>*/  /* singleline comment */}
\/\*([^*]|\*[^\/])*\*\/       { printf("<COMMENT, %s>\n",yytext); /* multiline comment */}


{STRING_LITERAL}                    {printf("<STRING_LITERAL, %.*s>\n",yyleng-2,yytext+1);}

(!|>|<|=)=                          { printf("<PUNCTUATOR, %s >\n",yytext); /* Punctuator Rule, compartor */ }
[<>+=*/%!&?-]                       { printf("<PUNCTUATOR, %s >\n",yytext); /* Punctuator Rule, punctators */ }
"&&"|"||"|"->"                      { printf("<PUNCTUATOR, %s >\n",yytext); /* Punctuator Rule, logical operators */ }
brackets                            { printf("<PUNCTUATOR, %s >\n",yytext); /* Punctuator Rule, logical operators */ }

"["|"]"|"("|")"|"{"|"}"             { printf("<PUNCTUATOR, %s >\n",yytext); /* Scope Rule, brackets */ }
[||":"|";"|","|"-"]                 { printf("<PUNCTUATOR, %s >\n",yytext); /* Scope Rule, punctuators */ }

[a-zA-Z_]*                          {printf("<IDENTIFIER, %s >\n",yytext); /* Identifier non-digit */}
[a-zA-Z_][0-9a-zA-Z_]*              {printf("<IDENTIFIER, %s >\n",yytext); /* Identifier with digit */}



([+-]?[1-9]{digits}*|"0")           {printf("<CONSTANT, %s >\n",yytext); /* constant with digit */}
"\'"{C_CHAR_SEQUENCE}"\'"           {printf("<CONSTANT, %s>\n", yytext); /* constant with digit */}
[ \n\t]                             ;    
.                                   ;
%%

int yywrap()
{
    return 1;
}
