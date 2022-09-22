#!/usr/bin/env python3
import argparse
import os
import sys

args = sys.argv
if len(sys.argv) < 2:
    print(f"Usage: {sys.argv[0]} NAME [HC_NAME]", file=sys.stderr)
    sys.exit(1)

name = sys.argv[1]

if '-' in name:
    name, hc = name.split('-')
    os.execl("/bin/bash", "bash", "start-base.sh", "--hc", hc, name)
else:
    print(f"server {name}")
    os.execl("/bin/bash", "bash", "start-base.sh", name)
