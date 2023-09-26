%{

    #include <bits/stdc++.h>
	#include <sstream>
    #include "A6_37_translator.h"
    extern int yylex();
    void yyerror(string s);
    extern string var_type;
	vector<string> allstrings;
    // extern vector<label> label_table;
	extern int line;
    using namespace std;
%}

%union {
    char unaryOp;
    char *char_value;
    int instr_number;
    int intval;
    int num_params;
    Expression* expr;
    Statement* stat;
    symboltype* sym_type;
    sym* symp;
    Array* A;
    // int num;
    // char sym;
	Parameters* parameter_list;
}

%token <symp> IDENTIFIER 		 		
%token <intval> INTEGER_CONSTANT
%token <char_value> CHAR_CONSTANT				
%token <char_value> STRING_LITERAL 				
%token EOL
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

//to remove dangling else problem
%right "then" ELSE

//unary operator
%type <unaryOp> unary-operator

//number of parameters
%type <num_params> argument-expression-list argument-expression-listopt

//Expressions
%type <expr>
	expression
	expressionopt
	primary-expression 
	multiplicative-expression
	additive-expression
	relational-expression
	equality-expression
	logical-and-expression
	logical-or-expression
	conditional-expression
	assignment-expression
	expression-statement

//Statements
%type <stat>  
    statement
	compound-statement
	loop-statement
	block-item
	block-item-list
	block-item-listopt
	selection-statement
	iteration-statement
	jump-statement

//symbol type
%type <sym_type> pointer

//symbol
%type <symp> initializer
%type <symp> direct-declarator init-declarator declarator

//arr1s
%type <A> postfix-expression
	unary-expression

//Auxillary non-terminals M and N
%type <instr_number> M
%type <stat> N
%type <symp> identifier-aug

%type <parameter_list> parameter-declaration
				   parameter-listopt 
				   parameter-list

%%

M: %empty 
	{
		/**
		  * backpatching,stores the index of the next quad to be generated
		  * Used in various control statements
		  */
		$$ = nextinstr();
	}   
	;

F: %empty 
	{
		// rule for identifying the start of the for statement
		// loop_name = "FOR";
	}   
	;


// X: %empty 
// 	{
// 		/**
// 		  * change the current symbol pointer
// 		  * This will be used for nested block statements
// 		  */
// 		string name = ST->name+"."+loop_name+"$"+to_string(table_count); // give name for nested table
// 		table_count++; // increment the table count
// 		cout << " lookup generated X" << endl;
// 		sym* s = ST->lookup(name); // lookup the table for new entry

// 		s->nested = new symtable(name);
// 		s->nested->parent = ST;
// 		s->name = name;
// 		s->type = new symboltype("block");
// 		currSymbolPtr = s;
// 	}   
// 	;

N: %empty
	{
		/** 
		  * For backpatching, which inserts a goto 
		  * and stores the index of the next goto 
		  * statement to guard against fallthrough

		  * N->nextlist = makelist(nextinstr) we have defined nextlist for Statements
		  */
		$$ = new Statement();
		$$->nextlist=makelist(nextinstr());
		emit("goto","");
	}
	;

changetable: %empty 
	{    
		// for changing the current symbol table
		// parST = ST;                                                               // Used for changing to symbol table for a function
		if(currSymbolPtr->nested==NULL) 
		{
			changeTable(new symtable(""));	                                           // Function symbol table doesn't already exist	
		}
		else 
		{
			changeTable(currSymbolPtr ->nested);						               // Function symbol table already exists	
			// emit("func", ST->name);
		}
	}
	;

changetable_emit: %empty 
	{    
		// same as change table but also emits a function call
		// parST = ST;                                                               // Used for changing to symbol table for a function
		if(currSymbolPtr->nested==NULL) 
		{
			changeTable(new symtable(""));	                                           // Function symbol table doesn't already exist	
		}
		else 
		{
			changeTable(currSymbolPtr ->nested);						               // Function symbol table already exists	
			emit("func", ST->name);
		}
	}
	;

identifier-aug : IDENTIFIER{
	// this is used to update the type of the identifier and current symbol pointer
	$$ = $1->update(new symboltype(var_type));
	currSymbolPtr = $$;
}

