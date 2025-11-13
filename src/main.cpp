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

#include <iostream>
#include <string>
#include <algorithm>
#include <vector>
#include <list>
#include <fstream>
#include <filesystem>
#include <random>
#include <chrono>

using namespace std;
namespace fs = std::filesystem;

// #define VERSION "N/A"

extern FILE *yyin;
extern int yyparse(void);
string executeableName = "sosdk";
list<string> assemblies;

void printHelp(string help) {
    cout << "SOSDK Version " << VERSION << endl;
    cout << "Copyright (c) 2025 First Person" << endl << endl;
    cout << "Usage: " << executeableName << " [options] <input|output|argument>" << endl;
    cout << "Options:" << endl;
    cout << "  --help      --h        Show this help message" << endl;
    cout << "  --version   --v        Show version information" << endl;
    cout << "  -o                     Specify output file" << endl;
    cout << "  -l                     Link Library" << endl;
    cout << "  -D<macro>              Define a macro" << endl;
    cout << "  -v<level>              Enable verbose output" << endl;
    cout << "  -type                  Set Program Type" << endl;
    cout << "  -a<architecture>       Set Target Architecture" << endl;
    cout << "  -O<level>              Set Optimization Level (0-3)" << endl;
    cout << "  -s                     Generate Debug Symbols" << endl;
    cout << "  -E                     Preprocess only" << endl;
    cout << "  -S                     Generate Assembly only" << endl;
}

bool compileFile(const string& inputPath) {
    fs::path p(inputPath);
    std::string basename = p.stem().string();
    
    yyin = fopen(inputPath.c_str(), "r");
    if (!yyin) {
        cerr << "Error: cannot open file '" << inputPath << "'" << endl;
        return false;
    }

    cout << "[SOSDK] Compiling " << inputPath << "..." << endl;

    // Run parser
    int result = yyparse();

    fclose(yyin);

    if (result != 0) {
        cerr << "[ERROR] Compilation failed." << endl;
        return false;
    }

    unsigned seed = std::chrono::system_clock::now().time_since_epoch().count();
    std::default_random_engine generator(seed);
    std::uniform_int_distribution<int> distribution(10000000, 99999999);
    int UNIQUE_ID = distribution(generator);

    ofstream outputFile("TMP" + std::to_string(UNIQUE_ID) + ".asm");
    if (!outputFile.is_open()) {
        cerr << "Failed to open output file." << endl;
        return false;
    }

    for (const auto& assembly : assemblies) {
        outputFile << assembly << endl;
    }

    // Add bootloader signature and padding
    outputFile << "    times 510-($-$$) db 0" << endl;
    outputFile << "    dw 0xAA55" << endl;

    outputFile.close();

    string cmd1 = "nasm -f bin TMP" + std::to_string(UNIQUE_ID) + ".asm -o " + basename + ".bin";
    if (system(cmd1.c_str()) != 0) {
        cerr << "nasm command failed" << endl;
        return false;
    }

    return true;
}

int main(int argc, char* argv[]) {
    executeableName = argv[0];

    if (argc == 1) {
        // Default behavior when no arguments are provided
        cout << "No arguments provided. Try '" << executeableName << " --help' for usage information." << endl;
        return 0;
    }

    string arg = argv[1];
    string argLower = arg;
    transform(argLower.begin(), argLower.end(), argLower.begin(), ::tolower);

    if (argLower == "--help" || argLower == "--h") {
        printHelp("main");
    } else if (argLower == "--version" || argLower == "-v") {
        cout << "SOSDK Version " << VERSION << endl;
    }
    else {
        // Check if arg is already a path (absolute or relative)
        fs::path inputPath(arg);
        
        // If it's a relative path or filename, check if it exists as-is
        if (fs::exists(inputPath)) {
            if (!compileFile(inputPath.string())) {
                return 1;
            }
        }
        // Otherwise try in current directory
        else {
            inputPath = fs::current_path() / arg;
            if (fs::exists(inputPath)) {
                if (!compileFile(inputPath.string())) {
                    return 1;
                }
            }
            else {
                cout << "Error: file not found '" << arg << "'" << endl;
                cout << "Try '" << executeableName << " --help' for usage information." << endl;
                return 1;
            }
        }
    }

    return 0;
}