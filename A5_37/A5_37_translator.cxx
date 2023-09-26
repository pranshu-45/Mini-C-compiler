#include "A5_37_translator.h"
#include <bits/stdc++.h>
using namespace std;
extern int yydebug;

//----------------------------------------------//
//              global variables                //
//          (Referance from the headers)        //
//----------------------------------------------//
quadArray Q;                                                                                       // Quad Array
symtable* ST;                                                                                      // Points to current symbol table
basicType bt;                                                                                      // basic types
bool debug_on;                                                                                     // bool for printing debug output
string var_type;                                                                                   // Stores latest type
symtable* globalST;                                                                                // Global Symbol Table
symtable* parST;                                                                                   // denotes the Parent of the current Symbol Table
sym* currSymbolPtr;                                                                                // points to current symbol
long long int table_count;                                                                         // count of table
string loop_name;                                                                                  // get the name of the loop
vector<label>label_table;                                                                          // table to store the labels


//-----------------------------------------------------------//
//      Implementation of the Symbol Type Class functions    //
//-----------------------------------------------------------//
symboltype::symboltype(string type,symboltype* arrtype,int width)                                  // Constructor for a symbol type
{
    (*this).type   = type;
    (*this).width  = width;
    (*this).arrtype= arrtype;
}

//--------------------------------------------------------------//
//      Implementation of the Symbol Element Class functions    //
//--------------------------------------------------------------//
sym::sym(string name, string t, symboltype* arrtype, int width) 
{
    this->name = name;
    type = new symboltype(t,arrtype,width);                                                        // Generate type of symbol
    size = computeSize(type);                                                                      // find the size from the type
    offset = 0;                                                                                    // put initial offset as 0
    val = "-";                                                                                     // no initial value
    nested = NULL;                                                                                 // no nested table
}

sym* sym::update(symboltype* t) 
{
    type=t;                                                                                        // Update the new type
    (*this).size=computeSize(t);                                                                   // new size
    return this;                                                                                   // return the same variable	
}

//------------------------------------------------------//
//      Implementation of the Label Symbol functions    //
//------------------------------------------------------//
label::label(string _name, int _addr):name(_name),addr(_addr){}

//------------------------------------------------------//
//      Implementation of the Symbol Table functions    //
//------------------------------------------------------//
symtable::symtable(string name)                                                                    // constructor for a symbol table
{
    this->parent = nullptr;
    (*this).name=name;                                                                             // Initialize the name of the symbol table
    count=0;                                                                                       // Put count of number of temporary variables as 0
}

sym* symtable::lookup(string name)                                                 // Lookup an symbol in the symbol table, whether it exists or not
{
    // cout << "lookup " << name << " " << this->name << endl;
    sym* symbol;
    list<sym>::iterator it;                                                                        // it is list iterator (pointer) for list of symbols
    it=table.begin();                                                                              // start a linear search from the first element in the table
    while(it!=table.end()) 
    {
        if(it->name==name) 
            return &(*it);                                                                         // if the name of the symbol is found in the table then return the address of the element
        it++;                                                                                      // otherwise continue the search
    }

    sym *ptr = nullptr;
    if(this->parent)ptr = this->parent->lookup(name);
	/**
	 * If the symbol has not been found 
	 * in the symbol table then craete 
	 * a new entry for the symbol table
	 * and insert in the table
	 * 
	 * Return the pointer to this 
	 * new element inserted
	 */
    if(ST == this and !ptr){
        symbol = new sym(name);
        table.push_back(*symbol);                                                                  // push the symbol into the table
        return &table.back();                                                                      // return the symbol
    } else if(ptr) return ptr;
    return nullptr;
}

sym* symtable::lookup1(string name)                                                 // Lookup an symbol in the symbol table, whether it exists or not
{
    sym* symbol;
    list<sym>::iterator it;                                                                        // it is list iterator (pointer) for list of symbols
    it=table.begin();                                                                              // start a linear search from the first element in the table
    while(it!=table.end()) 
    {
        if(it->name==name){
            return &(*it);                                                                         // if the name of the symbol is found in the table then return the address of the element
        } 
        it++;                                                                                      // otherwise continue the search
    }
    symbol = new sym(name);
    cout << "pushing back " << name << endl;
        table.push_back(*symbol);                                                                  // push the symbol into the table
        return &table.back(); 

    // sym *ptr = nullptr;
    // if(this->parent)ptr = this->parent->lookup(name);
	// /**
	//  * If the symbol has not been found 
	//  * in the symbol table then craete 
	//  * a new entry for the symbol table
	//  * and insert in the table
	//  * 
	//  * Return the pointer to this 
	//  * new element inserted
	//  */
    // if(ST == this and !ptr){
    //     symbol = new sym(name);
    //     table.push_back(*symbol);                                                                  // push the symbol into the table
    //     return &table.back();                                                                      // return the symbol
    // } else if(ptr) return ptr;
    // return nullptr;
}