// -------------------------------- 1. EXPRESSIONS ------------------------------
primary-expression:
    IDENTIFIER{
	    $$=new Expression();                                                  // create new expression and store pointer to ST entry in the location			
	    $$->loc=$1;
	    $$->type="not-boolean";
	}
|   INTEGER_CONSTANT{ 
		$$=new Expression();	
		string p=convertIntToString($1);
		$$->loc=gentemp(new symboltype("int"),p);
		emit("=",$$->loc->name,p);
	}
|   CHAR_CONSTANT{                                                                         // create new expression and store the value of the constant in a temporary
		$$=new Expression();
		$$->loc=gentemp(new symboltype("char"),$1);
		emit("=char",$$->loc->name,string($1));
	}
|   STRING_LITERAL{                                                                          // create new expression and store the value of the constant in a temporary
		$$=new Expression();
		$$->loc=gentemp(new symboltype("ptr"),$1);
		$$->loc->type->arrtype=new symboltype("char");
		emit("=str",$$->loc->name,$1);
		allstrings.push_back($1);
	}
|   ROUND_BRACKET_OPEN expression ROUND_BRACKET_CLOSE{                                                                          // simply equal to expression
		$$=$2;
	}
;

// CONSTANT:
//     INTEGER_CONSTANT 
// |   CHAR_CONSTANT 
// ;


postfix-expression:
    primary-expression{
		$$=new Array();	
		$$->Array=$1->loc;	
		$$->type=$1->loc->type;	
		$$->loc=$$->Array;
	}
|   postfix-expression SQUARE_BRACKET_OPEN expression SQUARE_BRACKET_CLOSE{ 	
		$$=new Array();
		$$->type=$1->type->arrtype;                 // type=type of element	
		$$->Array=$1->Array;                        // copy the base
		$$->loc=gentemp(new symboltype("int"));     // store computed address
		$$->atype="arr";                            //atype is arr.
		if($1->atype=="arr") 
		{			                               // if already arr, multiply the size of the sub-type of Array with the expression value and add
			sym* t=gentemp(new symboltype("int"));
			int p=computeSize($$->type);
			string str=convertIntToString(p);
			emit("*",t->name,$3->loc->name,str);
			emit("+",$$->loc->name,$1->loc->name,t->name);
		}
		else 
		{   
			            //if a 1D Array, simply calculate size
			int p=computeSize($$->type);	
			string str=convertIntToString(p);
			// printf("names are %s %s \n",$$->loc->name,$3->loc->name,str.c_str());
			emit("*",$$->loc->name,$3->loc->name,str);
		}
	}
|   postfix-expression ROUND_BRACKET_OPEN argument-expression-listopt ROUND_BRACKET_CLOSE{
		
		// globalST->lookup		
		//call the function with number of parameters from argument_expression_list_opt
		$$=new Array();	
		$$->Array=gentemp($1->type);
		string str=convertIntToString($3);
		emit("call",$$->Array->name,$1->Array->name,str);
	}
|   postfix-expression ARROW IDENTIFIER
;

argument-expression-listopt:
    argument-expression-list{
        $$ = $1;
    }
|   %empty{
        $$ = 0;
    }
;

argument-expression-list:
    assignment-expression{
		$$=1;                                      //one argument and emit param
		emit("param",$1->loc->name);	
	}
|   argument-expression-list COMMA assignment-expression{
		$$=$1+1;                                  //one more argument and emit param		 
		emit("param",$3->loc->name);
	}
;



unary-expression:
    postfix-expression{ $$=$1; /*Equate $$ and $1*/} 
|   unary-operator unary-expression{   //if it is of this type, where unary operator is involved
		$$=new Array();
		switch($1)
		{	  
			case '&':                                                  //address of something, then generate a pointer temporary and emit the quad
				$$->Array=gentemp(new symboltype("ptr"));
				$$->Array->type->arrtype=$2->Array->type; 
				emit("=&",$$->Array->name,$2->Array->name);
				break;
			case '*':
				$$->atype="ptr";
				// cout << "loc is " << $2->Array->type->arrtype << endl;
				$$->loc=gentemp($2->Array->type->arrtype);
				$$->Array=$2->Array;
				emit("=*",$$->loc->name,$2->Array->name);	
				break;
			case '+':  //unary plus, do nothing
				$$=$2;
				break;                 
			case '-':				   //unary minus, generate new temporary of the same base type and make it negative of current one
				$$->Array=gentemp(new symboltype($2->Array->type->type));
				emit("uminus",$$->Array->name,$2->Array->name);
				break;
			case '!':				//logical not, generate new temporary of the same base type and make it negative of current one
				$$->Array=gentemp(new symboltype($2->Array->type->type));
				emit("!",$$->Array->name,$2->Array->name);
				break;
		}
	}
