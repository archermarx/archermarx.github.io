#!/usr/bin/env python3
import sys
import os

htmlfile = sys.argv[1]
mdfile = sys.argv[2]
dir = sys.argv[3]
tempfile = "../tmpfile"
assets = "assets";

os.makedirs(dir, exist_ok=True)
depth = dir.count("/")
reldir = "../" * depth

# read contents of file
with open(mdfile, 'r') as file:
    contents = file.read();

# add "last modified on" footer
from datetime import datetime
date = datetime.today().strftime('%b %d, %Y')
footer = f"""\n\\ \n\n\\ \n\n***\n
<span class="footer">
*Last updated on {date}. Created using [TSPW](https://github.com/eakbas/TSPW) and [pandoc](http://pandoc.org/).
</span>"""
contents += footer

# write to temporary file
with open(tempfile, 'w') as file:
    file.write(contents)

print(htmlfile)
import subprocess
args = [
    "pandoc",
    "--from=markdown",
    "--mathml",
    "--citeproc",
    f"--lua-filter=../{assets}/lua/bold-name.lua",
    "-t",
    "html5",
    "--standalone",
    "--css",
    f"{reldir}/{assets}/css/style.css",
    tempfile,
    "-o",
    htmlfile
] 
proc = subprocess.run(args)

os.remove(tempfile)
