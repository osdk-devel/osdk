%{
/*
 * MIT License
 * 
 * Copyright (c) 2025 First Person
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#include "tokens.h"
#include <stdio.h>
#include <string.h>

/* Global variables for tracking line and column */
int yyline = 1;
int yycolumn = 0;

/* Update column tracking */
#define YY_USER_ACTION yycolumn += yyleng;

%}

/* Options */
%option noyywrap
%option yylineno

/* Definitions */
DIGIT           [0-9]
LETTER          [a-zA-Z_]
IDENTIFIER      {LETTER}({LETTER}|{DIGIT})*
INTEGER         {DIGIT}+
WHITESPACE      [ \t\r]+
NEWLINE         \n

%%

    /* Whitespace and newlines */
{WHITESPACE}            { /* Skip whitespace */ }
{NEWLINE}               { yyline++; yycolumn = 0; }

    /* Keywords - C89/C90 */
"auto"                  { return TOKEN_KEYWORD_AUTO; }
"break"                 { return TOKEN_KEYWORD_BREAK; }
"case"                  { return TOKEN_KEYWORD_CASE; }
"char"                  { return TOKEN_KEYWORD_CHAR; }
"const"                 { return TOKEN_KEYWORD_CONST; }
"continue"              { return TOKEN_KEYWORD_CONTINUE; }
"default"               { return TOKEN_KEYWORD_DEFAULT; }
"do"                    { return TOKEN_KEYWORD_DO; }
"double"                { return TOKEN_KEYWORD_DOUBLE; }
"else"                  { return TOKEN_KEYWORD_ELSE; }
"enum"                  { return TOKEN_KEYWORD_ENUM; }
"extern"                { return TOKEN_KEYWORD_EXTERN; }
"float"                 { return TOKEN_KEYWORD_FLOAT; }
"for"                   { return TOKEN_KEYWORD_FOR; }
"goto"                  { return TOKEN_KEYWORD_GOTO; }
"if"                    { return TOKEN_KEYWORD_IF; }
"int"                   { return TOKEN_KEYWORD_INT; }
"long"                  { return TOKEN_KEYWORD_LONG; }
"register"              { return TOKEN_KEYWORD_REGISTER; }
"return"                { return TOKEN_KEYWORD_RETURN; }
"short"                 { return TOKEN_KEYWORD_SHORT; }
"signed"                { return TOKEN_KEYWORD_SIGNED; }
"sizeof"                { return TOKEN_KEYWORD_SIZEOF; }
"static"                { return TOKEN_KEYWORD_STATIC; }
"struct"                { return TOKEN_KEYWORD_STRUCT; }
"switch"                { return TOKEN_KEYWORD_SWITCH; }
"typedef"               { return TOKEN_KEYWORD_TYPEDEF; }
"union"                 { return TOKEN_KEYWORD_UNION; }
"unsigned"              { return TOKEN_KEYWORD_UNSIGNED; }
"void"                  { return TOKEN_KEYWORD_VOID; }
"volatile"              { return TOKEN_KEYWORD_VOLATILE; }
"while"                 { return TOKEN_KEYWORD_WHILE; }

    /* Keywords - C99 */
"inline"                { return TOKEN_KEYWORD_INLINE; }
"restrict"              { return TOKEN_KEYWORD_RESTRICT; }

    /* Keywords - C11 */
"_Alignas"              { return TOKEN_KEYWORD_ALIGNAS; }
"_Alignof"              { return TOKEN_KEYWORD_ALIGNOF; }
"_Atomic"               { return TOKEN_KEYWORD_ATOMIC; }
"_Bool"                 { return TOKEN_KEYWORD_BOOL; }
"_Complex"              { return TOKEN_KEYWORD_COMPLEX; }
"_Generic"              { return TOKEN_KEYWORD_GENERIC; }
"_Imaginary"            { return TOKEN_KEYWORD_IMAGINARY; }
"_Noreturn"             { return TOKEN_KEYWORD_NORETURN; }
"_Static_assert"        { return TOKEN_KEYWORD_STATIC_ASSERT; }
"_Thread_local"         { return TOKEN_KEYWORD_THREAD_LOCAL; }

    /* Identifiers and literals */
{IDENTIFIER}            { return TOKEN_IDENTIFIER; }
{INTEGER}               { return TOKEN_NUMBER; }

    /* Character and string literals */
