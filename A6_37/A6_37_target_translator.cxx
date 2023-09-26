#include "A6_37_translator.h"
#include <iostream>
#include <cstring>
#include <string>
#include <bits/stdc++.h>

extern FILE *yyin;
extern vector<string> allstrings;
extern int yydebug;

using namespace std;

int labelCount = 0;                 // Label count in asm file
map<int, int> labelMap;             // map from quad number to label number
ofstream out;                       // asm file stream
vector<quad> Array;                 // quad Array
string asmfilename = "A6_37_quads"; // asm file name
string inputfile = "A6_37_test";    // input file name

ActivationRecord *curr_ar;
ofstream asmFile;
map<char, int> esc_to_ascii = {{'n', 10}, {'t', 9}, {'r', 13}, {'b', 8}, {'f', 12}, {'v', 11}, {'a', 7}, {'0', 0}};
map<int, map<int, string>> num_to_reg = {{1, {{1, "dil"}, {4, "edi"}, {8, "rdi"}}}, {2, {{1, "sil"}, {4, "esi"}, {8, "rsi"}}}, {3, {{1, "dl"}, {4, "edx"}, {8, "rdx"}}}, {4, {{1, "cl"}, {4, "ecx"}, {8, "rcx"}}}};

void finalBackpatch()
{
    int curPos = Q.Array.size();
    int lastExit = -1;
    for (auto it = Q.Array.rbegin(); it != Q.Array.rend(); it++)
    {
        string op = it->op;
        if (op == "funcend")
        {
            lastExit = curPos;
        }
        else if (op == "goto" or op == "==" or op == "!=" or op == "<" or op == ">" or op == "<=" or op == ">=")
        {
            if (it->res.empty())
            {
                it->res = to_string(lastExit);
            }
        }
        curPos--;
    }
}

int get_ascii(string cc)
{
    if (cc.length() == 3)
    {
        return (int)cc[1];
    }
    else
    {
        if (esc_to_ascii.find(cc[2]) != esc_to_ascii.end())
        {
            return esc_to_ascii[cc[2]];
        }
        else
        {
            return (int)cc[2];
        }
    }
}

string stack_location(string name)
{
    if (curr_ar->displacement.count(name))
        return to_string(curr_ar->displacement[name]) + "(%rbp)";
    else
        return name;
}

string find_register(string name, int number, int size)
{
    string regis = num_to_reg[number][size];
    return "%" + regis;
}

void storing_paramter(string name, int number)
{
    sym *symbol = ST->lookup(name);
    int size = symbol->size;
    string type = symbol->type->type;
    string instr = "";
    if (type == "arr")
    {
        instr = "leaq";
        size = 8;
    }
    else if (size == 1)
    {
        instr = "movb";
    }
    else if (size == 4)
    {
        instr = "movl";
    }
    else if (size == 8)
    {
        instr = "movq";
    }
    string regis = find_register(name, number, size);
    asmFile << "\t" << setw(8) << instr << stack_location(name) << ", " << regis << endl;

    // sym *symbol = ST->lookup(name);
    // int size = symbol->size;
    // string type = symbol->type->type;
    // string instr = "";
    // if (type == "arr")
    // {
    //     instr = "leaq";
    //     size = 8;
    // }
    // else if (size == 1)
    // {
    //     instr = "movb";
    // }
    // else if (size == 4)
    // {
    //     instr = "movl";
    // }
    // else if (size == 8)
    // {
    //     instr = "movq";
    // }
    // string regis = find_register(name, number, size);
    // asmFile << "\t" << setw(8) << instr << stack_location(name) << ", " << regis << endl;
}

void parameter(string name, int number)
{

    sym *symbol = ST->lookup(name);
    int size = symbol->size;
    string type = symbol->type->type;
    string instr = "";
    if (type == "arr")
    {
        instr = "movq";
        size = 8;
    }
    else if (size == 1)
    {
        instr = "movb";
    }
    else if (size == 4)
    {
        instr = "movl";
    }
    else if (size == 8)
    {
        instr = "movq";
    }
    string regis = find_register(name, number, size);
    asmFile << "\t" << setw(8) << instr << regis << ", " << stack_location(name) << endl;

    // int size = computeSize(new symboltype(name));
    // string instr = "";
    // if (printType(new symboltype(name)) == "arr")
    // {
    //     instr = "movq";
    //     size = 8;
    // }
    // else if ( size == 1)
    // {
    //     instr = "movb";
    // }
    // else if (size == 4)
    // {
    //     instr = "movl";
    // }
    // else if (size == 8)
    // {
    //     instr = "movq";
    // }
    // string regis = find_register(name, number, size);
    // asmFile << "\t" << setw(8) << instr << regis << ", " << stack_location(name) << endl;
}

