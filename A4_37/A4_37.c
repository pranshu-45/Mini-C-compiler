#include <stdio.h>
#include "A4_37.tab.h"

extern int yyparse();

int main(){
  yydebug =1;
  yyparse();
  return 0;
}