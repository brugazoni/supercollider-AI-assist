import multiprocessing as mp
import sys
import os

print(f"[{os.getpid()}] Module evaluated! __name__={__name__}, sys.argv={sys.argv}")

def worker():
    print(f"[{os.getpid()}] Worker running.")

if __name__ == '__main__':
    print(f"[{os.getpid()}] Inside main block. parent={mp.parent_process()}")
    if mp.parent_process() is None:
        p = mp.Process(target=worker)
        p.start()
        p.join()
