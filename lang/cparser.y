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

void yyerror(const char* s);
void emit_asm(const char* fmt, ...);

extern list<string> assemblies;

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

%token TOKEN_KEYWORD_INT TOKEN_KEYWORD_FLOAT TOKEN_KEYWORD_DOUBLE TOKEN_KEYWORD_IF TOKEN_KEYWORD_ELSE TOKEN_KEYWORD_WHILE TOKEN_KEYWORD_RETURN
%token TOKEN_KEYWORD_AUTO TOKEN_KEYWORD_BREAK TOKEN_KEYWORD_CASE TOKEN_KEYWORD_CHAR TOKEN_KEYWORD_CONST
%token TOKEN_KEYWORD_CONTINUE TOKEN_KEYWORD_DEFAULT TOKEN_KEYWORD_DO TOKEN_KEYWORD_ENUM TOKEN_KEYWORD_EXTERN
%token TOKEN_KEYWORD_FOR TOKEN_KEYWORD_GOTO TOKEN_KEYWORD_INLINE TOKEN_KEYWORD_LONG TOKEN_KEYWORD_REGISTER
%token TOKEN_KEYWORD_RESTRICT TOKEN_KEYWORD_SHORT TOKEN_KEYWORD_SIGNED TOKEN_KEYWORD_SIZEOF TOKEN_KEYWORD_STATIC
%token TOKEN_KEYWORD_STRUCT TOKEN_KEYWORD_SWITCH TOKEN_KEYWORD_TYPEDEF TOKEN_KEYWORD_UNION TOKEN_KEYWORD_UNSIGNED
%token TOKEN_KEYWORD_VOID TOKEN_KEYWORD_VOLATILE TOKEN_KEYWORD_ALIGNAS TOKEN_KEYWORD_ALIGNOF TOKEN_KEYWORD_ATOMIC
%token TOKEN_KEYWORD_BOOL TOKEN_KEYWORD_COMPLEX TOKEN_KEYWORD_GENERIC TOKEN_KEYWORD_IMAGINARY
%token TOKEN_KEYWORD_NORETURN TOKEN_KEYWORD_STATIC_ASSERT TOKEN_KEYWORD_THREAD_LOCAL
%token TOKEN_KEYWORD_BITINT TOKEN_KEYWORD_DECIMAL128 TOKEN_KEYWORD_DECIMAL32 TOKEN_KEYWORD_DECIMAL64
%token TOKEN_KEYWORD_TYPEOF TOKEN_KEYWORD_TYPEOF_UNQUAL TOKEN_KEYWORD_CONSTEXPR TOKEN_KEYWORD_NULLPTR
%token TOKEN_KEYWORD_TRUE TOKEN_KEYWORD_FALSE
%token TOKEN_PLUS TOKEN_MINUS TOKEN_ASTERISK TOKEN_SLASH TOKEN_EQUAL TOKEN_PERCENT
%token TOKEN_LESS_THAN TOKEN_GREATER_THAN TOKEN_EQUAL_EQUAL TOKEN_NOT_EQUAL
%token TOKEN_LESS_THAN_EQUAL TOKEN_GREATER_THAN_EQUAL
%token TOKEN_LOGICAL_AND TOKEN_LOGICAL_OR TOKEN_LOGICAL_NOT
%token TOKEN_AMPERSAND TOKEN_BITWISE_OR TOKEN_BITWISE_XOR TOKEN_BITWISE_NOT
%token TOKEN_SHIFT_LEFT TOKEN_SHIFT_RIGHT TOKEN_SHIFT_LEFT_EQUAL TOKEN_SHIFT_RIGHT_EQUAL
%token TOKEN_PARENTHESIS_OPEN TOKEN_PARENTHESIS_CLOSE
%token TOKEN_BRACE_OPEN TOKEN_BRACE_CLOSE TOKEN_BRACKET_OPEN TOKEN_BRACKET_CLOSE
%token TOKEN_SEMICOLON TOKEN_COMMA TOKEN_DOT TOKEN_ARROW TOKEN_COLON TOKEN_QUESTION TOKEN_HASH TOKEN_ELLIPSIS
%token TOKEN_INCREMENT TOKEN_DECREMENT
%token TOKEN_PLUS_EQUAL TOKEN_MINUS_EQUAL TOKEN_ASTERISK_EQUAL TOKEN_SLASH_EQUAL TOKEN_PERCENT_EQUAL
%token TOKEN_AMPERSAND_EQUAL TOKEN_BITWISE_OR_EQUAL TOKEN_BITWISE_XOR_EQUAL
%token TOKEN_CHARACTER TOKEN_STRING TOKEN_COMMENT TOKEN_WHITESPACE TOKEN_UNKNOWN

