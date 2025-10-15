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

#ifndef CLEXER_H
#define CLEXER_H

#include <string>
#include "tokens.h"

class CLexer {
public:
    size_t pos;
    int line;
    
    /**
     * Constructor - initializes the lexer with input text
     * @param input The source code to tokenize
     */
    CLexer(const std::string& input);
    
    /**
     * Peek at the next character without consuming it
     * @return The next character, or '\0' if at end of input
     */
    char peek();
    
    /**
     * Peek at a character at a specific offset from current position
     * @param offset The number of characters ahead to peek
     * @return The character at the offset, or '\0' if out of bounds
     */
    char peekAt(size_t offset);
    
    /**
     * Advance to the next character in the input
     * Updates line and column tracking
     */
    void advance();
    
    /**
     * Get the next token from the input
     * @return Token type constant from tokens.h
     */
    int getToken();
    
    /**
     * Convert a token constant to its string name
     * @param token The token constant
     * @return String representation of the token name
     */
    std::string getTokenName(int token);

private:
    std::string text;
    char currentChar;
    int column;
};

#endif