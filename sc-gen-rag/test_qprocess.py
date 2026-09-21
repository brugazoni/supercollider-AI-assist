import sys
from PyQt5.QtCore import QProcess, QCoreApplication

app = QCoreApplication(sys.argv)
proc = QProcess()
proc.start("python", ["launcher.py"])
proc.waitForStarted()

proc.write(b"test1\n")

def on_ready_read():
    out = proc.readAllStandardOutput().data().decode()
    if out: print(f"OUT: {out}", end="")
    err = proc.readAllStandardError().data().decode()
    if err: print(f"ERR: {err}", end="")

proc.readyReadStandardOutput.connect(on_ready_read)
proc.readyReadStandardError.connect(on_ready_read)

proc.finished.connect(lambda: app.quit())

import threading
import time

def delayed_write():
    time.sleep(2)
    print("Writing test2...")
    proc.write(b"test2\n")
    time.sleep(6)
    print("Closing write channel...")
    proc.closeWriteChannel()

threading.Thread(target=delayed_write, daemon=True).start()

app.exec_()
