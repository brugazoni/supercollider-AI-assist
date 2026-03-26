import time
import re
from sclang_validator import SclangValidator

def test_file():
    validator = SclangValidator(boot_timeout=15)
    if not validator.start():
        return

    with open("tests/full-test.scd", "r", encoding="utf-8") as f:
        code = f.read()

    # Manually fix the missing semicolon at line 62!
    code = code.replace(")\n\nNdef(\\ballRoll).set(\\wet12, 30);", ");\n\nNdef(\\ballRoll).set(\\wet12, 30);")

    # Fix the windows carriage returns causing line double-counting!
    code = code.replace('\r\n', '\n')

    print("Validating code...")
    start_time = time.time()
    
    is_valid, err = validator.validate(code, timeout=10.0)
    
    print(f"Validation took {time.time() - start_time:.2f} seconds.")
    print(f"Is Valid: {is_valid}")
    if err:
        print(f"Error Message:\n{err}")

    validator.stop()

if __name__ == "__main__":
    test_file()