// prepares the activation table for a given symtable
void computeActivationRecord(symtable *st)
{
    int param = -20;
    int local = -24;

    // iterate over the symtable
    for (list<sym>::iterator it = st->table.begin(); it != st->table.end(); it++)
    {
        // if param
        if (it->category == "param")
        {
            st->ar[it->name] = param; // assign it to be param in activation record
            param += it->size;        // add the size of the entry
        }
        else if (it->name == "return")
            continue;

        // if local
        else
        {
            st->ar[it->name] = local; // assign it to be param in activation record
            local -= it->size;        // add the size of the entry
        }
    }
}

void genasm()
{

    // ofstream asmFile;
    asmFile.open(asmfilename);
    asmFile << left;
    asmFile << "\t.file\t\"" + inputfile + "\"" << endl;
    asmFile << endl;
    asmFile << "#\t"
            << "function variables and temp are allocated on the stack:\n"
            << endl;

    for (sym symbol : globalST->table)
    {
        if (symbol.category == "function")
        {
            asmFile << "#\t" << symbol.name << endl;
            for (auto &record : symbol.nested->activationRecord->displacement)
            {
                asmFile << "#\t" << record.first << ": " << record.second << endl;
            }
        }
    }
    for (auto &record : globalST->activationRecord->displacement)
    {
        asmFile << "#\t" << record.first << ": " << record.second << endl;
    }

    asmFile << endl;

    if (allstrings.size() > 0)
    {
        asmFile << "\t.section\t.rodata" << endl;
        int i = 0;
        for (auto &stringLiteral : allstrings)
        {
            asmFile << ".LC" << i++ << ":" << endl;
            asmFile << "\t.string\t" << stringLiteral << endl;
        }
    }

    for (auto &symbol : globalST->table)
    {
        if (symbol.val.empty() && symbol.category == "global")
        {
            asmFile << "\t.comm\t" << symbol.name << "," << symbol.size << "," << symbol.size << endl;
        }
    }
    map<int, string> label_map;
    int num_of_quad = 1, labelNum = 0;
    for (auto &quad : Q.Array)
    {
        if (quad.op == "func")
        {
            label_map[num_of_quad] = ".LFB" + to_string(labelNum);
        }
        else if (quad.op == "funcend")
        {
            label_map[num_of_quad] = ".LFE" + to_string(labelNum);
            labelNum++;
        }
        num_of_quad++;
    }
    for (auto &quad : Q.Array)
    {
        if (quad.op == "goto" or quad.op == "==" or quad.op == "!=" or quad.op == "<" or quad.op == ">" or quad.op == "<=" or quad.op == ">=")
        {
            int loc = stoi(quad.res) + 1;
            if (label_map.find(loc) == label_map.end())
            {
                // asmFile << "emitting l" << endl;
                label_map[loc] = ".L" + to_string(labelNum);
                labelNum++;
            }
        }
    }

    bool txt_spc = false;
    string glb_strtemp;
    int glb_inttemp, glb_chartemp;
    string fun_label;
    stack<string> params;
    num_of_quad = 1;
    int stringcounter = 0;

    bool gotReturn = false;

    for (sym symbol : globalST->table)
    {
        if (symbol.category != "global")
        {
            continue;
        }
        if (symbol.type->type == "int")
        {
            asmFile << "\t" << setw(8) << ".globl" << symbol.name << endl;
            if (symbol.val != "-")
                asmFile << "\t" << setw(8) << ".data" << endl;
            asmFile << "\t" << setw(8) << ".align" << 4 << endl;
            asmFile << "\t" << setw(8) << ".type" << symbol.name << ", @object" << endl;
            asmFile << "\t" << setw(8) << ".size" << symbol.name << ", 4" << endl;
            asmFile << symbol.name << ":" << endl;
            if (symbol.val != "-")
            {
                asmFile << "\t" << setw(8) << ".long" << symbol.val << endl;
            }
            else
            {
                asmFile << "\t" << setw(8) << ".zero" << 4 << endl;
            }
        }
        else if (symbol.type->type == "char")
        {
            asmFile << "\t" << setw(8) << ".globl" << symbol.name << endl;
            asmFile << "\t" << setw(8) << ".data" << endl;
            asmFile << "\t" << setw(8) << ".type" << symbol.name << ", @object" << endl;
            asmFile << "\t" << setw(8) << ".size" << symbol.name << ", 1" << endl;
            asmFile << symbol.name << ":" << endl;
            asmFile << "\t" << setw(8) << ".byte" << symbol.val << endl;
        }
        else if (symbol.type->type == "ptr")
        {
            asmFile << "\t"
                    << ".section	.data.rel.local" << endl;
            asmFile << "\t" << setw(8) << ".align" << 8 << endl;
            asmFile << "\t" << setw(8) << ".type" << symbol.name << ", @object" << endl;
            asmFile << "\t" << setw(8) << ".size" << symbol.name << ", 8" << endl;
            asmFile << symbol.name << ":" << endl;
            asmFile << "\t" << setw(8) << ".quad" << symbol.val << endl;
        }
        else if (symbol.type->type == "arr")
        {

            asmFile << "\t" << setw(8) << ".globl" << symbol.name << endl;
            asmFile << "\t" << setw(8) << ".bss" << endl;
            asmFile << "\t" << setw(8) << ".align" << 32 << endl;
            asmFile << "\t" << setw(8) << ".type" << symbol.name << ", @object" << endl;
            asmFile << "\t" << setw(8) << ".size" << symbol.name << ", " << computeSize(symbol.type) << endl;
            asmFile << symbol.name << ":" << endl;
            asmFile << "\t" << setw(8) << ".zero" << computeSize(symbol.type) << endl;
        }
    }

    for (auto &quad : Q.Array)
    {
        // asmFile << "#\t" << num_of_quad << ": " << quad.op << " " << quad.arg1 << " " << quad.arg2 << " " << quad.res << endl;

        if (quad.op == "func")
        {
            if (!txt_spc)
            {
                asmFile << "\t.text" << endl;
                txt_spc = true;
            }

            ST = globalST->lookup(quad.res)->nested;
            curr_ar = ST->activationRecord;

            fun_label = label_map[num_of_quad];
            fun_label[3] = 'E';
            asmFile << "\t" << setw(8) << ".globl" << quad.res << endl;
            asmFile << "\t" << setw(8) << ".type" << quad.res << ", @function" << endl;
            asmFile << quad.res << ":" << endl;
            asmFile << label_map[num_of_quad] << ":" << endl;
            asmFile << "\t"
                    << ".cfi_startproc" << endl;
            asmFile << "\t" << setw(8) << "pushq"
                    << "%rbp" << endl;
            asmFile << "\t.cfi_def_cfa_offset 16" << endl;
            asmFile << "\t.cfi_offset 6, -16" << endl;
            asmFile << "\t" << setw(8) << "movq"
                    << "%rsp, %rbp" << endl;
            asmFile << "\t.cfi_def_cfa_register 6" << endl;
            asmFile << "\t" << setw(8) << "subq"
                    << "$" << -curr_ar->totalDisplacement << ", %rsp" << endl;

            int number = 1;
            for (auto param : globalST->lookup(ST->name)->parameter_names)
            {
                asmFile << "#inside for loop " << globalST->lookup(ST->name)->parameter_names.size() << endl;
                parameter(param, number);
                number++;
            }
            // for (auto param : ST->parameters)
            // {
            //     parameter(param, number);
            //     number++;
            // }
        }
        else if (quad.op == "funcend")
        {

            asmFile << label_map[num_of_quad] << ":" << endl;
            asmFile << "\t" << setw(8) << "movq"
                    << "%rbp, %rsp" << endl;
            asmFile << "\t" << setw(8) << "popq"
                    << "%rbp" << endl;
            asmFile << "\t"
                    << ".cfi_def_cfa 7, 8" << endl;
            asmFile << "\t"
                    << "ret" << endl;
            asmFile << "\t"
                    << ".cfi_endproc" << endl;
            asmFile << "\t" << setw(8) << ".size" << quad.res << ", .-" << quad.res << endl;

            txt_spc = false;
        }
        else
        {
            if (txt_spc)
            {
                string op = quad.op;
                string result = quad.res;
                string arg1 = quad.arg1;
                string arg2 = quad.arg2;

                if (label_map.count(num_of_quad))
                {
                    asmFile << label_map[num_of_quad] << ":" << endl;
                }

                if (op == "=")
                {
                    if (isdigit(arg1[0]))
                    {
                        // integer constant
                        asmFile << "\t" << setw(8) << "movl"
                                << "$" << arg1 << ", " << stack_location(result) << endl;
                    }
                    else if (arg1[0] == '\'')
                    {
                        // character constant
                        asmFile << "\t" << setw(8) << "movb"
                                << "$" << get_ascii(arg1) << ", " << stack_location(result) << endl;
                    }
                    else
                    {
                        int sz = ST->lookup(arg1)->size;
                        if (sz == 1)
                        {
                            asmFile << "\t" << setw(8) << "movb" << stack_location(arg1) << ", %al" << endl;
                            asmFile << "\t" << setw(8) << "movb"
                                    << "%al, " << stack_location(result) << endl;
                        }
                        else if (sz == 4)
                        {
                            asmFile << "\t" << setw(8) << "movl" << stack_location(arg1) << ", %eax" << endl;
                            asmFile << "\t" << setw(8) << "movl"
                                    << "%eax, " << stack_location(result) << endl;
                        }
                        else if (sz == 8)
                        {
                            asmFile << "\t" << setw(8) << "movq" << stack_location(arg1) << ", %rax" << endl;
                            asmFile << "\t" << setw(8) << "movq"
                                    << "%rax, " << stack_location(result) << endl;
                        }
                    }
                }
                else if (op == "=str")
                {
                    asmFile << "\t" << setw(8) << "movq"
                            << "$.LC" << stringcounter++ << ", " << stack_location(result) << endl;
                }
                else if (op == "param")
                {
                    // cout << "found operator param " << result << endl;
                    params.push(result);
                }
                else if (op == "call")
                {
                    int paramCount = stoi(arg2);
                    while (paramCount)
                    {
                        storing_paramter(params.top(), paramCount);
                        params.pop();
                        paramCount--;
                    }
                    asmFile << "\t" << setw(8) << "call" << arg1 << endl;
                    int sz = ST->lookup(result)->size;
                    if (sz == 1)
                    {
                        asmFile << "\t" << setw(8) << "movb"
                                << "%al, " << stack_location(result) << endl;
                    }
                    else if (sz == 4)
                    {
                        asmFile << "\t" << setw(8) << "movl"
                                << "%eax, " << stack_location(result) << endl;
                    }
                    else if (sz == 8)
                    {
                        asmFile << "\t" << setw(8) << "movq"
                                << "%rax, " << stack_location(result) << endl;
                    }
                }
                else if (op == "return")
                {
                    gotReturn = true;
                    if (!result.empty())
                    {
                        int sz = ST->lookup(result)->size;
                        if (sz == 1)
                        {
                            asmFile << "\t" << setw(8) << "movb" << stack_location(result) << ", %al" << endl;
                        }
                        else if (sz == 4)
                        {
                            asmFile << "\t" << setw(8) << "movl" << stack_location(result) << ", %eax" << endl;
                        }
                        else if (sz == 8)
                        {
                            asmFile << "\t" << setw(8) << "movq" << stack_location(result) << ", %rax" << endl;
                        }
                    }
                    if (quad.op != "funcend")
                        asmFile << "\t" << setw(8) << "jmp" << fun_label << endl;
                }
                else if (op == "goto")
                {
                    asmFile << "\t" << setw(8) << "jmp" << label_map[stoi(result) + 1] << endl;
                }
                else if (op == "==" or op == "!=" or op == "<" or op == "<=" or op == ">" or op == ">=")
                {
                    // check if arg1 == arg2
                    int sz = ST->lookup(arg1)->size;
                    string movins, cmpins, movreg;
                    if (sz == 1)
                    {
                        movins = "movb";
                        cmpins = "cmpb";
                        movreg = "%al";
                    }
                    else if (sz == 4)
                    {
                        movins = "movl";
                        cmpins = "cmpl";
                        movreg = "%eax";
                    }
                    else if (sz == 8)
                    {
                        movins = "movq";
                        cmpins = "cmpq";
                        movreg = "%rax";
                    }
                    asmFile << "\t" << setw(8) << movins << stack_location(arg2) << ", " << movreg << endl;
                    asmFile << "\t" << setw(8) << cmpins << movreg << ", " << stack_location(arg1) << endl;
                    if (op == "==")
                    {
                        asmFile << "\t" << setw(8) << "je" << label_map[stoi(result) + 1] << endl;
                    }
                    else if (op == "!=")
                    {
                        asmFile << "\t" << setw(8) << "jne" << label_map[stoi(result) + 1] << endl;
                    }
                    else if (op == "<")
                    {
                        asmFile << "\t" << setw(8) << "jl" << label_map[stoi(result) + 1] << endl;
                    }
                    else if (op == "<=")
                    {
                        asmFile << "\t" << setw(8) << "jle" << label_map[stoi(result) + 1] << endl;
                    }
                    else if (op == ">")
                    {
                        asmFile << "\t" << setw(8) << "jg" << label_map[stoi(result) + 1] << endl;
                    }
                    else if (op == ">=")
                    {
                        asmFile << "\t" << setw(8) << "jge" << label_map[stoi(result) + 1] << endl;
                    }
                }
                else if (op == "+")
                {
                    // result = arg1 + arg2
                    if (result == arg1)
                    {
                        // increment arg1
                        asmFile << "\t" << setw(8) << "incl" << stack_location(arg1) << endl;
                    }
                    else
                    {
                        asmFile << "\t" << setw(8) << "movl" << stack_location(arg1) << ", "
                                << "%eax" << endl;
                        asmFile << "\t" << setw(8) << "addl" << stack_location(arg2) << ", "
                                << "%eax" << endl;
                        asmFile << "\t" << setw(8) << "movl"
                                << "%eax"
                                << ", " << stack_location(result) << endl;
                    }
                }
                else if (op == "-")
                {
                    // result = arg1 - arg2
                    if (result == arg1)
                    {
                        // decrement arg1
                        asmFile << "\t" << setw(8) << "decl" << stack_location(arg1) << endl;
                    }
                    else
                    {
                        asmFile << "\t" << setw(8) << "movl" << stack_location(arg1) << ", "
                                << "%eax" << endl;
                        asmFile << "\t" << setw(8) << "subl" << stack_location(arg2) << ", "
                                << "%eax" << endl;
                        asmFile << "\t" << setw(8) << "movl"
                                << "%eax"
                                << ", " << stack_location(result) << endl;
                    }
                }
                else if (op == "*")
                {
                    // result = arg1 * arg2
                    asmFile << "\t" << setw(8) << "movl" << stack_location(arg1) << ", "
                            << "%eax" << endl;
                    if (isdigit(arg2[0]))
                    {
                        asmFile << "\t" << setw(8) << "imull"
                                << "$" + stack_location(arg2) << ", "
                                << "%eax" << endl;
                    }
                    else
                    {
                        asmFile << "\t" << setw(8) << "imull" << stack_location(arg2) << ", "
                                << "%eax" << endl;
                    }
                    asmFile << "\t" << setw(8) << "movl"
                            << "%eax"
                            << ", " << stack_location(result) << endl;
                }
                else if (op == "/")
                {
                    // result = arg1  / arg2
                    asmFile << "\t" << setw(8) << "movl" << stack_location(arg1) << ", "
                            << "%eax" << endl;
                    asmFile << "\t" << setw(8) << "cdq" << endl;
                    asmFile << "\t" << setw(8) << "idivl" << stack_location(arg2) << endl;
                    asmFile << "\t" << setw(8) << "movl"
                            << "%eax"
                            << ", " << stack_location(result) << endl;
                }
                else if (op == "%")
                {
                    // result = arg1 % arg2
                    asmFile << "\t" << setw(8) << "movl" << stack_location(arg1) << ", "
                            << "%eax" << endl;
                    asmFile << "\t" << setw(8) << "cdq" << endl;
                    asmFile << "\t" << setw(8) << "idivl" << stack_location(arg2) << endl;
                    asmFile << "\t" << setw(8) << "movl"
                            << "%edx"
                            << ", " << stack_location(result) << endl;
                }
                else if (op == "=[]")
                {
                    // result = arg1[arg2]
                    sym *symbol = ST->lookup(arg1);
                    asmFile << "\t" << setw(8) << "movl" << stack_location(arg2) << ", "
                            << "%eax" << endl;
                    // to sign-extend the value of the %eax register to the larger %rax register
                    asmFile << "\t" << setw(8) << "cltq" << endl;
                    if (symbol->category == "global")
                    {
                        asmFile << "\t" << setw(8) << "leaq" << arg1 << "(%rip) , %rdx" << endl;
                        // rip = base address, rdx = offset
                        asmFile << "\t" << setw(8) << "movl"
                                << "(%rax, %rdx)"
                                << ", "
                                << "%eax" << endl;
                    }
                    else
                    {
                        asmFile << "\t" << setw(8) << "movl" << curr_ar->displacement[arg1] << "(%rbp, %rax, 1)"
                                << ", "
                                << "%eax" << endl;
                    }
                    asmFile << "\t" << setw(8) << "movl"
                            << "%eax"
                            << ", " << stack_location(result) << endl;
                }
                else if (op == "[]=")
                {
                    sym *symbol = ST->lookup(result);
                    asmFile << "\t" << setw(8) << "movl" << stack_location(arg1) << ", "
                            << "%eax" << endl;
                    asmFile << "\t" << setw(8) << "cltq" << endl;
                    asmFile << "\t" << setw(8) << "movl" << stack_location(arg2) << ", "
                            << "%ebx" << endl;
                    if (symbol->category == "global")
                    {
                        asmFile << "\t" << setw(8) << "leaq" << result << "(%rip) , %rdx" << endl;
                        asmFile << "\t" << setw(8) << "movl"
                                << "%ebx"
                                << ", "
                                << "(%rax,%rdx)" << endl;
                    }
                    else
                    {
                        asmFile << "\t" << setw(8) << "movl"
                                << "%ebx"
                                << ", " << curr_ar->displacement[result] << "(%rbp, %rax,1)" << endl;
                    }
                }
                else if (op == "=&")
                {
                    sym *symbol = ST->lookup(arg1);
                    // result = &arg1
                    if (symbol->type->type.substr(0, 3) == "arr")
                    {
                        if (symbol->category == "global")
                        {
                            asmFile << "\t" << setw(8) << "leaq" << arg1 << "(%rip) , %rdx" << endl;
                            asmFile << "\t" << setw(8) << "leaq"
                                    << "(%rax,%rdx)"
                                    << ", "
                                    << "%rax" << endl;
                        }
                        else
                        {
                            asmFile << "\t" << setw(8) << "movl" << stack_location(arg2) << ", %eax" << endl;
                            asmFile << "\t" << setw(8) << "leaq" << to_string(curr_ar->displacement[arg1]) << "(%rax,%rbp)"
                                    << ", "
                                    << "%rax" << endl;
                        }
                        asmFile << "\t" << setw(8) << "movq"
                                << "%rax"
                                << ", " << stack_location(result) << endl;
                    }
                    else
                    {
                        asmFile << "\t" << setw(8) << "leaq" << stack_location(arg1) << ", "
                                << "%rax" << endl;
                        asmFile << "\t" << setw(8) << "movq"
                                << "%rax"
                                << ", " << stack_location(result) << endl;
                    }
                }
                else if (op == "=*")
                {
                    // result = *arg1
                    asmFile << "\t" << setw(8) << "movq" << stack_location(arg1) << ", "
                            << "%rax" << endl;
                    asmFile << "\t" << setw(8) << "movl"
                            << "(%rax)"
                            << ", "
                            << "%eax" << endl;
                    asmFile << "\t" << setw(8) << "movl"
                            << "%eax"
                            << ", " << stack_location(result) << endl;
                }
                else if (op == "=-")
                {
                    // result = -arg1
                    asmFile << "\t" << setw(8) << "movl" << stack_location(arg1) << ", "
                            << "%eax" << endl;
                    asmFile << "\t" << setw(8) << "negl"
                            << "%eax" << endl;
                    asmFile << "\t" << setw(8) << "movl"
                            << "%eax"
                            << ", " << stack_location(result) << endl;
                }
                else if (op == "*=")
                {
                    // *result = arg1
                    asmFile << "\t" << setw(8) << "movl" << stack_location(arg1) << ", "
                            << "%eax" << endl;
                    asmFile << "\t" << setw(8) << "movq" << stack_location(result) << ", "
                            << "%rbx" << endl;
                    asmFile << "\t" << setw(8) << "movl"
                            << "%eax"
                            << ", "
                            << "(%rbx)" << endl;
                }
            }
            else
            {
                currSymbolPtr = globalST->lookup(quad.res);
                // asmFile << "# looking up " << quad.res << " " << currSymbolPtr->category << endl;
                if (currSymbolPtr->category == "temporary")
                {
                    if (currSymbolPtr->type->type == "int")
                    {
                        glb_inttemp = stoi(quad.arg1);
                    }
                    else if (currSymbolPtr->type->type == "char")
                    {
                        glb_chartemp = get_ascii(quad.arg1);
                    }
                    else if (currSymbolPtr->type->type == "ptr")
                    {
                        glb_strtemp = ".LC" + quad.arg1;
                    }
                }
                else
                {
                    // if (currSymbolPtr->type->type == "int")
                    // {
                    //     asmFile << "\t" << setw(8) << ".globl" << currSymbolPtr->name << endl;
                    //     asmFile << "\t" << setw(8) << ".data" << endl;
                    //     asmFile << "\t" << setw(8) << ".align" << 4 << endl;
                    //     asmFile << "\t" << setw(8) << ".type" << currSymbolPtr->name << ", @object" << endl;
                    //     asmFile << "\t" << setw(8) << ".size" << currSymbolPtr->name << ", 4" << endl;
                    //     asmFile << currSymbolPtr->name << ":" << endl;
                    //     asmFile << "\t" << setw(8) << ".long" << glb_inttemp << endl;
                    // }
                    // else if (currSymbolPtr->type->type == "char")
                    // {
                    //     asmFile << "\t" << setw(8) << ".globl" << currSymbolPtr->name << endl;
                    //     asmFile << "\t" << setw(8) << ".data" << endl;
                    //     asmFile << "\t" << setw(8) << ".type" << currSymbolPtr->name << ", @object" << endl;
                    //     asmFile << "\t" << setw(8) << ".size" << currSymbolPtr->name << ", 1" << endl;
                    //     asmFile << currSymbolPtr->name << ":" << endl;
                    //     asmFile << "\t" << setw(8) << ".byte" << glb_chartemp << endl;
                    // }
                    // else if (currSymbolPtr->type->type == "ptr")
                    // {
                    //     asmFile << "\t"
                    //             << ".section	.data.rel.local" << endl;
                    //     asmFile << "\t" << setw(8) << ".align" << 8 << endl;
                    //     asmFile << "\t" << setw(8) << ".type" << currSymbolPtr->name << ", @object" << endl;
                    //     asmFile << "\t" << setw(8) << ".size" << currSymbolPtr->name << ", 8" << endl;
                    //     asmFile << currSymbolPtr->name << ":" << endl;
                    //     asmFile << "\t" << setw(8) << ".quad" << glb_strtemp << endl;
                    // }
                }
            }
        }

        num_of_quad++;
    }

    asmFile.close();
}

template <class T>
ostream &operator<<(ostream &os, const vector<T> &v)
{
    copy(v.begin(), v.end(), ostream_iterator<T>(os, " "));
    return os;
}

int main(int ac, char *av[])
{

    initialise_bt();
    inputfile = inputfile + string(av[ac - 1]) + string(".nc");
    asmfilename = asmfilename + string(av[ac - 1]) + string(".s");
    globalST = new symtable("Global");
    ST = globalST;
    yyin = fopen(inputfile.c_str(), "r");
    // yydebug = 1;
    yyparse();
    globalST->update();
    globalST->print();
    finalBackpatch();
    Q.print();
    // for(vector<string>::iterator it = allstrings.begin(); it!=allstrings.end(); it++) {
    // 	cout << *it << endl;
    // }
    genasm();
}