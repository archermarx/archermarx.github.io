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
    contents = file.readlines();

# find YAML header
div_count = 0
div_ind = 0
title_ind = 0
for (i, l) in enumerate(contents):
    if l.startswith('Title'):
        title_ind = i
    if l.strip() == '---':
        div_count += 1
        div_ind = i
    if div_count == 2:
        break

header = contents[:div_ind+1]
contents = contents[div_ind+1:]

# add favicon into header after title
favicon_path = "/favicon.ico"

favicon_header = [
    "header-includes:\n",
    f'    <link rel="icon" type="image/x-icon" href={favicon_path}/>\n'
]

header = header[0:title_ind+1] + favicon_header + header[title_ind+1:]

# add "last modified on" footer
from datetime import datetime
date = datetime.today().strftime('%b %d, %Y')
footer = f"""\n\n\\ \n\n***\n
<span class="footer">
*Last updated on {date}. Created using [pandoc](http://pandoc.org/).
</span>"""

# write navbar
navbar = """<div class="navbar">
[Home](/index.html) | [Publications](/publications.html) | [Posts](/archive.html) | [Curriculum Vitae](/files/thomas_marks_cv_2024.pdf)
</div>"""

# write to temporary file
with open(tempfile, 'w') as file:
    file.writelines(header)
    file.write(navbar)
    file.writelines(contents)
    file.write(footer)

print(htmlfile)
import subprocess
args = [
    "pandoc",
    "--from",
    "markdown-markdown_in_html_blocks+raw_html",
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
