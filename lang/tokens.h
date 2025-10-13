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

#ifndef TOKENS_H
#define TOKENS_H

// Basic
#define TOKEN_IDENTIFIER            1
#define TOKEN_NUMBER                2
#define TOKEN_CHARACTER             3
#define TOKEN_STRING                4
#define TOKEN_COMMENT               5
#define TOKEN_WHITESPACE            6

// Delimiters
#define TOKEN_PARENTHESIS_OPEN      7
#define TOKEN_PARENTHESIS_CLOSE     8
#define TOKEN_BRACE_OPEN            9
#define TOKEN_BRACE_CLOSE           10
#define TOKEN_BRACKET_OPEN          11
#define TOKEN_BRACKET_CLOSE         12

// Punctuation
#define TOKEN_SEMICOLON             13
#define TOKEN_COLON                 14
#define TOKEN_COMMA                 15
#define TOKEN_DOT                   16
#define TOKEN_ELLIPSIS              17
#define TOKEN_HASH                  18
#define TOKEN_ARROW                 19
#define TOKEN_QUESTION              20

// Operators
#define TOKEN_PLUS                  21
#define TOKEN_MINUS                 22
#define TOKEN_ASTERISK              23
#define TOKEN_SLASH                 24
#define TOKEN_PERCENT               25
#define TOKEN_INCREMENT             26
#define TOKEN_DECREMENT             27
#define TOKEN_EQUAL                 28
#define TOKEN_PLUS_EQUAL            29
#define TOKEN_MINUS_EQUAL           30
#define TOKEN_ASTERISK_EQUAL        31
#define TOKEN_SLASH_EQUAL           32
#define TOKEN_PERCENT_EQUAL         33
#define TOKEN_AMPERSAND             34
#define TOKEN_AMPERSAND_EQUAL       35
#define TOKEN_BITWISE_OR            36
#define TOKEN_BITWISE_OR_EQUAL      37
#define TOKEN_BITWISE_XOR           38
#define TOKEN_BITWISE_XOR_EQUAL     39
#define TOKEN_BITWISE_NOT           40
#define TOKEN_SHIFT_LEFT            41
#define TOKEN_SHIFT_RIGHT           42
#define TOKEN_SHIFT_LEFT_EQUAL      43
#define TOKEN_SHIFT_RIGHT_EQUAL     44
#define TOKEN_LOGICAL_AND           45
#define TOKEN_LOGICAL_OR            46
#define TOKEN_LOGICAL_NOT           47
#define TOKEN_LESS_THAN             48
#define TOKEN_GREATER_THAN          49
#define TOKEN_LESS_THAN_EQUAL       50
#define TOKEN_GREATER_THAN_EQUAL    51
#define TOKEN_EQUAL_EQUAL           52
#define TOKEN_NOT_EQUAL             53

// Keywords
#define TOKEN_KEYWORD_AUTO          54
#define TOKEN_KEYWORD_BREAK         55
#define TOKEN_KEYWORD_CASE          56
#define TOKEN_KEYWORD_CHAR          57
#define TOKEN_KEYWORD_CONST         58
#define TOKEN_KEYWORD_CONTINUE      59
#define TOKEN_KEYWORD_DEFAULT       60
#define TOKEN_KEYWORD_DO            61
#define TOKEN_KEYWORD_DOUBLE        62
#define TOKEN_KEYWORD_ELSE          63
#define TOKEN_KEYWORD_ENUM          64
#define TOKEN_KEYWORD_EXTERN        65
#define TOKEN_KEYWORD_FLOAT         66
#define TOKEN_KEYWORD_FOR           67
#define TOKEN_KEYWORD_GOTO          68
#define TOKEN_KEYWORD_IF            69
#define TOKEN_KEYWORD_INLINE        70
#define TOKEN_KEYWORD_INT           71
#define TOKEN_KEYWORD_LONG          72
#define TOKEN_KEYWORD_REGISTER      73
#define TOKEN_KEYWORD_RESTRICT      74
#define TOKEN_KEYWORD_RETURN        75
#define TOKEN_KEYWORD_SHORT         76
#define TOKEN_KEYWORD_SIGNED        77
#define TOKEN_KEYWORD_SIZEOF        78
#define TOKEN_KEYWORD_STATIC        79
#define TOKEN_KEYWORD_STRUCT        80
#define TOKEN_KEYWORD_SWITCH        81
#define TOKEN_KEYWORD_TYPEDEF       82
#define TOKEN_KEYWORD_UNION         83
#define TOKEN_KEYWORD_UNSIGNED      84
#define TOKEN_KEYWORD_VOID          85
#define TOKEN_KEYWORD_VOLATILE      86
#define TOKEN_KEYWORD_WHILE         87
#define TOKEN_KEYWORD_ALIGNAS       88
#define TOKEN_KEYWORD_ALIGNOF       89
#define TOKEN_KEYWORD_ATOMIC        90
#define TOKEN_KEYWORD_BOOL          91
#define TOKEN_KEYWORD_COMPLEX       92
#define TOKEN_KEYWORD_GENERIC       93
#define TOKEN_KEYWORD_IMAGINARY     94
#define TOKEN_KEYWORD_NORETURN      95
#define TOKEN_KEYWORD_STATIC_ASSERT 96
#define TOKEN_KEYWORD_THREAD_LOCAL  97

// File tokens
#define TOKEN_START_OF_FILE         98
#define TOKEN_END_OF_FILE           99

// Miscellaneous
#define TOKEN_UNKNOWN               100

#endif