;

unary-operator: 
    AND { $$='&'; }
|   MULTIPLY { $$='*'; }
|   PLUS { $$='+'; }
|   MINUS { $$='-'; }
|   EXCLAMATION_MARK { $$='!'; }
;

multiplicative-expression: 
    unary-expression{
		$$ = new Expression();             //generate new expression							    
		if($1->atype=="arr") 			   //if it is of type arr
		{
			$$->loc = gentemp($1->loc->type);	
			emit("=[]", $$->loc->name, $1->Array->name, $1->loc->name);     //emit with Array right
		}
		else if($1->atype=="ptr")         //if it is of type ptr
		{ 
			$$->loc = $1->loc;        //equate the locs
		}
		else
		{
			$$->loc = $1->Array;
		}
	}
|   multiplicative-expression MULTIPLY unary-expression{ 
		Expression *temp  = new Expression();             //generate new expression							    
		if($3->atype=="arr") 			   //if it is of type arr
		{
			temp->loc = gentemp($3->loc->type);	
			emit("=[]", temp->loc->name, $3->Array->name, $3->loc->name);     //emit with Array right
		}
		else if($3->atype=="ptr")         //if it is of type ptr
		{ 
			temp->loc = $3->loc;        //equate the locs
		}
		else
		{
			temp->loc = $3->Array;
		}
		//if we have multiplication
		if(!compareSymbolType($1->loc, temp->loc))         
			cout<<"Type Error in Program"<< endl;	// error
		else 								 //if types are compatible, generate new temporary and equate to the product
		{
			$$ = new Expression();	
			$$->loc = gentemp(new symboltype($1->loc->type->type));
			emit("*", $$->loc->name, $1->loc->name, temp->loc->name);
		}
	}
|   multiplicative-expression DIVIDE unary-expression{
		Expression *temp  = new Expression();             //generate new expression							    
		if($3->atype=="arr") 			   //if it is of type arr
		{
			temp->loc = gentemp($3->loc->type);	
			emit("=[]", temp->loc->name, $3->Array->name, $3->loc->name);     //emit with Array right
		}
		else if($3->atype=="ptr")         //if it is of type ptr
		{ 
			temp->loc = $3->loc;        //equate the locs
		}
		else
		{
			temp->loc = $3->Array;
		}
		//if we have division
		if(!compareSymbolType($1->loc, $3->Array)){ 
			cout << "Type Error in Program"<< endl;
		}
		else   
		{
			//if types are compatible, generate new temporary and equate to the quotient
			$$ = new Expression();
			$$->loc = gentemp(new symboltype($1->loc->type->type));
			emit("/", $$->loc->name, $1->loc->name, $3->Array->name);
		}
	}
|   multiplicative-expression MODULO unary-expression{
		Expression *temp  = new Expression();             //generate new expression							    
		if($3->atype=="arr") 			   //if it is of type arr
		{
			temp->loc = gentemp($3->loc->type);	
			emit("=[]", temp->loc->name, $3->Array->name, $3->loc->name);     //emit with Array right
		}
		else if($3->atype=="ptr")         //if it is of type ptr
		{ 
			temp->loc = $3->loc;        //equate the locs
		}
		else
		{
			temp->loc = $3->Array;
		}
		// modulo operation
		if(!compareSymbolType($1->loc, $3->Array)) cout << "Type Error in Program"<< endl;		
		else 		 
		{
			//if types are compatible, generate new temporary and equate to the quotient
			$$ = new Expression();
			$$->loc = gentemp(new symboltype($1->loc->type->type));
			emit("%", $$->loc->name, $1->loc->name, $3->Array->name);	
		}
	}
;

additive-expression:
    multiplicative-expression {$$ = $1;}
