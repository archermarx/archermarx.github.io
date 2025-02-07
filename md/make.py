#!/usr/bin/env python3
import sys
import os
from pathlib import Path
from datetime import datetime
import time
import subprocess

htmlfile = sys.argv[1]
mdfile = sys.argv[2]
dir = sys.argv[3]
tempfile = "../tmpfile"
assets = "assets"

os.makedirs(dir, exist_ok=True)
depth = dir.count("/")
reldir = "../" * depth

# read contents of file
with open(mdfile, "r") as file:
    contents = file.readlines()

# ========= Insert date into YAML header if not present ===================
div_count = 0
div_ind = 0
title_ind = 0
has_date = False
for i, l in enumerate(contents):
    lower = l.casefold()
    if lower.startswith("title") or lower.startswith("pagetitle"):
        title_ind = i
    if lower.startswith("date"):
        print(lower)
        has_date = True
    if l.strip() == "---":
        div_count += 1
        div_ind = i
    if div_count == 2:
        break

header = contents[: div_ind + 1]
contents = contents[div_ind + 1 :]

if not has_date:
    date = datetime.strptime(time.ctime(os.path.getmtime(mdfile)), "%c")
    date = date.strftime("%b %d, %Y")
    date_header = [f"date: '{date}'\n"]
else:
    date_header = []

header = header[0 : title_ind + 1] + date_header + header[title_ind + 1 :]

# ========= Write modified md/html to temporary file =======================
with open(tempfile, "w") as file:
    file.writelines(header)
    file.writelines(contents)

# ========= Convert markdown to html using pandoc ==========================
print(htmlfile)

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
    "--template",
    f"../{assets}/html/template.html",
    "--css",
    f"{reldir}/{assets}/css/style.css",
    tempfile,
    "-o",
    htmlfile,
]
proc = subprocess.run(args)

os.remove(tempfile)
