%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include "clexer.h"

extern int yylex();
extern char* yytext;
extern int yylineno;

void yyerror(const char* s);
void emit_asm(const char* fmt, ...);

// Symbol table
typedef struct symbol {
    char name[256];
    int offset;
    struct symbol* next;
} symbol_t;

symbol_t* symtab = NULL;
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

%token TOKEN_KEYWORD_INT TOKEN_KEYWORD_IF TOKEN_KEYWORD_ELSE TOKEN_KEYWORD_WHILE TOKEN_KEYWORD_RETURN
%token TOKEN_PLUS TOKEN_MINUS TOKEN_ASTERISK TOKEN_SLASH TOKEN_EQUAL
%token TOKEN_LESS_THAN TOKEN_GREATER_THAN TOKEN_EQUAL_EQUAL TOKEN_NOT_EQUAL
%token TOKEN_PARENTHESIS_OPEN TOKEN_PARENTHESIS_CLOSE
%token TOKEN_BRACE_OPEN TOKEN_BRACE_CLOSE
%token TOKEN_SEMICOLON
%token TOKEN_INCREMENT TOKEN_DECREMENT
%token TOKEN_PLUS_EQUAL TOKEN_MINUS_EQUAL

%type <num> expression term factor
%type <str> identifier

%left TOKEN_PLUS TOKEN_MINUS
%left TOKEN_ASTERISK TOKEN_SLASH
%right UMINUS

%%

program:
      /* empty */
    | program statement
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
    fprintf(stderr, "Error at line %d: %s\n", yylineno, s);
}

void emit_asm(const char* fmt, ...) {
    va_list args;
    va_start(args, fmt);
    vprintf(fmt, args);
    printf("\n");
    va_end(args);
}

void add_symbol(const char* name) {
    symbol_t* sym = malloc(sizeof(symbol_t));
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