|   additive-expression PLUS multiplicative-expression{
		
		if(!compareSymbolType($1->loc, $3->loc))
			cout << "Type Error in Program"<< endl;
		else    	//if types are compatible, generate new temporary and equate to the sum
		{
			$$ = new Expression();	
			$$->loc = gentemp(new symboltype($1->loc->type->type));
			emit("+", $$->loc->name, $1->loc->name, $3->loc->name);
		}
	}
|   additive-expression MINUS multiplicative-expression{
		
		if(!compareSymbolType($1->loc, $3->loc))
			cout << "Type Error in Program"<< endl;		
		else        //if types are compatible, generate new temporary and equate to the difference
		{	
			$$ = new Expression();	
			$$->loc = gentemp(new symboltype($1->loc->type->type));
			emit("-", $$->loc->name, $1->loc->name, $3->loc->name);
		}
	}
;

relational-expression:
    additive-expression { $$=$1; }
|   relational-expression LESS_THAN additive-expression{
		if(!compareSymbolType($1->loc, $3->loc)) 
		{
			// yyerror("Type Error in Program");
		}
		else 
		{      //check compatible types									
			$$ = new Expression();
			$$->type = "bool";                         //new type is boolean
			$$->truelist = makelist(nextinstr());     //makelist for truelist and falselist
			$$->falselist = makelist(nextinstr()+1);
			emit("<", "", $1->loc->name, $3->loc->name);     //emit statement if a<b goto .. 
			emit("goto", "");	//emit statement goto ..
		}
	}
|   relational-expression GREATER_THAN additive-expression{
		// similar to above, check compatible types,make new lists and emit
		if(!compareSymbolType($1->loc, $3->loc)) 
		{
			// yyerror("Type Error in Program");
		}
		else 
		{	
			$$ = new Expression();		
			$$->type = "bool";
			$$->truelist = makelist(nextinstr());
			$$->falselist = makelist(nextinstr()+1);
			emit(">", "", $1->loc->name, $3->loc->name);
			emit("goto", "");
		}	
	}
|   relational-expression LESS_THAN_EQUAL_TO additive-expression{
        if(!compareSymbolType($1->loc, $3->loc)) 
		{
			// yyerror("Type Error in Program");
		}
		else 
		{			
			$$ = new Expression();		
			$$->type = "bool";
			$$->truelist = makelist(nextinstr());
			$$->falselist = makelist(nextinstr()+1);
			emit("<=", "test", $1->loc->name, $3->loc->name);
			emit("goto", "");
		}
    }
|   relational-expression GREATER_THAN_EQUAL_TO additive-expression{
		if(!compareSymbolType($1->loc, $3->loc))
		{
			// yyerror("Type Error in Program");
		}
		else 
		{	
			$$ = new Expression();	
			$$->type = "bool";
			$$->truelist = makelist(nextinstr());
			$$->falselist = makelist(nextinstr()+1);
			emit(">=", "", $1->loc->name, $3->loc->name);
			emit("goto", "");
		}
	}
;

equality-expression:
    relational-expression{ $$=$1; }
|   equality-expression COMPARISON relational-expression{
		if(!compareSymbolType($1->loc, $3->loc))                //check compatible types
		{
			// yyerror("Type Error in Program");
		}
		else 
		{
			convertBoolToInt($1);                  //convert bool to int		
			convertBoolToInt($3);
			$$ = new Expression();
			$$->type = "bool";
			$$->truelist = makelist(nextinstr());            //make lists for new expression
			$$->falselist = makelist(nextinstr()+1); 
			emit("==", "", $1->loc->name, $3->loc->name);      //emit if a==b goto ..
			emit("goto", "");				//emit goto ..
		}
	}
|   equality-expression NOT_EQUAL relational-expression{
		if(!compareSymbolType($1->loc, $3->loc)) 
		{
			// yyerror("Type Error in Program");
		}
		else 
		{			
			convertBoolToInt($1);
			convertBoolToInt($3);
			$$ = new Expression();                 //result is boolean
			$$->type = "bool";
			$$->truelist = makelist(nextinstr());
			$$->falselist = makelist(nextinstr()+1);
			emit("!=", "", $1->loc->name, $3->loc->name);
			emit("goto", "");
		}
	}
;

logical-and-expression:
    equality-expression {$$=$1;}
// |   logical-and-expression LOGICAL_AND M equality-expression{ 
        
