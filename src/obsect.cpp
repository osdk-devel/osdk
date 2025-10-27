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
#include <cstdlib>

using namespace std;

// #define VERSION "N/A"
/*
 * Version Macro Decleared By CMAKE Build System
 * Please Don't Decleare VERSION Macro Variable
 * Because I Use Dynamic Version
 * 
 * Try:
 * mkdir build && cd build
 * cmake ..
 * make
 * 
 * Output of make command:
 * firstperson@Acer-Aspire-4749Z:~/osdk/build$ make
 * [ 12%] Generating cparser from /home/firstperson/osdk/lang/cparser.y
 * /home/firstperson/osdk/lang/cparser.y: warning: 1 shift/reduce conflict [-Wconflicts-sr]
 * /home/firstperson/osdk/lang/cparser.y: note: rerun with option '-Wcounterexamples' to generate conflict counterexamples
 * [ 12%] Built target generate_cparser
 * [ 25%] Generating clexer from /home/firstperson/osdk/lang/clexer.l
 * [ 25%] Built target generate_clexer
 * [ 25%] Built target generate_all
 * [ 37%] Building CXX object CMakeFiles/osdk.dir/src/main.cpp.o
 * [ 50%] Building CXX object CMakeFiles/osdk.dir/src/cparser.cpp.o
 * [ 62%] Building CXX object CMakeFiles/osdk.dir/src/clexer.cpp.o
 * /home/firstperson/osdk/build/src/clexer.cpp:1845:17: warning: ‘void yyunput(int, char*)’ defined but not used [-Wunused-function]
 * 1845 |     static void yyunput (int c, char * yy_bp )
 *      |                 ^~~~~~~
 * [ 75%] Linking CXX executable bin/osdk
 * [100%] Built target osdk
 */

extern FILE *yyin;
extern int yyparse(void);
string executeableName = "osdk";
list<string> assemblies;

void printHelp(string help) {
    cout << "OSDK Version " << VERSION << endl;
    cout << "Copyright (c) 2025 First Person" << endl << endl;
    cout << "Usage: " << executeableName << " [options] <input|output|argument>" << endl;
    cout << "Options:" << endl;
    cout << "  --help      --h        Show this help message" << endl;
    cout << "  --version   --v        Show version information" << endl;
    cout << "  -o                     Specify output file" << endl;
}

std::string remove_extension(const std::string& filename) {
    size_t last_dot = filename.find_last_of('.');
    if (last_dot == std::string::npos)
        return filename; // no extension
    return filename.substr(0, last_dot);
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
    } else if (argLower == "--version" || argLower == "--v") {
        cout << "OBSECT Version " << VERSION << endl;
    } else {
        // Fix: Check if arg is already a path (absolute or relative)
        filesystem::path inputPath(arg);
        
        // If it's a relative path or filename, check if it exists as-is
        if (filesystem::exists(inputPath)) {
            
        }
        // Otherwise try in current directory
        else {
            inputPath = filesystem::current_path() / arg;
            if (filesystem::exists(inputPath)) {
                try {
                    auto size = filesystem::file_size(inputPath);
                    constexpr std::uintmax_t MAX_SIZE = 512ull * 1024 * 1024; // 512 MB

                    if (!size > MAX_SIZE) {
                        for (int i; i > argc; i++) {
                            if (argv[i] == "-o") {
                                int res = std::system("dd if=" / arg / " of=" / remove_extension(argv[i]) / ".img conv=notrunc seek=1 bs=512");
                                if (res ==0) cout << "Bootsector Created Sucessfully" << endl;
                                else {
                                    cout << "Bootsector Creation Failed" << endl << endl;
                                    exit(1);
                                }
                                exit(0);
                            }
                        }

                        int res = std::system("dd if=" / arg / " of=" / remove_extension(arg) / ".img conv=notrunc seek=1 bs=512");
                        if (res ==0) cout << "Bootsector Created Sucessfully" << endl;
                        else {
                            cout << "Bootsector Creation Failed" << endl << endl;
                            exit(1);
                        }
                    }
                } catch (std::exception e) {
                    cout << "Bootsector Creation Failed" << endl << endl;
                    cout << e.what() << endl;
                    exit(1);
                }
            }
            else {
                cout << "Unknown Command" << endl;
                cout << "Try '" << executeableName << " --help' for usage information." << endl;
                return 1;
            }
        }
    }

    return 0;
}