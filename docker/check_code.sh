#!/bin/bash
#
# SuperCollider Syntax Checker Wrapper
# 
# Usage: ./check_code.sh <code_file_or_string>
#
# If argument is a file path, it reads from that file.
# Otherwise, it treats the argument as inline code.
#
# Exit codes:
#   0 = Syntax OK
#   1 = Syntax Error
#   2 = Usage error

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTAINER_NAME="sc_syntax_checker"
CODE_INPUT_DIR="$SCRIPT_DIR/code_input"

# Ensure code_input directory exists
mkdir -p "$CODE_INPUT_DIR"

# Function to show usage
show_usage() {
    echo "Usage: $0 <code_file | inline_code_string>"
    echo ""
    echo "Examples:"
    echo "  $0 /path/to/my_code.scd"
    echo "  $0 '{ SinOsc.ar(440) }.play'"
    exit 2
}

# Check if argument provided
if [ -z "$1" ]; then
    show_usage
fi

# Generate temporary filename
TEMP_FILE="$CODE_INPUT_DIR/temp_$(date +%s%N).scd"

# Determine if input is a file or inline code
if [ -f "$1" ]; then
    # It's a file - copy to code_input
    cp "$1" "$TEMP_FILE"
else
    # It's inline code - write to temp file
    echo "$1" > "$TEMP_FILE"
fi

# Run the syntax checker in Docker
# We mount the code_input and pass the relative path
docker exec "$CONTAINER_NAME" sclang /app/check_syntax.scd "/app/code_input/$(basename $TEMP_FILE)"
EXIT_CODE=$?

# Cleanup temp file
rm -f "$TEMP_FILE"

exit $EXIT_CODE