// 		convertIntToBool($4);                                  //convert inclusive_or_expression int to bool	
// 		convertIntToBool($1);                                  //convert logical_and_expression to bool
// 		$$ = new Expression();                                 //make new boolean expression 
// 		$$->type = "bool";
// 		backpatch($1->truelist, $3);                           //if $1 is true, we move to $5
// 		$$->truelist = $4->truelist;                           //if $5 is also true, we get truelist for $$
// 		$$->falselist = merge($1->falselist, $4->falselist);   //merge their falselists
// 	}
	|logical-and-expression N logical-and-expression M equality-expression 
	{
		// involves back-patching
		// convert int to bool
		convertIntToBool($5);

		// convert $1 to bool and backpatch using N
		backpatch($2->nextlist, nextinstr());
		convertIntToBool($1);

		$$ = new Expression();
		$$->type = "bool";

		// standard back-patching principles
		backpatch($1->truelist, $4);
		$$->truelist = $5->truelist;
		$$->falselist = merge ($1->falselist, $5->falselist);
	}
	
;

logical-or-expression:
    logical-and-expression { $$=$1; }
// |   logical-or-expression LOGICAL_OR M logical-and-expression{ 
// 		convertIntToBool($4);			 //convert logical_and_expression int to bool	
// 		convertIntToBool($1);			 //convert logical_or_expression to bool
// 		$$ = new Expression();			 //make new boolean expression
// 		$$->type = "bool";
// 		backpatch($1->falselist, $3);		//if $1 is true, we move to $5
// 		$$->truelist = merge($1->truelist, $4->truelist);		//merge their truelists
// 		$$->falselist = $4->falselist;		 	//if $5 is also false, we get falselist for $$
// 	}
	|logical-or-expression N logical-or-expression M logical-and-expression 
	{
		// convert (if) int to bool
		convertIntToBool($5);

		// convert $1 to bool and backpatch using N
		backpatch($2->nextlist, nextinstr());
		convertIntToBool($1);

		$$ = new Expression();
		$$->type = "bool";

		// standard back-patching principles involved
		backpatch ($1->falselist, $4);
		$$->truelist = merge ($1->truelist, $5->truelist);
		$$->falselist = $5->falselist;
	}
;

conditional-expression:
    logical-or-expression { $$=$1; }
|   logical-or-expression N QUESTION_MARK M expression N COLON M conditional-expression{
		$$ = $1;
		//normal conversion method to get conditional expressions
		$$->loc = gentemp($5->loc->type);       //generate temporary for expression
		$$->loc->update($5->loc->type);
		emit("=", $$->loc->name, $9->loc->name);      //make it equal to sconditional_expression
		list<int> l = makelist(nextinstr());        //makelist next instruction
		emit("goto", "");              //prevent fallthrough
		backpatch($6->nextlist, nextinstr());        //after N, go to next instruction
		emit("=", $$->loc->name, $5->loc->name);
		list<int> m = makelist(nextinstr());         //makelist next instruction
		l = merge(l, m);						//merge the two lists
		emit("goto", "");						//prevent fallthrough
		backpatch($2->nextlist, nextinstr());   //backpatching
		convertIntToBool($1);                   //convert expression to boolean
		backpatch($1->truelist, $4);           //$1 true goes to expression
		backpatch($1->falselist, $8);          //$1 false goes to conditional_expression
		backpatch(l, nextinstr());
	}
|   ROUND_BRACKET_OPEN logical-or-expression ROUND_BRACKET_CLOSE N QUESTION_MARK M expression N COLON M conditional-expression{
		$$ = $2;
		//normal conversion method to get conditional expressions
		$$->loc = gentemp($7->loc->type);       //generate temporary for expression
		$$->loc->update($7->loc->type);
		emit("=", $$->loc->name, $11->loc->name);      //make it equal to sconditional_expression
		list<int> l = makelist(nextinstr());        //makelist next instruction
		emit("goto", "");              //prevent fallthrough
		backpatch($8->nextlist, nextinstr());        //after N, go to next instruction
		emit("=", $$->loc->name, $7->loc->name);
		list<int> m = makelist(nextinstr());         //makelist next instruction
		l = merge(l, m);						//merge the two lists
		emit("goto", "");						//prevent fallthrough
		backpatch($4->nextlist, nextinstr());   //backpatching
		convertIntToBool($2);                   //convert expression to boolean
		backpatch($2->truelist, $6);           //$1 true goes to expression
		backpatch($2->falselist, $10);          //$1 false goes to conditional_expression
		backpatch(l, nextinstr());
	}
