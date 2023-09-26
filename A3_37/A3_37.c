#include <stdio.h>

extern int yylex();
extern int yylineno;
extern int yyleng;
extern char* yytext;
extern FILE* yyin;

int main(){
      // open a file handle to a particular file:
      FILE *myfile = fopen("A3_37.nc", "r");
      if (!myfile) {
            printf("I can't open the file\n");
            return -1;
      }
       // set lex to read from it instead of defaulting to STDIN:
      yyin = myfile;

      yylex();

      return 0;
}