void symtable::update()                                                                            // Update the symbol table and the offsets in it
{
    list<symtable*> tb;                                                                            // list of tables
    int off;
    list<sym>::iterator it;                                                                        // list iterator for elements in the symbol table
    it=table.begin();
    while(it!=table.end()) 
    {
        if(it==table.begin()) 
        {
            it->offset=0;                                                                           // initial offset should be 0
            off=it->size;
        }
        else 
        {
            it->offset=off;
            off=it->offset+it->size;                                                                 // subsequent offset is the sum of the current offset and the space occupied by the current element
        }
        if(it->nested!=NULL) 
            tb.push_back(it->nested);
        it++;
    }

    for(list<symtable*>::iterator it1 = tb.begin();it1!=tb.end();it1++){
        (*it1)->update(); // update all nested tables
    }
    // list<symtable*>::iterator it1;                                                                   // list iterator for the nested tables
    // it1=tb.begin();
    // while(it1 !=tb.end())                                                                            // recursively update all the nested tables 
    // {
    //     (*it1)->update();
    //     it1++;
    // }
}

void repeatTimes(int times, string val){
    while((times--)>0){
        cout << val ;
    }
}

// print any symbol table
void symtable::print()                                                                                
{
    int next_instr=0;                                                                                 
    list<symtable*> tb;                                                                               // list of tables
    
    repeatTimes(70,"__");                                                                             // output formatting
    cout << endl;

    cout << "Table Name: " << name ;
    repeatTimes(53-name.length()," ");
	cout << " Parent Name: ";                                                                         // table name
    if((parent==NULL)) cout<<"NULL"<<endl;                                          // If no parent for the current table print NULL  
    else cout<<parent->name<<endl;                                                  // print the name for the current table
    repeatTimes(70,"__");                                                          // Design formatting
    cout << endl;
    
	//----------- Print the headers for the table --------------
    cout<<"Name";                                                                                // Name of the entry in the symbol table
    repeatTimes(36," ");

    cout<<"Type";                                                                                // Type of the symbol table entry
    repeatTimes(16," ");

    cout<<"Initial Value";                                                                       // Initial Value of the symbol table entry
    repeatTimes(7," ");

    cout<<"Size";                                                                                // Size of the type of the symbol table entry
    repeatTimes(11, " ");

    cout<<"Offset";                                                                              // Offset for the current entry in thr symbol table
    repeatTimes(9, " ");

    cout<<"Nested"<<endl;                                                                   // Nested symbol table (if any)
    repeatTimes(100, " ");
    cout<<endl;

    for(list<sym>::iterator it=table.begin(); it!=table.end(); it++) {                                // iterate through all the elements in the symbol table and print their details
    
        cout << it->name;                                                                        // Print name of the symbol entry	
        repeatTimes(40-it->name.length()," ");

        string rec_type=printType(it->type);                                                          // Use PrintType to print type of the symbol entry
        if((this==globalST) && (it->function_parameters.size()>0)){
            string type = "";
            for(auto itr = it->function_parameters.begin();itr!=it->function_parameters.end();itr++){
                type += (*itr);
                if(next(itr,1)!=it->function_parameters.end())type+=" x ";
            }
            // for(string s : it->function_parameters){
            //     type+=s;
            //     type+=" X ";	
            // }
            type += "->";
            type+=it->type->type;
            // cout << "name should be " << type << endl;
            rec_type = type;
        }
        cout << rec_type;
        repeatTimes(20-rec_type.length()," ");

        cout << it->val;                                                                         // Print initial value of the current symbol table entry
        repeatTimes(20-it->val.length()," ");

        cout<<it->size;                                                                          // Print size of the current symbol table entry
        repeatTimes(15-to_string(it->size).length()," ");

        cout<<it->offset;                                                                        // print offset of the current symbol entry
        repeatTimes(15-to_string(it->offset).length()," ");

        if(it->nested==NULL) {                                                                        // print nested table's name if it exists
            cout<<"NULL"<<endl;
        }
        else {
            cout<<it->nested->name<<endl;	
            tb.push_back(it->nested);                                                                 // Insert the names of the nested tables that need to be recursively printed
        }
    }
    
    repeatTimes(130,"-");
    cout << endl << endl;
    for(list<symtable*>::iterator it=tb.begin(); it !=tb.end();++it) 
    {
		/**
		 * print symbol table that are nested in the 
		 * current symbol table, hence recursively 
		 * print all nested tables
		 */
        (*it)->print();
    }
}

