#!/usr/bin/env python3
import os
import pty
import subprocess
import sys


def main():
    if len(sys.argv) < 5:
        sys.exit(1)
    glow, style, width, filepath = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
    master, slave = pty.openpty()
    proc = subprocess.Popen(
        [glow, "-s", style, "-w", width, filepath],
        stdout=slave,
        stderr=slave,
        stdin=slave,
    )
    os.close(slave)
    chunks = []
    while True:
        try:
            data = os.read(master, 4096)
            if not data:
                break
            chunks.append(data)
        except OSError:
            break
    proc.wait()
    os.close(master)
    sys.stdout.buffer.write(b"".join(chunks))


main()