;

assignment-expression:
    conditional-expression { $$=$1; }
|   unary-expression ASSIGN assignment-expression{
		if($1->atype=="arr")          // if type is arr, simply check if we need to convert and emit
		{
			$3->loc = convertType($3->loc, $1->type->type);
			emit("[]=", $1->Array->name, $1->loc->name, $3->loc->name);		
		}
		else if($1->atype=="ptr")     // if type is ptr, simply emit
		{
			emit("*=", $1->Array->name, $3->loc->name);	
		}
		else                              //otherwise assignment
		{
			$3->loc = convertType($3->loc, $1->Array->type->type);
			emit("=", $1->Array->name, $3->loc->name);
		}
		
		$$ = $3;
	}
;

expression:
    assignment-expression { $$=$1; }
;
expressionopt:
    expression { $$=$1; }
    |   %empty { $$=new Expression(); }
    ;

// -------------------------------- 2. DECLARATIONS ------------------------------

declaration:
    type-specifier init-declarator SEMICOLON{ 
	}
;

init-declarator:
    declarator { $$=$1; }
|   declarator ASSIGN initializer {
		if($3->val!="") $1->val=$3->val;        //get the initial value and  emit it
		emit("=", $1->name, $3->name);	
	}
;

type-specifier:
    VOID { var_type = "void"; }
|   CHAR { var_type = "char"; }
|   INT  { var_type = "int";  } 
;

declarator:
    pointer direct-declarator{
		symboltype *t = $1;
		while(t->arrtype!=NULL) t = t->arrtype;           //for multidimensional arr1s, move in depth till you get the base type
		t->arrtype = $2->type;                //add the base type 
		// $$ = $2->update($1);                  //update
		if($2->type->type == "arr"){
				$1->arrtype = $2->type->arrtype;
				$2->type->arrtype = $1;
				// $$ = $2->update();
			}
			else if( $2->type->type == "func"){
				ST->lookup("return")->update($1);
			}
			else
			{
				$$ = $2->update($1);
     		}

		}
|   direct-declarator
;
    
direct-declarator:
    IDENTIFIER{
		$1 = ST->lookup1($1->name)->update(new symboltype(var_type)); 
		$$ = $1->update(new symboltype(var_type));
		currSymbolPtr = $$;	
	}
|   IDENTIFIER SQUARE_BRACKET_OPEN INTEGER_CONSTANT SQUARE_BRACKET_CLOSE {
		$1 = ST->lookup1($1->name)->update(new symboltype("arr",new symboltype(var_type), $3));
		symboltype *t = $1 -> type;
		symboltype *prev = NULL;
		while(t->type == "arr") 
		{
			prev = t;	
			t = t->arrtype;         //keep moving recursively to base type
		}
		if(prev==NULL) 
		{
			// int temp = atoi($3->loc->val.c_str());      //get initial value
			symboltype* s = new symboltype("arr", $1->type);    
			$$ = $1->update(s);
		}
		else 
		{
			// prev->arrtype =  new symboltype("arr", t, atoi($3->loc->val.c_str()));
			// prev->arrtype =  new symboltype("arr", t, 0);
			$$ = $1->update($1->type);
		}
	}
|   identifier-aug ROUND_BRACKET_OPEN changetable parameter-listopt ROUND_BRACKET_CLOSE {
		// for(string s : $4->parameters){
		// 	cout << "param is " << s << endl;
		// }
		
		// $1 = ST->lookup($1->name)->update(new symboltype(var_type)); 
		ST->name = $1->name;	
		if($1->type->type !="void") 
		{
			// cout << "lookup generated dir declarator " << endl;
			sym *s = ST->lookup("return");         //lookup for return value	
			s->update($1->type);
		}
		$1->nested=ST;
		$1->category = "function";       
		ST->parent = globalST;
		changeTable(globalST);				// Come back to globalsymbol table
		currSymbolPtr = $$;

		// string type = "";
		// for(string s : $4->parameters){
		// 	type+=s;
		// 	type+=" X ";	
		// }
		// type += "->";
		// type+=globalST->lookup($1->name)->type->type;
		// cout << "name should be " << type << endl;
		// cout << "setting function parameters " << $1->name << endl;
		globalST->lookup($1->name)->function_parameters = $4->parameters;
		globalST->lookup($1->name)->parameter_names = $4->parameter_names;
		// for(string s : globalST->lookup($1->name)->function_parameters){
		// 	cout << s << endl;
		// }
		// globalST->lookup($1->name)->update(new symboltype(type));
	}
