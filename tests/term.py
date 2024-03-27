#!/usr/bin/env python3
"""Display terminal output from NXT program."""
#
# Copyright (C) 2024 Nicolas Schodet
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.
#
import argparse
import nxt.locator
import nxt.error
import os.path
import time

p = argparse.ArgumentParser(description=__doc__)
p.add_argument("-s", "--start", metavar="PROGRAM",
               help="start program (with .rxe extension if not given")
p.add_argument("-q", "--quiet", action="store_true", help="output nothing while waiting")
p.add_argument("-o", "--once", action="store_true", help="exit after program end")
nxt.locator.add_arguments(p)
options = p.parse_args()

spinner = "-\\|/"
spinning = False
seen = False

def out(message):
    print(message.rstrip(b"\0").decode("windows-1252"))

with nxt.locator.find_with_options(options) as b:
    try:
        if options.start:
            prog = options.start
            if not os.path.splitext(prog)[1]:
                prog = prog + ".rxe"
            b.start_program(prog)
        while True:
            try:
                (inbox, message) = b.message_read(10, 0, True)
                if spinning:
                    print("\b", end="")
                out(message)
                seen = True
            except nxt.error.EmptyMailboxError as e:
                if spinning:
                    print("\b", end="")
                if not options.quiet:
                    print("_", end="", flush=True)
                    spinning = True
                time.sleep(0.05)
                seen = True
            except nxt.error.NoActiveProgramError:
                if spinning:
                    print("\b", end="")
                if seen and options.once:
                    break
                if not options.quiet:
                    print(spinner[0], end="", flush=True)
                    spinner = spinner[1:] + spinner[0]
                    spinning = True
                time.sleep(0.2)
    except KeyboardInterrupt:
        pass
