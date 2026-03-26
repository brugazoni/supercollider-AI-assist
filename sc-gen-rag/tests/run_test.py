from sclang_validator import SclangValidator
v = SclangValidator()
if v.start():
    v._send_code('try { "test_multi.scd".load; "__SCLANG_VALID__".postln; } { |e| ("__SCLANG_ERROR__ " ++ e.errorString).postln; }\n')
    import time
    time.sleep(1)
    for l in v._flush_buffer(): print(repr(l))
    v.stop()
