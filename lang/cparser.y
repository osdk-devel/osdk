%{
/*
 * MIT License
 * Copyright (c) 2025 First Person
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <cstdarg>
#include <string>
#include <list>
#include <iostream>

#include "clexer.h"

using namespace std;

extern int yylex();
extern char* yytext;
extern int yylineno;
extern FILE* yyin;

void yyerror(const char* s);
void emit_asm(const char* fmt, ...);

extern list<string> assemblies;
string current_filename = "<input>";

// Symbol table
typedef struct symbol {
    char name[256];
    int offset;
    struct symbol* next;
} symbol_t;

symbol_t* symtab = nullptr;
int stack_offset = 0;
int label_counter = 0;

// Functions
void add_symbol(const char* name);
int get_symbol_offset(const char* name);
int get_new_label(void);

%}

%union {
    int num;
    char str[256];
}

%token <str> TOKEN_IDENTIFIER
%token <num> TOKEN_NUMBER

// Keywords - C89/C90
%token TOKEN_KEYWORD_AUTO TOKEN_KEYWORD_BREAK TOKEN_KEYWORD_CASE TOKEN_KEYWORD_CHAR
%token TOKEN_KEYWORD_CONST TOKEN_KEYWORD_CONTINUE TOKEN_KEYWORD_DEFAULT TOKEN_KEYWORD_DO
%token TOKEN_KEYWORD_DOUBLE TOKEN_KEYWORD_ELSE TOKEN_KEYWORD_ENUM TOKEN_KEYWORD_EXTERN
%token TOKEN_KEYWORD_FLOAT TOKEN_KEYWORD_FOR TOKEN_KEYWORD_GOTO TOKEN_KEYWORD_IF
%token TOKEN_KEYWORD_INT TOKEN_KEYWORD_LONG TOKEN_KEYWORD_REGISTER TOKEN_KEYWORD_RETURN
%token TOKEN_KEYWORD_SHORT TOKEN_KEYWORD_SIGNED TOKEN_KEYWORD_SIZEOF TOKEN_KEYWORD_STATIC
%token TOKEN_KEYWORD_STRUCT TOKEN_KEYWORD_SWITCH TOKEN_KEYWORD_TYPEDEF TOKEN_KEYWORD_UNION
%token TOKEN_KEYWORD_UNSIGNED TOKEN_KEYWORD_VOID TOKEN_KEYWORD_VOLATILE TOKEN_KEYWORD_WHILE

// Keywords - C99
%token TOKEN_KEYWORD_INLINE TOKEN_KEYWORD_RESTRICT

// Keywords - C11
%token TOKEN_KEYWORD_ALIGNAS TOKEN_KEYWORD_ALIGNOF TOKEN_KEYWORD_ATOMIC TOKEN_KEYWORD_BOOL
%token TOKEN_KEYWORD_COMPLEX TOKEN_KEYWORD_GENERIC TOKEN_KEYWORD_IMAGINARY TOKEN_KEYWORD_NORETURN
%token TOKEN_KEYWORD_STATIC_ASSERT TOKEN_KEYWORD_THREAD_LOCAL

// Operators
%token TOKEN_PLUS TOKEN_MINUS TOKEN_ASTERISK TOKEN_SLASH TOKEN_PERCENT
%token TOKEN_EQUAL TOKEN_PLUS_EQUAL TOKEN_MINUS_EQUAL TOKEN_ASTERISK_EQUAL
%token TOKEN_SLASH_EQUAL TOKEN_PERCENT_EQUAL
%token TOKEN_INCREMENT TOKEN_DECREMENT
%token TOKEN_AMPERSAND TOKEN_AMPERSAND_EQUAL TOKEN_BITWISE_OR TOKEN_BITWISE_OR_EQUAL
%token TOKEN_BITWISE_XOR TOKEN_BITWISE_XOR_EQUAL TOKEN_BITWISE_NOT
%token TOKEN_SHIFT_LEFT TOKEN_SHIFT_RIGHT TOKEN_SHIFT_LEFT_EQUAL TOKEN_SHIFT_RIGHT_EQUAL
%token TOKEN_LOGICAL_AND TOKEN_LOGICAL_OR TOKEN_LOGICAL_NOT
%token TOKEN_LESS_THAN TOKEN_GREATER_THAN TOKEN_LESS_THAN_EQUAL TOKEN_GREATER_THAN_EQUAL
%token TOKEN_EQUAL_EQUAL TOKEN_NOT_EQUAL

// Delimiters
%token TOKEN_PARENTHESIS_OPEN TOKEN_PARENTHESIS_CLOSE
%token TOKEN_BRACE_OPEN TOKEN_BRACE_CLOSE
%token TOKEN_BRACKET_OPEN TOKEN_BRACKET_CLOSE

// Punctuation
%token TOKEN_SEMICOLON TOKEN_COLON TOKEN_COMMA TOKEN_DOT TOKEN_ELLIPSIS
%token TOKEN_HASH TOKEN_ARROW TOKEN_QUESTION

// Literals
%token TOKEN_CHARACTER TOKEN_STRING

// Miscellaneous
%token TOKEN_UNKNOWN

%type <num> expression term factor
%type <str> identifier type_specifier

%left TOKEN_PLUS TOKEN_MINUS
%left TOKEN_ASTERISK TOKEN_SLASH
%right UMINUS

%%

program:
      /* empty */
    | program external_declaration
    ;

external_declaration:
      function_definition
    | declaration
    ;

function_definition:
      type_specifier identifier TOKEN_PARENTHESIS_OPEN parameter_list TOKEN_PARENTHESIS_CLOSE 
    {
        emit_asm(".%s", strcmp($2, "main") == 0 ? "start" : $2);
    }
    compound_statement
    {
        emit_asm("; end function %s", $2);
    }
    | type_specifier identifier TOKEN_PARENTHESIS_OPEN TOKEN_PARENTHESIS_CLOSE 
    {
        emit_asm(".%s", strcmp($2, "main") == 0 ? "start" : $2);
    }
    compound_statement
    {
        emit_asm("; end function %s", $2);
    }
    ;

parameter_list:
      type_specifier identifier
    | parameter_list TOKEN_COMMA type_specifier identifier
    ;

type_specifier:
      TOKEN_KEYWORD_INT { strcpy($$, "int"); }
    | TOKEN_KEYWORD_VOID { strcpy($$, "void"); }
    | TOKEN_KEYWORD_CHAR { strcpy($$, "char"); }
    | TOKEN_KEYWORD_FLOAT { strcpy($$, "float"); }
    | TOKEN_KEYWORD_DOUBLE { strcpy($$, "double"); }
    ;

statement:
      declaration
    | assignment
    | if_statement
    | while_statement
    | return_statement
    | expression_statement
    | compound_statement
    ;

compound_statement:
    TOKEN_BRACE_OPEN statements TOKEN_BRACE_CLOSE
    ;

statements:
      /* empty */
    | statements statement
    ;

declaration:
    TOKEN_KEYWORD_INT identifier TOKEN_SEMICOLON
    {
        emit_asm("; declare int %s", $2);
        add_symbol($2);
    }
    | TOKEN_KEYWORD_INT identifier TOKEN_EQUAL expression TOKEN_SEMICOLON
    {
        emit_asm("; declare int %s = expr", $2);
        add_symbol($2);
        int offset = get_symbol_offset($2);
        emit_asm("    mov [rbp - %d], rax", offset);
    }
    ;

identifier:
    TOKEN_IDENTIFIER
    {
        strcpy($$, yytext);
    }
    ;

assignment:
    identifier TOKEN_EQUAL expression TOKEN_SEMICOLON
    {
        int offset = get_symbol_offset($1);
        emit_asm("; %s = expr", $1);
        emit_asm("    mov [rbp - %d], rax", offset);
    }
    | identifier TOKEN_PLUS_EQUAL expression TOKEN_SEMICOLON
    {
        int offset = get_symbol_offset($1);
        emit_asm("; %s += expr", $1);
        emit_asm("    add [rbp - %d], rax", offset);
    }
    | identifier TOKEN_MINUS_EQUAL expression TOKEN_SEMICOLON
    {
        int offset = get_symbol_offset($1);
        emit_asm("; %s -= expr", $1);
        emit_asm("    sub [rbp - %d], rax", offset);
    }
    | identifier TOKEN_INCREMENT TOKEN_SEMICOLON
    {
        int offset = get_symbol_offset($1);
        emit_asm("; %s++", $1);
        emit_asm("    inc qword [rbp - %d]", offset);
    }
    | identifier TOKEN_DECREMENT TOKEN_SEMICOLON
    {
        int offset = get_symbol_offset($1);
        emit_asm("; %s--", $1);
        emit_asm("    dec qword [rbp - %d]", offset);
    }
    ;

expression_statement:
    expression TOKEN_SEMICOLON
    ;

expression:
    term
    | expression TOKEN_PLUS term
    {
        emit_asm("    push rax");
        emit_asm("    mov rbx, [rsp]");
        emit_asm("    add rax, rbx");
        emit_asm("    add rsp, 8");
    }
    | expression TOKEN_MINUS term
    {
        emit_asm("    push rax");
        emit_asm("    mov rbx, [rsp]");
        emit_asm("    sub rbx, rax");
        emit_asm("    mov rax, rbx");
        emit_asm("    add rsp, 8");
    }
    | expression TOKEN_ASTERISK term
    {
        emit_asm("    push rax");
        emit_asm("    mov rbx, [rsp]");
        emit_asm("    imul rax, rbx");
        emit_asm("    add rsp, 8");
    }
    | expression TOKEN_SLASH term
    {
        emit_asm("    push rax");
        emit_asm("    mov rbx, [rsp]");
        emit_asm("    mov rdx, 0");
        emit_asm("    xchg rax, rbx");
        emit_asm("    idiv rbx");
        emit_asm("    add rsp, 8");
    }
    ;

term:
    factor
    | TOKEN_PARENTHESIS_OPEN expression TOKEN_PARENTHESIS_CLOSE
    {
        $$ = $2;
    }
    ;

factor:
    TOKEN_NUMBER
    {
        emit_asm("    mov rax, %d", $1);
        $$ = $1;
    }
    | identifier
    {
        int offset = get_symbol_offset($1);
        emit_asm("    mov rax, [rbp - %d]", offset);
    }
    | TOKEN_MINUS factor %prec UMINUS
    {
        emit_asm("    neg rax");
    }
    ;

if_statement:
    TOKEN_KEYWORD_IF TOKEN_PARENTHESIS_OPEN expression TOKEN_PARENTHESIS_CLOSE statement
    {
        int label = get_new_label();
        emit_asm("    cmp rax, 0");
        emit_asm("    je .L%d_end", label);
        emit_asm(".L%d_end:", label);
    }
    | TOKEN_KEYWORD_IF TOKEN_PARENTHESIS_OPEN expression TOKEN_PARENTHESIS_CLOSE statement TOKEN_KEYWORD_ELSE statement
    {
        int lbl_else = get_new_label();
        int lbl_end = get_new_label();
        emit_asm("    cmp rax, 0");
        emit_asm("    je .L%d", lbl_else);
        emit_asm("    jmp .L%d", lbl_end);
        emit_asm(".L%d:", lbl_else);
        emit_asm(".L%d:", lbl_end);
    }
    ;

while_statement:
    TOKEN_KEYWORD_WHILE TOKEN_PARENTHESIS_OPEN expression TOKEN_PARENTHESIS_CLOSE statement
    {
        int lbl_start = get_new_label();
        int lbl_end = get_new_label();
        emit_asm(".L%d:", lbl_start);
        emit_asm("    cmp rax, 0");
        emit_asm("    je .L%d", lbl_end);
        emit_asm("    jmp .L%d", lbl_start);
        emit_asm(".L%d:", lbl_end);
    }
    ;

return_statement:
    TOKEN_KEYWORD_RETURN expression TOKEN_SEMICOLON
    {
        emit_asm("; return");
        emit_asm("    mov rsp, rbp");
        emit_asm("    pop rbp");
        emit_asm("    ret");
    }
    | TOKEN_KEYWORD_RETURN TOKEN_SEMICOLON
    {
        emit_asm("; return");
        emit_asm("    mov rsp, rbp");
        emit_asm("    pop rbp");
        emit_asm("    ret");
    }
    ;

%%

void yyerror(const char* s) {
    // Get current position in file to show context
    long current_pos = ftell(yyin);
    
    // Try to read the current line for context
    fseek(yyin, 0, SEEK_SET);
    char line_buffer[1024];
    int line_num = 1;
    string error_line = "";
    
    while (fgets(line_buffer, sizeof(line_buffer), yyin) && line_num <= yylineno) {
        if (line_num == yylineno) {
            error_line = line_buffer;
            // Remove trailing newline
            if (!error_line.empty() && error_line[error_line.length()-1] == '\n') {
                error_line.erase(error_line.length()-1);
            }
            break;
        }
        line_num++;
    }
    
    // Restore file position
    fseek(yyin, current_pos, SEEK_SET);
    
    // Print gcc-like error message
    fprintf(stderr, "\033[1m%s:%d:1: \033[31merror:\033[0m %s\n", 
            current_filename.c_str(), yylineno, s);
    
    if (!error_line.empty()) {
        fprintf(stderr, " %4d | %s\n", yylineno, error_line.c_str());
        fprintf(stderr, "      | \033[31m^\033[0m\n");
    }
    
    // Additional hint for common errors
    if (strstr(s, "syntax error")) {
        if (strstr(yytext, "void") || strstr(yytext, "main")) {
            fprintf(stderr, "\033[1mnote:\033[0m unexpected token '%s'\n", yytext);
        } else {
            fprintf(stderr, "\033[1mnote:\033[0m near token '%s'\n", yytext);
        }
    }
}

void emit_asm(const char* fmt, ...) {
    char buffer[1024];
    va_list args;
    va_start(args, fmt);
    vsnprintf(buffer, sizeof(buffer), fmt, args);
    va_end(args);

    assemblies.push_back(buffer);
}

void add_symbol(const char* name) {
    symbol_t* sym = (symbol_t*) malloc(sizeof(symbol_t));
    strcpy(sym->name, name);
    stack_offset += 8;
    sym->offset = stack_offset;
    sym->next = symtab;
    symtab = sym;
}

int get_symbol_offset(const char* name) {
    for (symbol_t* sym = symtab; sym; sym = sym->next) {
        if (strcmp(sym->name, name) == 0) return sym->offset;
    }
    fprintf(stderr, "Error: undefined variable '%s'\n", name);
    return 0;
}

int get_new_label(void) {
    return label_counter++;
}