//--------------------------------------------------//
//      Implementation of the quad functions        //
//--------------------------------------------------//

//----------------Constrtuctors overloaded----------------------

// --------- (string, string, string, string)
quad::quad(string res,string arg1,string op,string arg2)
{
	(*this).op=op;
	(*this).arg1=arg1;
	(*this).arg2=arg2;
	(*this).res=res;
}

// --------- (string, int, string, string)
quad::quad(string res,int arg1,string op,string arg2)
{	
	(*this).op=op;
	(*this).arg1=convertIntToString(arg1);
	(*this).arg2=arg2;
	(*this).res=res;	
}

//------------- Helper function to print the quads -----------------
void quad::print() 
{
    ///////////////////////////////////////
    //          BINARY OPERATORS         //
    ///////////////////////////////////////

	int next_instr=0;	
	if(op=="+") (*this).type1();
	else if(op=="-") (*this).type1();
	else if(op=="*") (*this).type1();
	else if(op=="/") (*this).type1();
	else if(op=="%") (*this).type1();
	// else if(op=="|") (*this).type1();
	// else if(op=="^") (*this).type1();
	// else if(op=="&") (*this).type1();

    ///////////////////////////////////////
    //       RELATIONAL OPERATORS        //
    ///////////////////////////////////////

	else if(op=="==") (*this).type2();
	else if(op=="!=") (*this).type2();
	else if(op=="<=") (*this).type2();
	else if(op=="<") (*this).type2();
	else if(op==">") (*this).type2();
	else if(op==">=") (*this).type2();
	else if(op=="goto") cout <<"goto "<<res;


	//----- Asignment operator --------
	else if(op=="=") cout <<res<<" = "<<arg1 ;	


	else if(op=="=&") cout <<res<<" = &"<<arg1;
	else if(op=="=*") cout <<res<<" = *"<<arg1;
	else if(op=="*=") cout <<"*"<<res<<" = "<<arg1;
	else if(op=="uminus") cout <<res<<" = -"<<arg1;
	// else if(op=="~") cout <<res<<" = ~"<<arg1;
	else if(op=="!") cout <<res<<" = !"<<arg1;

    ///////////////////////////////////////
    //         OTHER OPERATORS           //
    ///////////////////////////////////////

	else if(op=="=[]") cout <<res<<" = "<<arg1<<"["<<arg2<<"]";
	else if(op=="[]=") cout <<res<<"["<<arg1<<"]"<<" = "<< arg2;
	else if(op=="return") cout <<"return "<<res;
	else if(op=="param") cout <<"param "<<res;
	else if(op=="call") cout <<res<<" = "<<"call "<<arg1<<", "<<arg2;
	else if(op=="label") cout <<res<<": ";
	else cout <<"Can't find the operator"<<op;		
	cout <<endl;
}

void quad::type1()                                                                                    // Printing binary operators
{
    cout<<res<<" = "<<arg1<<" "<<op<<" "<<arg2;	
}

void quad::type2()                                                                                    // Printing relation operators and jumps
{
    cout<<"if "<<arg1<< " "<<op<<" "<<arg2<<" goto "<<res;	
}

//------------------------------------------------------//
//      Implementation of the Basic Type functions      //
//------------------------------------------------------//
void basicType::addType(string t, int s)                                                               // Add new trivial type to type Symbol table
{
    type.push_back(t);	
    size.push_back(s);
}

//--------------------------------------------------------------//
//        Implementation of the Quad Array Class functions      //
//--------------------------------------------------------------//
void quadArray::print()                                                                                // print the quad Array i.e the list of TAC
{
    repeatTimes(60,"__");
    cout<<endl;

    cout<<"THREE ADDRESS CODE (TAC): "<<endl;                                                       // print all the three address codes TAC
    repeatTimes(60,"__");
    cout<<endl;    
    
    int j=0;
    vector<quad>::iterator it;                                                                         // vector iterator to iterate through all the TAC in the array
    it=Array.begin();
    while(it!=Array.end()) 
    {
        // cout << "quad array " << it->op << endl;
        if(it->op=="label")                                                                             // print the label if it is the operator 
        {
            cout<<endl<<j<<": ";
            it->print();
        }
        else {                                                                                          // otherwise give 4 spaces and then print
            cout<<j<<": ";
            generateSpaces(4);
            it->print();
        }
        it++;j++;
    }
    repeatTimes(65,"__");                                                              // End of printing of the TAC
    cout<<endl;
}