;

pointer:
    MULTIPLY{
        $$ = new symboltype("ptr");
    }
;

pointeropt:
	pointer
| 	%empty
;

parameter-list:
    parameter-declaration{
		$$ = $1;
	}
|   parameter-list COMMA parameter-declaration{
		$$ = new Parameters();
		$1->parameters.merge($3->parameters);
		$1->parameter_names.merge($3->parameter_names);
		$$->parameters = $1->parameters; 
		$$->parameter_names = $1->parameter_names;
	}
;

parameter-listopt:
    parameter-list{
		$$ = new Parameters();
		$$->parameters = $1->parameters;
		$$->parameter_names = $1->parameter_names;
	} 
    | %empty{
		$$ = new Parameters();
	}
    ;

parameter-declaration:
    // type-specifier pointeropt IDENTIFIEROPT
	type-specifier declarator{
		$$ = new Parameters();
		$$->parameters.push_back(printType($2->type));
		$$->parameter_names.push_back($2->name);
		$2->category = "param";
	}
|	type-specifier {
		// parameter_list* temp = new Parameters;
		$$ = new Parameters();
		$$->parameter_names.push_back("");
		$$->parameters.push_back(var_type);
	}
;

IDENTIFIEROPT:
    IDENTIFIER
| %empty
;

initializer:
    assignment-expression{
        $$ = $1->loc;
    }
;

// -------------------------------- 3. STATEMENTS ------------------------------
statement:
    compound-statement { $$=$1; }
|   expression-statement{ 
		$$=new Statement();              //create new statement with same nextlist
		$$->nextlist=$1->nextlist; 
	}
|   selection-statement { $$=$1; }
|   iteration-statement { $$=$1; }
|   jump-statement { $$=$1; }
;

loop-statement:
    expression-statement{ 
		$$=new Statement();              //create new statement with same nextlist
		$$->nextlist=$1->nextlist; 
	}
|   selection-statement { $$=$1; }
|   iteration-statement { $$=$1; }
|   jump-statement { $$=$1; }
;
compound-statement:
    // CURLY_BRACKET_OPEN X changetable block-item-listopt CURLY_BRACKET_CLOSE // CHANGED : removed X and changetable
	// {
    //     $$ = $4;
    //     changeTable(ST->parent);        //change table to parent
    // }
	CURLY_BRACKET_OPEN block-item-listopt CURLY_BRACKET_CLOSE // CHANGED : removed X and changetable
	{
        $$ = $2;
    }
;

block-item-list:
    block-item {
        $$ = $1;
    }
|   block-item-list M block-item{
        $$ = $3;
        backpatch($1->nextlist, $2);        //after $1,move to block_item via $2
    }
;

block-item-listopt:
    block-item-list { $$=$1; }
|   %empty{ $$ = new Statement(); }
;

block-item:
    declaration { $$ = new Statement(); }
|   statement { $$ = $1; }
;

expression-statement:
    expression SEMICOLON { $$=$1; }
    |  SEMICOLON { $$=new Expression(); }
;

selection-statement:
    IF ROUND_BRACKET_OPEN expression N ROUND_BRACKET_CLOSE M statement N %prec "then" {
        backpatch($4->nextlist, nextinstr());        //nextlist of N goes to nextinstr
		convertIntToBool($3);         //convert expression to bool
		$$ = new Statement();        //make new statement
		backpatch($3->truelist, $6);        //is expression is true, go to M i.e just before statement body
		list<int> temp = merge($3->falselist, $7->nextlist);   //merge falselist of expression, nextlist of statement and second N
		$$->nextlist = merge($8->nextlist, temp);
    }