'(\\.|[^\\'\n])'        { return TOKEN_CHARACTER; }
\"(\\.|[^\\"\n])*\"     { return TOKEN_STRING; }

    /* Comments */
"//".*                  { return TOKEN_COMMENT; }
"/*"([^*]|(\*+[^*/]))*\*+"/" { return TOKEN_COMMENT; }

    /* Three-character operators */
"..."                   { return TOKEN_ELLIPSIS; }
"<<="                   { return TOKEN_SHIFT_LEFT_EQUAL; }
">>="                   { return TOKEN_SHIFT_RIGHT_EQUAL; }

    /* Two-character operators */
"++"                    { return TOKEN_INCREMENT; }
"--"                    { return TOKEN_DECREMENT; }
"->"                    { return TOKEN_ARROW; }
"<<"                    { return TOKEN_SHIFT_LEFT; }
">>"                    { return TOKEN_SHIFT_RIGHT; }
"<="                    { return TOKEN_LESS_THAN_EQUAL; }
">="                    { return TOKEN_GREATER_THAN_EQUAL; }
"=="                    { return TOKEN_EQUAL_EQUAL; }
"!="                    { return TOKEN_NOT_EQUAL; }
"&&"                    { return TOKEN_LOGICAL_AND; }
"||"                    { return TOKEN_LOGICAL_OR; }
"+="                    { return TOKEN_PLUS_EQUAL; }
"-="                    { return TOKEN_MINUS_EQUAL; }
"*="                    { return TOKEN_ASTERISK_EQUAL; }
"/="                    { return TOKEN_SLASH_EQUAL; }
"%="                    { return TOKEN_PERCENT_EQUAL; }
"&="                    { return TOKEN_AMPERSAND_EQUAL; }
"|="                    { return TOKEN_BITWISE_OR_EQUAL; }
"^="                    { return TOKEN_BITWISE_XOR_EQUAL; }

    /* Single-character operators and punctuation */
"+"                     { return TOKEN_PLUS; }
"-"                     { return TOKEN_MINUS; }
"*"                     { return TOKEN_ASTERISK; }
"/"                     { return TOKEN_SLASH; }
"%"                     { return TOKEN_PERCENT; }
"&"                     { return TOKEN_AMPERSAND; }
"|"                     { return TOKEN_BITWISE_OR; }
"^"                     { return TOKEN_BITWISE_XOR; }
"~"                     { return TOKEN_BITWISE_NOT; }
"!"                     { return TOKEN_LOGICAL_NOT; }
"<"                     { return TOKEN_LESS_THAN; }
">"                     { return TOKEN_GREATER_THAN; }
"="                     { return TOKEN_EQUAL; }
"?"                     { return TOKEN_QUESTION; }
":"                     { return TOKEN_COLON; }
";"                     { return TOKEN_SEMICOLON; }
","                     { return TOKEN_COMMA; }
"."                     { return TOKEN_DOT; }
"#"                     { return TOKEN_HASH; }

    /* Delimiters */
"("                     { return TOKEN_PARENTHESIS_OPEN; }
")"                     { return TOKEN_PARENTHESIS_CLOSE; }
"{"                     { return TOKEN_BRACE_OPEN; }
"}"                     { return TOKEN_BRACE_CLOSE; }
"["                     { return TOKEN_BRACKET_OPEN; }
"]"                     { return TOKEN_BRACKET_CLOSE; }

    /* Unknown character */
.                       { return TOKEN_UNKNOWN; }

%%

/* Additional C code */