%type <num> expression term factor
%type <str> identifier

%left TOKEN_PLUS TOKEN_MINUS
%left TOKEN_ASTERISK TOKEN_SLASH
%right UMINUS

%%

program:
      /* empty */
    | program function_definition
    | program function_declaration
    | program statement
    ;

function_definition:
    TOKEN_KEYWORD_INT identifier TOKEN_PARENTHESIS_OPEN parameter_list TOKEN_PARENTHESIS_CLOSE 
    {
        emit_asm("section .text");
        emit_asm("    org 0x7C00");
        emit_asm("    bits 16");
        emit_asm("%s:", $2);
        emit_asm("    xor ax, ax");
        emit_asm("    mov ds, ax");
        emit_asm("    mov es, ax");
        emit_asm("    mov ss, ax");
        emit_asm("    mov sp, 0x7C00");
    }
    compound_statement
    | TOKEN_KEYWORD_INT identifier TOKEN_PARENTHESIS_OPEN TOKEN_PARENTHESIS_CLOSE 
    {
        emit_asm("section .text");
        emit_asm("    org 0x7C00");
        emit_asm("    bits 16");
        emit_asm("%s:", (strcmp($2, "main") == 0) ? "_start" : $2);
        emit_asm("    xor ax, ax");
        emit_asm("    mov ds, ax");
        emit_asm("    mov es, ax");
        emit_asm("    mov ss, ax");
        emit_asm("    mov sp, 0x7C00");
    }
    compound_statement
    ;

parameter_list:
      TOKEN_KEYWORD_INT identifier
    | parameter_list TOKEN_COMMA TOKEN_KEYWORD_INT identifier
    ;

function_declaration:
      TOKEN_KEYWORD_VOID identifier TOKEN_PARENTHESIS_OPEN TOKEN_PARENTHESIS_CLOSE TOKEN_SEMICOLON
    | TOKEN_KEYWORD_INT identifier TOKEN_PARENTHESIS_OPEN TOKEN_PARENTHESIS_CLOSE TOKEN_SEMICOLON
    | TOKEN_KEYWORD_CHAR identifier TOKEN_PARENTHESIS_OPEN TOKEN_PARENTHESIS_CLOSE TOKEN_SEMICOLON
    | TOKEN_KEYWORD_SHORT identifier TOKEN_PARENTHESIS_OPEN TOKEN_PARENTHESIS_CLOSE TOKEN_SEMICOLON
    | TOKEN_KEYWORD_LONG identifier TOKEN_PARENTHESIS_OPEN TOKEN_PARENTHESIS_CLOSE TOKEN_SEMICOLON
    | TOKEN_KEYWORD_FLOAT identifier TOKEN_PARENTHESIS_OPEN TOKEN_PARENTHESIS_CLOSE TOKEN_SEMICOLON
    | TOKEN_KEYWORD_DOUBLE identifier TOKEN_PARENTHESIS_OPEN TOKEN_PARENTHESIS_CLOSE TOKEN_SEMICOLON
    | TOKEN_KEYWORD_VOID TOKEN_ASTERISK identifier TOKEN_PARENTHESIS_OPEN TOKEN_PARENTHESIS_CLOSE TOKEN_SEMICOLON
    | TOKEN_KEYWORD_INT TOKEN_ASTERISK identifier TOKEN_PARENTHESIS_OPEN TOKEN_PARENTHESIS_CLOSE TOKEN_SEMICOLON
    | TOKEN_KEYWORD_CHAR TOKEN_ASTERISK identifier TOKEN_PARENTHESIS_OPEN TOKEN_PARENTHESIS_CLOSE TOKEN_SEMICOLON
    | TOKEN_KEYWORD_SHORT TOKEN_ASTERISK identifier TOKEN_PARENTHESIS_OPEN TOKEN_PARENTHESIS_CLOSE TOKEN_SEMICOLON
    | TOKEN_KEYWORD_LONG TOKEN_ASTERISK identifier TOKEN_PARENTHESIS_OPEN TOKEN_PARENTHESIS_CLOSE TOKEN_SEMICOLON
    | TOKEN_KEYWORD_FLOAT TOKEN_ASTERISK identifier TOKEN_PARENTHESIS_OPEN TOKEN_PARENTHESIS_CLOSE TOKEN_SEMICOLON
    | TOKEN_KEYWORD_DOUBLE TOKEN_ASTERISK identifier TOKEN_PARENTHESIS_OPEN TOKEN_PARENTHESIS_CLOSE TOKEN_SEMICOLON
    ;