//------------------------------------------------------------------//
//          Overloaded emit function used by the parser             //
//------------------------------------------------------------------//

//----------------- Emit a three address code TAC and add it to the Quad Array ------------
void emit(string op, string res, string arg1, string arg2) 
{
    // cout << "emit " << op << " " << res << " " << arg1 << " " << arg2 << endl;
	quad *q1= new quad(res,arg1,op,arg2);
	Q.Array.push_back(*q1);
}

void emit(string op, string res, int arg1, string arg2) 
{
    quad *q2= new quad(res,arg1,op,arg2);
    Q.Array.push_back(*q2);
}


/**
 * GENTEMP
 * -------
 * generates a temporary variable 
 * and insert it in the current 
 * Symbole table 
 * 
 * Parameter
 * ---------
 * symbol type * : pointer to the 
 *                 class of symbol type
 * init : initial value of the structure
 * 
 * Return
 * ------
 * Pointer to the newly created symbol 
 * table entry
 */
sym* gentemp(symboltype* t, string str_new) // generate temp variable
{   
                                                                
    string tmp_name = "t"+convertIntToString(ST->count++);                                              // generate name of temporary variable
    sym* s = new sym(tmp_name);
    s->type = t;
    s->size=computeSize(t);                                                                           // calculate the size of the current symbol
    s->val = str_new;
    ST->table.push_back(*s);                                                                            // push the newly created symbol in the Symbol table
    return &ST->table.back();
}


label* find_label(string _name){
    for(vector<label>::iterator it=label_table.begin(); it!=label_table.end(); it++){
        if(it->name==_name)return &(*it);
    }
    return nullptr;
}

//-------------------------------------------------------------//
//            Backpatching and related functions               //
//-------------------------------------------------------------//
void backpatch(list<int> list1,int addr)                                                                // backpatching
{
    string str=convertIntToString(addr);                                                                // get string form of the address
    
    for(list<int>::iterator it=list1.begin();it!=list1.end();it++){
        Q.Array[*it].res = str;
    }
}

// make a list with given initial variable
list<int> makelist(int init) 
{
    list<int> newlist(1,init);                                                                          // make a new list	
    return newlist;                                                                                     // return the newly created list
}

// merging two lists
list<int> merge(list<int> &a,list<int> &b)
{
    a.merge(b);                                                                                         // merge two existing lists
    return a;                                                                                           // return the merged list
}

//----------------------------------------------------------------------//
//          Other helper functions required for TAC generation          //
//----------------------------------------------------------------------//

//------------- Type checking and Type conversion functions -------------
string convertIntToString(int a)                                                                        // helper function to convert int to string
{
    return to_string(a);
}


Expression* convertBoolToInt(Expression* e)                                                             // Convert any Expression to bool using standard procedure
{	
	if(e->type=="bool") 
    {
        e->loc=gentemp(new symboltype("int"));                                                          // use general goto statements and standard procedure
        backpatch(e->truelist,nextinstr());
        emit("=",e->loc->name,"true");
        int p=nextinstr()+1;
        string str=convertIntToString(p);
        emit("goto",str);
        backpatch(e->falselist,nextinstr());
        emit("=",e->loc->name,"false");
    }
    return e;
}

Expression* convertIntToBool(Expression* e)                                                             // Convert any Expression to bool using standard procedure
{
    if(e->type!="bool")                
    {
        e->falselist=makelist(nextinstr());                                                             // update the falselist
        emit("==","",e->loc->name,"0");                                                                 // emit general goto statements
        e->truelist=makelist(nextinstr());                                                              // update the truelist
        emit("goto","");
    }
    return e;
}

