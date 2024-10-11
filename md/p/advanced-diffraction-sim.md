---
pagetitle: Diffraction simulation
bibliography: '../assets/bib/references.bib'
csl: '../assets/csl/iop-style.csl'
suppress-bibliography: false
link-citations: true
citations-hover: true
---

# Diffraction grating simulation

<div class="centered-block">
<div class="controls">
<div>
<input type="range" id="sources_input" min="1" max="16" value="3" step="1" autocomplete="off"/>
<label for="sources_input">Slits: <output id="sources_output"/></label>
</div>
<div>
<input type="range" id="spacing_input" min="0" max="1" value="0.5" step="any" autocomplete="off"/>
<label for="spacing_input">Slit spacing</label>
</div>
<div>
<input type="range" id="slitwidth_input" min="0.05" max="0.95" value="0.5" step="any" autocomplete="off"/>
<label for="slitwidth_input">Slit width</label>
</div>
<div>
<input type="range" id="wavenumber_input" min="1" max="64" value="16" step="any" autocomplete="off"/>
<label for="wavenumber_input">Wavenumber: <output id="wavenumber_output"/></label>
</div>
</div>

<canvas id="canvas" width=1000 height=1200></canvas>
</div>

<script src = "../scripts/webgl.js"></script>
<script>
// Get the webgl rendering context
var gl = canvas.getContext('webgl');


// vertex shader
var vshader = `
attribute vec4 position;
void main() {
    gl_Position = position;
}
`;

// fragment shader
var fshader = `
precision mediump float;

uniform float width;
uniform float height;
#define PI 3.141592653589
float timefreq = 100.0;
uniform float time;

#define RED vec3(162., 30., 37.) / 256.0
#define BLUE vec3(11., 102., 188.) / 256.0
#define WHITE vec3(1.0, 1.0, 1.0)
#define BLACK vec3(0.0, 0.0, 0.0)

#define MIN_DIST 0.0125
#define BLUR_RADIUS 1.05
#define SLIT_HEIGHT 0.02

#define MAX_SLITS 16
float centers[MAX_SLITS];
float grating_y = 0.25;

uniform int num_slits;
uniform float spacing;
uniform float slit_width;
uniform float wavenumber;
float source_distance = 2.0;

vec3 wave_color(float amplitude) {
    vec3 color;
    if (amplitude > 0.0) {
        color = RED;
    } else {
        color = BLUE;
    }
    float s = pow(abs(amplitude), 1.2) * 1.2; // gamma correction and scaling
    s = clamp(s, 0.0, 1.0); // clamp to [0,1]
    color *= s;
    return color;
}

vec3 draw_grating(vec3 color, vec2 pos, vec2 sourcePos) {
    float grating_thickness = 0.01;

    float x = pos.x / width;
    float y = pos.y / height;

    if (y > -grating_y + grating_thickness / 2.0 ||
        y < -grating_y - grating_thickness / 2.0) {
        return color;
    }
    
    vec3 c = WHITE;
    float w = 0.5 * slit_width; 

    for (int i = 0; i <= MAX_SLITS; i++) {
        if (i >= num_slits) {break;}
        if (x >= centers[i] - w && x <= centers[i] + w) {
            c = color;
            break;
        }  
    }

    return c;
}

void main () {
    // determine grate centers
    if (num_slits == 1) {
        centers[0] = 0.0;
    } else {
        float increment = spacing / float(num_slits-1);
        for (int i = 0; i < MAX_SLITS; i++) {
            if (i >= num_slits) {break;}
            centers[i] = -0.5 * spacing + float(i)*increment;
        }
    }

    vec2 pos = gl_FragCoord.xy - vec2(width/2.0, height/2.0);
    vec2 sourcePos = vec2(0.0, -source_distance * width);
    float r = distance(pos, sourcePos) / width;
    float wave_amplitude =  sin(2.0*PI * wavenumber * r - time);

    vec3 color = wave_color(wave_amplitude);
    gl_FragColor = vec4(draw_grating(color, pos, sourcePos), 1.0);
}
`;

// Controls
var time = 0.0;
var dt = 0.1;

// Compile program
var program = compile(gl, vshader, fshader);

// Send canvas size to shader
var width = canvas.width;
var height = canvas.height;
var widthLoc = gl.getUniformLocation(program, 'width');
var heightLoc = gl.getUniformLocation(program, 'height');
var timeLoc = gl.getUniformLocation(program, 'time');
gl.uniform1f(widthLoc, width);
gl.uniform1f(heightLoc, height);

// Set controls
var spacing_input = document.querySelector("#spacing_input");
set_spacing = (val) => {
    gl.uniform1f(gl.getUniformLocation(program, 'spacing'), val);
    set_slitwidth(slitwidth_input.value);
}
spacing_input.addEventListener("input", (event) => {set_spacing(event.target.value)});

var slitwidth_input = document.querySelector("#slitwidth_input");
set_slitwidth = (val) => {
    gl.uniform1f(gl.getUniformLocation(program, 'slit_width'), 0.5 * val * spacing_input.value);
}
slitwidth_input.addEventListener("input", (event) => {set_slitwidth(event.target.value)});

var wavenumber_input = document.querySelector("#wavenumber_input");
var wavenumber_output = document.querySelector("#wavenumber_output");
set_wavenumber = (val) => {
    wavenumber_output.textContent = Math.round(10*val)/10;
    gl.uniform1f(gl.getUniformLocation(program, 'wavenumber'), val);
}
wavenumber_input.addEventListener("input", (event) => {set_wavenumber(event.target.value)});

var sources_input = document.querySelector("#sources_input");
var sources_output = document.querySelector("#sources_output");
set_sources = (val) => {
    sources_output.textContent = val;
    gl.uniform1i(gl.getUniformLocation(program, 'num_slits'), val);
}
sources_input.addEventListener("input", (event) => {set_sources(event.target.value)});

// initialize controls
set_spacing(spacing_input.value);
set_slitwidth(slitwidth_input.value);
set_wavenumber(wavenumber_input.value);
set_sources(sources_input.value);

// Define vertices and colors
var verticesColors = new Float32Array([
   //x ,  y,    z,  
    -1.0, -1.0, 0.0, 
    -1.0,  1.0, 0.0, 
     1.0,  1.0, 0.0, 
     1.0, -1.0, 0.0,
]);
  
// Save the number of vertices (3)
var n = 4;

// Get the size of each float in bytes (4)
var fsize = verticesColors.BYTES_PER_ELEMENT;
var stride = 3 * fsize;

// Create a buffer object
createBuffer(gl, verticesColors);

// Bind the attribute position to the 1st, 2nd and 3rd floats in every chunk of 6 floats in the buffer
setAttrib(gl, program, 'position', 3, gl.FLOAT, stride, 0);

const interval = setInterval(() => {
    // Set the clear color
    gl.clearColor(0.0, 0.0, 0.0, 1.0);

    // Clear canvas
    gl.clear(gl.COLOR_BUFFER_BIT);

    // Update time and draw
    time += dt;
    gl.uniform1f(timeLoc, time);
    gl.drawArrays(gl.TRIANGLE_FAN, 0, n);
}, 10);

</script>