|   IF ROUND_BRACKET_OPEN expression N ROUND_BRACKET_CLOSE M statement N ELSE M statement{
		backpatch($4->nextlist, nextinstr());		//nextlist of N goes to nextinstr
		convertIntToBool($3);        //convert expression to bool
		$$ = new Statement();       //make new statement
		backpatch($3->truelist, $6);    //when expression is true, go to M1 else go to M2
		backpatch($3->falselist, $10);
		list<int> temp = merge($7->nextlist, $8->nextlist);       //merge the nextlists of the statements and second N
		$$->nextlist = merge($11->nextlist,temp);	
	}
;

iteration-statement:

	FOR F ROUND_BRACKET_OPEN declaration M expression-statement M expressionopt N ROUND_BRACKET_CLOSE M loop-statement     //for loop
	{
		$$ = new Statement();		 //create new statement
		convertIntToBool($6);  //convert check expression to boolean
		backpatch($6->truelist, $11);	//if expression is true, go to M2
		backpatch($9->nextlist, $5);	//after N, go back to M1
		backpatch($12->nextlist, $7);	//statement go back to expression
		string str=convertIntToString($7);
		emit("goto", str);				//prevent fallthrough
		$$->nextlist = $6->falselist;	//move out if statement is false
	}
	| FOR F ROUND_BRACKET_OPEN expression-statement M expression-statement M expressionopt N ROUND_BRACKET_CLOSE M loop-statement     //for loop
	{
		$$ = new Statement();		 //create new statement
		convertIntToBool($6);  //convert check expression to boolean
		backpatch($6->truelist, $11);	//if expression is true, go to M2
		backpatch($9->nextlist, $5);	//after N, go back to M1
		backpatch($12->nextlist, $7);	//statement go back to expression
		string str=convertIntToString($7);
		emit("goto", str);				//prevent fallthrough
		$$->nextlist = $6->falselist;	//move out if statement is false
	}
	| FOR F ROUND_BRACKET_OPEN declaration M expression-statement M expressionopt N ROUND_BRACKET_CLOSE M CURLY_BRACKET_OPEN block-item-listopt CURLY_BRACKET_CLOSE      //for loop
	{
		$$ = new Statement();		 //create new statement
		convertIntToBool($6);  //convert check expression to boolean
		backpatch($6->truelist, $11);	//if expression is true, go to M2
		backpatch($9->nextlist, $5);	//after N, go back to M1
		backpatch($13->nextlist, $7);	//statement go back to expression
		string str=convertIntToString($7);
		emit("goto", str);				//prevent fallthrough
		$$->nextlist = $6->falselist;	//move out if statement is false
	}
	| FOR F ROUND_BRACKET_OPEN expression-statement M expression-statement M expressionopt N ROUND_BRACKET_CLOSE M CURLY_BRACKET_OPEN block-item-listopt CURLY_BRACKET_CLOSE
	{	
		$$ = new Statement();		 //create new statement
		convertIntToBool($6);  //convert check expression to boolean
		backpatch($6->truelist, $11);	//if expression is true, go to M2
		backpatch($9->nextlist, $5);	//after N, go back to M1
		backpatch($13->nextlist, $7);	//statement go back to expression
		string str=convertIntToString($7);
		emit("goto", str);				//prevent fallthrough
		$$->nextlist = $6->falselist;	//move out if statement is false
	}

;
    
jump-statement:
    RETURN expression SEMICOLON{
		$$ = new Statement();	
		emit("return",$2->loc->name);               //emit return with the name of the return value
	}
|   RETURN SEMICOLON{
        $$ = new Statement();
        emit("return","");                          // simply emit return 
    }
;

// -------------------------------- 4. TRANSLATION UNIT ------------------------------



translation-unit-list:
    translation-unit
|   translation-unit translation-unit-list 
;

translation-unit:
    function-definition 
|   declaration
;

function-definition:
    type-specifier declarator changetable_emit CURLY_BRACKET_OPEN block-item-listopt CURLY_BRACKET_CLOSE{
		emit("funcend",ST->name);
			 	
		ST->parent=globalST;
		
		
		changeTable(globalST);                     //once we come back to this at the end, change the table to global Symbol table
	}
;

declaration-list:
    declaration
|   declaration-list declaration
;

declaration-listopt:
    declaration-list
|	%empty
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

// int main() {
//     yydebug = 1;
//     yyparse();
//     return 0;
// }

void yyerror(string s){
    printf("ERROR: %s %d\n",s.c_str(),line);

    return;
}

