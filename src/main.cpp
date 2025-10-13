#include <iostream>
#include <string>
#include <algorithm>

using namespace std;
#define VERSION "N/A"
string executeableName = "osdk";

void printHelp(string help) {
    cout << "OSDK Version " << VERSION << endl;
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

int main(int argc, char* argv[]) {
    executeableName = argv[0];

    if (argc == 1) {
        // Default behavior when no arguments are provided
        cout << "No arguments provided. Try '" << executeableName << " --help' for usage information." << endl;
        return 0;
    }

    string arg = argv[1];
    transform(arg.begin(), arg.end(), arg.begin(), ::tolower);

    if (arg == "--help" || arg == "--h") {
        printHelp("main");
    } else if (arg == "--version" || arg == "--v") {
        cout << "OSDK Version " << VERSION << endl;
    } else {
        cout << "Unknown option: " << arg << endl;
        cout << "Try '" << executeableName << " --help' for usage information." << endl;
    }

    return 0;
}