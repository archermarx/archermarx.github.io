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

# find YAML header
div_count = 0
div_ind = 0
title_ind = 0
for i, l in enumerate(contents):
    if l.startswith("Title"):
        title_ind = i
    if l.strip() == "---":
        div_count += 1
        div_ind = i
    if div_count == 2:
        break

header = contents[: div_ind + 1]
contents = contents[div_ind + 1 :]

# add favicon into header after title
favicon_path = "/favicon.ico"

favicon_header = [
    "header-includes:\n",
    f'    <link rel="icon" type="image/x-icon" href="{favicon_path}"/>\n',
]

header = header[0 : title_ind + 1] + favicon_header + header[title_ind + 1 :]

# ========= Write navbar ===================================================
active = 'class="active"'
is_home = active if mdfile == "index.md" else ""
is_pubs = active if mdfile == "publications.md" else ""

content_paths = {"p", "content"}

if mdfile == "archive.md" or str(Path(mdfile).parent) in content_paths:
    is_posts = active
else:
    is_posts = ""

navbar = f"""
<div class="navbar" id="navigation_bar">
<a {is_home} href="/">Home</a>
<a {is_pubs} href="/publications">Publications</a>
<a {is_posts} href="/archive">Posts</a>
<a href="/files/cv.pdf">Curriculum Vitae</a>
<a href="javascript:void(0);" class="icon" onclick="responsive_navbar()">
    <i class="fa fa-bars"></i>
</a>
</div>
"""

navbar_js = """
<script>
function responsive_navbar() {
  var x = document.getElementById("navigation_bar");
  if (x.className === "navbar") {
    x.className += " responsive";
  } else {
    x.className = "navbar";
  }
}
</script>
"""

# ========= Write footer with modification date  ===========================
date = datetime.strptime(time.ctime(os.path.getmtime(mdfile)), "%c")
date = date.strftime("%b %d, %Y")

footer = f"""\n\n\\ \n\n***\n
<span class="footer">
*Last updated on {date}. Created using [pandoc](http://pandoc.org/).
</span>"""

# ========= Write modified md/html to temporary file =======================
with open(tempfile, "w") as file:
    file.writelines(header)
    file.write(navbar)
    file.writelines(contents)
    file.write(navbar_js)
    file.write(footer)

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
    "--css",
    f"{reldir}/{assets}/css/style.css",
    tempfile,
    "-o",
    htmlfile,
]
proc = subprocess.run(args)

os.remove(tempfile)
