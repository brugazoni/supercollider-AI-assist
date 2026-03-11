/*
    SuperCollider Syntax Checker - Simple Version
    
    Usage: sclang check_syntax.scd <path_to_PREPROCESSED_file>
    
    NOTE: The input file should be preprocessed to remove top-level () blocks.
    Use preprocess_sc.py for that step.
    
    Output:
    - "SYNTAX_OK" + code on success
    - "SYNTAX_ERROR" + error details on failure
*/

(
var args = thisProcess.argv;
var filePath, code, testCode, compiled;

if(args.size < 1) {
    "SYNTAX_ERROR: No file path provided".postln;
    1.exit;
};

filePath = args[0];

if(File.exists(filePath) == false) {
    ("SYNTAX_ERROR: File not found - " ++ filePath).postln;
    1.exit;
};

code = File.readAllString(filePath);

// Wrap in function and compile
testCode = "{ " ++ code ++ " }";

try {
    compiled = testCode.compile;
    if(compiled.isNil) {
        "SYNTAX_ERROR: Compilation failed".postln;
        1.exit;
    };
    "SYNTAX_OK".postln;
    "---CODE_START---".postln;
    code.postln;
    "---CODE_END---".postln;
    0.exit;
} { |error|
    "SYNTAX_ERROR:".postln;
    error.errorString.postln;
    1.exit;
};
)