statement:
      declaration
    | assignment
    | if_statement
    | while_statement
    | for_statement
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
        add_symbol($2);
        emit_asm("; %s declared (using register)", $2);
    }
    | TOKEN_KEYWORD_INT identifier TOKEN_EQUAL expression TOKEN_SEMICOLON
    {
        add_symbol($2);
        emit_asm("; %s initialized", $2);
    }
    | TOKEN_KEYWORD_CHAR identifier TOKEN_SEMICOLON
    {
        add_symbol($2);
        emit_asm("; %s declared (using register)", $2);
    }
    | TOKEN_KEYWORD_CHAR identifier TOKEN_EQUAL expression TOKEN_SEMICOLON
    {
        add_symbol($2);
        emit_asm("; %s initialized", $2);
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
        emit_asm("; %s = expr (stored in ax)", $1);
    }
    | identifier TOKEN_PLUS_EQUAL expression TOKEN_SEMICOLON
    {
        emit_asm("; %s += expr", $1);
    }
    | identifier TOKEN_MINUS_EQUAL expression TOKEN_SEMICOLON
    {
        emit_asm("; %s -= expr", $1);
    }
    | identifier TOKEN_INCREMENT TOKEN_SEMICOLON
    {
        emit_asm("; %s++", $1);
    }
    | identifier TOKEN_DECREMENT TOKEN_SEMICOLON
    {
        emit_asm("; %s--", $1);
    }
    ;

expression_statement:
    expression TOKEN_SEMICOLON
    ;

expression:
    term
    | expression TOKEN_PLUS term
    {
        emit_asm("    push ax");
        emit_asm("    pop bx");
        emit_asm("    add ax, bx");
    }
    | expression TOKEN_MINUS term
    {
        emit_asm("    push ax");
        emit_asm("    pop bx");
        emit_asm("    sub bx, ax");
        emit_asm("    mov ax, bx");
    }
    | expression TOKEN_ASTERISK term
    {
        emit_asm("    push ax");
        emit_asm("    pop bx");
        emit_asm("    imul bx");
    }
    | expression TOKEN_SLASH term
    {
        emit_asm("    push ax");
        emit_asm("    pop bx");
        emit_asm("    xor dx, dx");
        emit_asm("    xchg ax, bx");
        emit_asm("    div bx");
    }
    | expression TOKEN_LESS_THAN term
    {
        emit_asm("    push ax");
        emit_asm("    pop bx");
        emit_asm("    cmp bx, ax");
        emit_asm("    setl al");
        emit_asm("    movzx ax, al");
    }
    | expression TOKEN_GREATER_THAN term
    {
        emit_asm("    push ax");
        emit_asm("    pop bx");
        emit_asm("    cmp bx, ax");
        emit_asm("    setg al");
        emit_asm("    movzx ax, al");
    }
    | expression TOKEN_LESS_THAN_EQUAL term
    {
        emit_asm("    push ax");
        emit_asm("    pop bx");
        emit_asm("    cmp bx, ax");
        emit_asm("    setle al");
        emit_asm("    movzx ax, al");
    }
    | expression TOKEN_GREATER_THAN_EQUAL term
    {
        emit_asm("    push ax");
        emit_asm("    pop bx");
        emit_asm("    cmp bx, ax");
        emit_asm("    setge al");
        emit_asm("    movzx ax, al");
    }
    | expression TOKEN_EQUAL_EQUAL term
    {
        emit_asm("    push ax");
        emit_asm("    pop bx");
        emit_asm("    cmp bx, ax");
        emit_asm("    sete al");
        emit_asm("    movzx ax, al");
    }
    | expression TOKEN_NOT_EQUAL term
    {
        emit_asm("    push ax");
        emit_asm("    pop bx");
        emit_asm("    cmp bx, ax");
        emit_asm("    setne al");
        emit_asm("    movzx ax, al");
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
        emit_asm("    mov ax, %d", $1);
        $$ = $1;
    }
    | identifier
    {
        emit_asm("; loading variable %s", $1);
        emit_asm("    xor ax, ax");
    }
    | TOKEN_MINUS factor %prec UMINUS
    {
        emit_asm("    neg ax");
    }
    ;

