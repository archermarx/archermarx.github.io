---
pagetitle: PICO-8 Perlin terrain generator
bibliography: '../assets/bib/references.bib'
csl: '../assets/csl/iop-style.csl'
suppress-bibliography: false
link-citations: true
citations-hover: true
---

# Terrain generation on the PICO-8 using Perlin noise

I recently discovered the lovely [PICO-8](https://www.lexaloffle.com/pico-8.php) fantasy game console, and have been enjoying tinkering with it to make small simulations and programs. 
This program uses [Perlin noise](https://adrianb.io/2014/08/09/perlinnoise.html) to generate a 128x128 pixel terrain map.
It's pretty bare-bones and runs fairly slowly, but it works!
You can run it by clicking the play button below. 

## Controls:
- **z**: Regenerate terrain
- **Up-arrow**: raise sea level
- **Down-arrow**: lower sea level

<iframe src="https://www.lexaloffle.com/bbs/widget.php?pid=perlin" allowfullscreen width="621" height="513" style="border:none; overflow:hidden"></iframe>

One of the things that makes PICO-8 games cool is how shareable they are.
The entire game, code and all, fits into this PNG!
If you download it, you can edit and run the code on your own PICO-8 instance.

![](/assets/pico8/perlin.p8.png)

