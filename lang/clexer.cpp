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

#include <iostream>
#include <string>
#include <cctype>
#include <fstream>
#include <vector>
#include "tokens.h"

using namespace std;

class Lexer {
public:
    size_t pos;
    int line;
    
    Lexer(const string& input) : text(input), pos(0), line(1), column(0) {
        currentChar = pos < text.size() ? text[pos] : '\0';
    }

    char peek() {
        size_t peekPos = pos + 1;
        if (peekPos < text.size()) {
            return text[peekPos];
        }
        return '\0';
    }
    
    char peekAt(size_t offset) {
        size_t peekPos = pos + offset;
        if (peekPos < text.size()) {
            return text[peekPos];
        }
        return '\0';
    }

    void advance() {
        if (currentChar == '\n') {
            line++;
            column = 0;
        } else {
            column++;
        }

        if (pos < text.size()) {
            currentChar = text[++pos];
        } else {
            currentChar = '\0';
        }
    }

    int getToken() {
        while (currentChar != '\0') {
            if (isspace(currentChar)) {
                while (isspace(currentChar)) {
                    advance();
                }
                return TOKEN_WHITESPACE;
            }

            if (isalpha(currentChar) || currentChar == '_') {
                string value;
                while (isalnum(currentChar) || currentChar == '_') {
                    value += currentChar;
                    advance();
                }
                if (value == "auto") return TOKEN_KEYWORD_AUTO;
                if (value == "break") return TOKEN_KEYWORD_BREAK;
                if (value == "case") return TOKEN_KEYWORD_CASE;
                if (value == "char") return TOKEN_KEYWORD_CHAR;
                if (value == "const") return TOKEN_KEYWORD_CONST;
                if (value == "continue") return TOKEN_KEYWORD_CONTINUE;
                if (value == "default") return TOKEN_KEYWORD_DEFAULT;
                if (value == "do") return TOKEN_KEYWORD_DO;
                if (value == "double") return TOKEN_KEYWORD_DOUBLE;
                if (value == "else") return TOKEN_KEYWORD_ELSE;
                if (value == "enum") return TOKEN_KEYWORD_ENUM;
                if (value == "extern") return TOKEN_KEYWORD_EXTERN;
                if (value == "float") return TOKEN_KEYWORD_FLOAT;
                if (value == "for") return TOKEN_KEYWORD_FOR;
                if (value == "goto") return TOKEN_KEYWORD_GOTO;
                if (value == "if") return TOKEN_KEYWORD_IF;
                if (value == "inline") return TOKEN_KEYWORD_INLINE;
                if (value == "int") return TOKEN_KEYWORD_INT;
                if (value == "long") return TOKEN_KEYWORD_LONG;
                if (value == "register") return TOKEN_KEYWORD_REGISTER;
                if (value == "restrict") return TOKEN_KEYWORD_RESTRICT;
                if (value == "return") return TOKEN_KEYWORD_RETURN;
                if (value == "short") return TOKEN_KEYWORD_SHORT;
                if (value == "signed") return TOKEN_KEYWORD_SIGNED;
                if (value == "sizeof") return TOKEN_KEYWORD_SIZEOF;
                if (value == "static") return TOKEN_KEYWORD_STATIC;
                if (value == "struct") return TOKEN_KEYWORD_STRUCT;
                if (value == "switch") return TOKEN_KEYWORD_SWITCH;
                if (value == "typedef") return TOKEN_KEYWORD_TYPEDEF;
                if (value == "union") return TOKEN_KEYWORD_UNION;
                if (value == "unsigned") return TOKEN_KEYWORD_UNSIGNED;
                if (value == "void") return TOKEN_KEYWORD_VOID;
                if (value == "volatile") return TOKEN_KEYWORD_VOLATILE;
                if (value == "while") return TOKEN_KEYWORD_WHILE;
                if (value == "_Alignas") return TOKEN_KEYWORD_ALIGNAS;
                if (value == "_Alignof") return TOKEN_KEYWORD_ALIGNOF;
                if (value == "_Atomic") return TOKEN_KEYWORD_ATOMIC;
                if (value == "_Bool") return TOKEN_KEYWORD_BOOL;
                if (value == "_Complex") return TOKEN_KEYWORD_COMPLEX;
                if (value == "_Generic") return TOKEN_KEYWORD_GENERIC;
                if (value == "_Imaginary") return TOKEN_KEYWORD_IMAGINARY;
                if (value == "_Noreturn") return TOKEN_KEYWORD_NORETURN;
                if (value == "_Static_assert") return TOKEN_KEYWORD_STATIC_ASSERT;
                if (value == "_Thread_local") return TOKEN_KEYWORD_THREAD_LOCAL;
                
                return TOKEN_IDENTIFIER;
            }

            if (isdigit(currentChar)) {
                while (isdigit(currentChar)) {
                    advance();
                }
                return TOKEN_NUMBER;
            }

            if (currentChar == '\'') {
                advance();
                if (currentChar != '\0' && currentChar != '\'') {
                    advance();
                }
                if (currentChar == '\'') {
                    advance();
                }
                return TOKEN_CHARACTER;
            }

            if (currentChar == '"') {
                advance();
                while (currentChar != '\0' && currentChar != '"') {
                    if (currentChar == '\\') {
                        advance();
                        if (currentChar != '\0') {
                            advance();
                        }
                    } else {
                        advance();
                    }
                }
                if (currentChar == '"') {
                    advance();
                }
                return TOKEN_STRING;
            }

            if (currentChar == '/' && peek() == '/') {
                while (currentChar != '\0' && currentChar != '\n') {
                    advance();
                }
                return TOKEN_COMMENT;
            }

            if (currentChar == '/' && peek() == '*') {
                advance();
                advance();
                while (currentChar != '\0') {
                    if (currentChar == '*' && peek() == '/') {
                        advance();
                        advance();
                        return TOKEN_COMMENT;
                    }
                    advance();
                }
                return TOKEN_UNKNOWN;
            }

            if (currentChar == '.') {
                if (peek() == '.' && pos + 2 < text.size() && text[pos + 2] == '.') {
                    advance();
                    advance();
                    advance();
                    return TOKEN_ELLIPSIS;
                }
                advance();
                return TOKEN_DOT;
            }

            if (currentChar == '+') {
                advance();
                if (currentChar == '+') {
                    advance();
                    return TOKEN_INCREMENT;
                }
                if (currentChar == '=') {
                    advance();
                    return TOKEN_PLUS_EQUAL;
                }
                return TOKEN_PLUS;
            }

            if (currentChar == '-') {
                advance();
                if (currentChar == '-') {
                    advance();
                    return TOKEN_DECREMENT;
                }
                if (currentChar == '=') {
                    advance();
                    return TOKEN_MINUS_EQUAL;
                }
                if (currentChar == '>') {
                    advance();
                    return TOKEN_ARROW;
                }
                return TOKEN_MINUS;
            }

            if (currentChar == '*') {
                advance();
                if (currentChar == '=') {
                    advance();
                    return TOKEN_ASTERISK_EQUAL;
                }
                return TOKEN_ASTERISK;
            }

            if (currentChar == '/') {
                advance();
                if (currentChar == '=') {
                    advance();
                    return TOKEN_SLASH_EQUAL;
                }
                return TOKEN_SLASH;
            }

            if (currentChar == '%') {
                advance();
                if (currentChar == '=') {
                    advance();
                    return TOKEN_PERCENT_EQUAL;
                }
                return TOKEN_PERCENT;
            }

            if (currentChar == '&') {
                advance();
                if (currentChar == '&') {
                    advance();
                    return TOKEN_LOGICAL_AND;
                }
                if (currentChar == '=') {
                    advance();
                    return TOKEN_AMPERSAND_EQUAL;
                }
                return TOKEN_AMPERSAND;
            }

            if (currentChar == '|') {
                advance();
                if (currentChar == '|') {
                    advance();
                    return TOKEN_LOGICAL_OR;
                }
                if (currentChar == '=') {
                    advance();
                    return TOKEN_BITWISE_OR_EQUAL;
                }
                return TOKEN_BITWISE_OR;
            }

            if (currentChar == '^') {
                advance();
                if (currentChar == '=') {
                    advance();
                    return TOKEN_BITWISE_XOR_EQUAL;
                }
                return TOKEN_BITWISE_XOR;
            }

            if (currentChar == '~') {
                advance();
                return TOKEN_BITWISE_NOT;
            }

            if (currentChar == '!') {
                advance();
                if (currentChar == '=') {
                    advance();
                    return TOKEN_NOT_EQUAL;
                }
                return TOKEN_LOGICAL_NOT;
            }

            if (currentChar == '=') {
                advance();
                if (currentChar == '=') {
                    advance();
                    return TOKEN_EQUAL_EQUAL;
                }
                return TOKEN_EQUAL;
            }

            if (currentChar == '<') {
                advance();
                if (currentChar == '<') {
                    advance();
                    if (currentChar == '=') {
                        advance();
                        return TOKEN_SHIFT_LEFT_EQUAL;
                    }
                    return TOKEN_SHIFT_LEFT;
                }
                if (currentChar == '=') {
                    advance();
                    return TOKEN_LESS_THAN_EQUAL;
                }
                return TOKEN_LESS_THAN;
            }

            if (currentChar == '>') {
                advance();
                if (currentChar == '>') {
                    advance();
                    if (currentChar == '=') {
                        advance();
                        return TOKEN_SHIFT_RIGHT_EQUAL;
                    }
                    return TOKEN_SHIFT_RIGHT;
                }
                if (currentChar == '=') {
                    advance();
                    return TOKEN_GREATER_THAN_EQUAL;
                }
                return TOKEN_GREATER_THAN;
            }

            char token = currentChar;
            advance();
            switch (token) {
                case '(': return TOKEN_PARENTHESIS_OPEN;
                case ')': return TOKEN_PARENTHESIS_CLOSE;
                case '{': return TOKEN_BRACE_OPEN;
                case '}': return TOKEN_BRACE_CLOSE;
                case '[': return TOKEN_BRACKET_OPEN;
                case ']': return TOKEN_BRACKET_CLOSE;
                case ';': return TOKEN_SEMICOLON;
                case ':': return TOKEN_COLON;
                case ',': return TOKEN_COMMA;
                case '#': return TOKEN_HASH;
                case '?': return TOKEN_QUESTION;
                default: return TOKEN_UNKNOWN;
            }
        }

        return TOKEN_END_OF_FILE;
    }

private:
    string text;
    char currentChar;
    int column;
};