if_statement:
    TOKEN_KEYWORD_IF TOKEN_PARENTHESIS_OPEN expression TOKEN_PARENTHESIS_CLOSE statement
    {
        int label = get_new_label();
        emit_asm("    cmp ax, 0");
        emit_asm("    je .L%d_end", label);
        emit_asm(".L%d_end:", label);
    }
    | TOKEN_KEYWORD_IF TOKEN_PARENTHESIS_OPEN expression TOKEN_PARENTHESIS_CLOSE statement TOKEN_KEYWORD_ELSE statement
    {
        int lbl_else = get_new_label();
        int lbl_end = get_new_label();
        emit_asm("    cmp ax, 0");
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

for_statement:
    TOKEN_KEYWORD_FOR TOKEN_PARENTHESIS_OPEN for_init 
    {
        int lbl_cond = get_new_label();
        emit_asm("; for loop init");
        emit_asm("    jmp .L%d_cond", lbl_cond);
        emit_asm(".L%d_body:", lbl_cond - 1);
    }
    expression TOKEN_SEMICOLON identifier TOKEN_INCREMENT TOKEN_PARENTHESIS_CLOSE 
    compound_statement
    {
        int offset = get_symbol_offset($7);
        emit_asm("; increment %s", $7);
        emit_asm("    inc qword [rbp - %d]", offset);
        emit_asm(".L%d_cond:", label_counter - 1);
        emit_asm("    cmp rax, 0");
        emit_asm("    jne .L%d_body", label_counter - 2);
        emit_asm(".L%d_end:", label_counter - 1);
    }
    ;

for_init:
    TOKEN_KEYWORD_INT identifier TOKEN_SEMICOLON
    {
        add_symbol($2);
        emit_asm("    sub rsp, 8  ; int %s", $2);
    }
    | TOKEN_KEYWORD_INT identifier TOKEN_EQUAL expression TOKEN_SEMICOLON
    {
        add_symbol($2);
        emit_asm("    sub rsp, 8  ; int %s", $2);
        int offset = get_symbol_offset($2);
        emit_asm("    mov [rbp - %d], rax", offset);
    }
    ;

return_statement:
    TOKEN_KEYWORD_RETURN expression TOKEN_SEMICOLON
    {
        emit_asm("; return");
        emit_asm("    ret");
    }
    | TOKEN_KEYWORD_RETURN TOKEN_SEMICOLON
    {
        emit_asm("; return");
        emit_asm("    ret");
    }
    ;

%%

void yyerror(const char* s) {
    fprintf(stderr, "Error at line %d: %s\n", yylineno, s);
    
    // Try to provide more helpful error messages
    if (strcmp(s, "syntax error") == 0) {
        // Look ahead to see what token we got
        int next_token = yylex();
        switch (next_token) {
            case TOKEN_KEYWORD_INT:
            case TOKEN_KEYWORD_FLOAT:
            case TOKEN_KEYWORD_DOUBLE:
            case TOKEN_KEYWORD_CHAR:
            case TOKEN_KEYWORD_VOID:
            case TOKEN_KEYWORD_IF:
            case TOKEN_KEYWORD_WHILE:
            case TOKEN_KEYWORD_FOR:
            case TOKEN_KEYWORD_RETURN:
                fprintf(stderr, "Hint: Missing semicolon before declaration or statement\n");
                break;
            case TOKEN_IDENTIFIER:
                fprintf(stderr, "Hint: Missing semicolon before identifier\n");
                break;
            case TOKEN_BRACE_CLOSE:
                fprintf(stderr, "Hint: Missing semicolon before closing brace\n");
                break;
            case 0:
                fprintf(stderr, "Hint: Unexpected end of file\n");
                break;
            default:
                fprintf(stderr, "Hint: Check for missing semicolon or other syntax error\n");
                break;
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
    // In flat memory model, we don't use stack offsets
    // Variables are accessed directly by name
    sym->offset = 0;
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