sym* convertType(sym* s, string rettype)                                                                // convert symbol s into the required return type
{
    
    if((*s).type->type=="int")                                                                     // if type int
    {
        if(rettype=="char")                                                                        // or converting to char
        {
	        sym* temp=gentemp(new symboltype(rettype));
            emit("=",temp->name,"int2char("+(*s).name+")");
            return temp;
        }
        return s;
    }
    else if((*s).type->type=="char")                                                                    // if type char
    {
        if(rettype=="int")                                                                              // converting char to int
        {
	        sym* temp=gentemp(new symboltype(rettype));
            emit("=",temp->name,"char2int("+(*s).name+")");
            return temp;
        }
       
        return s;
    }
    return s;
}

void changeTable(symtable* newtable)                                                                    // Change current symbol table
{
    ST = newtable;
} 

bool compareSymbolType(sym*& s1,sym*& s2)                                                               // Check if the symbols have same type or not
{
    symboltype* type1=s1->type;                                                                         // get the basic type of symbol 1
    symboltype* type2=s2->type;                                                                         // get the basic type of symbol 2
    int flag=0;
    
    if(compareSymbolType(type1,type2)) return true;                                                          // check if the two types are already equal
    else if(s1=convertType(s1,type2->type)) return true;                                                     // check if one can be converted to the other then convert them
    else if(s2=convertType(s2,type1->type)) return true;                                                     // check if one can be converted to the other then convert them
    
    return false;                                                                                  // else return false
}

bool compareSymbolType(symboltype* t1,symboltype* t2)                                                   // Check if the symbol types are same or not
{
    int flag=0;
    if(t1==NULL && t2==NULL) return true;                                                                    // if both symbol types are NULL
    else if(t1==NULL || t2==NULL || t1->type!=t2->type) return false;                                         // if only one of them is NULL or if base type isn't same
    
    return compareSymbolType(t1->arrtype,t2->arrtype);                                             // otherwise check their Array type
}

//----------------------------------------------------------------------//
//           Other helper function for debugging and printing           //
//----------------------------------------------------------------------//

void generateSpaces(int n)                                                                              // Generate required number of spaces
{
    while((n--)>0) std::cout<<" ";
}

int nextinstr() 
{
    return Q.Array.size();                                                                              // next instruction will be 1+last index and lastindex=size-1. hence return size
}

int computeSize(symboltype* t)                                                                          // calculate size function
{
    // printf("type %s\n",t->type.c_str());                                                                  // print type of variable(imp for multidimensional arrays)
    if(t->type.compare("void")==0) return bt.size[1];
    else if(t->type.compare("char")==0) return bt.size[2];
    else if(t->type.compare("int")==0) return bt.size[3];
    else if(t->type.compare("ptr")==0) return bt.size[4];
    else if(t->type.compare("func")==0) return bt.size[6];
    else if(t->type.compare("arr")==0) {
        return t->width*computeSize(t->arrtype);                         // recursive for arrays (Multidimensional arrays)
    }
    else return 0;
}

string printType(symboltype* t)                                                                         // Print type of variable(imp for multidimensional arrays)
{
    if(t==NULL) return bt.type[0];
    if(t->type.compare("void")==0)	return bt.type[1];
    else if(t->type.compare("char")==0) return bt.type[2];
    else if(t->type.compare("int")==0) return bt.type[3];
    else if(t->type.compare("ptr")==0) return bt.type[4]+"("+printType(t->arrtype)+")";                 // recursive for ptr
    else if(t->type.compare("arr")==0) 
    {
        string str=convertIntToString(t->width);                                                        // recursive for arrays
        return bt.type[5]+"("+str+","+printType(t->arrtype)+")";
    }
    else if(t->type.compare("func")==0) return bt.type[6];
    else if(t->type.compare("block")==0) return bt.type[7];
    else return t->type;
}

int main()
{

    ////////////////////////////////////////
    //             BASIC TYPES            //
    ////////////////////////////////////////
    
    bt.addType("null",0);                                                                               // Add base types initially
    bt.addType("void",0);
    bt.addType("char",1);
    bt.addType("int",4);
    // bt.addType("",8);
    bt.addType("ptr",4);
    bt.addType("arr",0);
    bt.addType("func",0);
    bt.addType("block",0);

    label_table.clear();
    // yydebug = 1;
    table_count = 0;                                                                                    // count of nested table
    debug_on= 1;                                                                                        // debugging is off
    globalST=new symtable("Global");                                                                    // Global Symbol Table
    ST=globalST;
    parST=nullptr;
    loop_name = "";

    yyparse();                                                                                          // initialize parse
    globalST->update();                                                                                 // update the global Symbol Table
    std::cout<<"\n";

    Q.print();                                                                                          // print the three address codes
    globalST->print();                                                                                  // print all Symbol Tables
};
