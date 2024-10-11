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
<input type="range" id="sources_input" min="2" max="16" value="3" step="1" autocomplete="off"/>
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
<div class = "controls">
<div>
<input type="range" id="sourcedist_input" min="0.15" max="5" value="2.5" step="any" autocomplete="off"/>
<label for="sourcedist_input">Source distance: <output id="sourcedist_output"/></label>
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
float max_x;
float grating_y = -0.25;

uniform int num_slits;
uniform float spacing;
uniform float slit_width;
uniform float wavenumber;
uniform float source_distance;

#define MAX_RAYS 100

float wave_amplitude(vec2 pos, vec2 sourcePos, float t) {
    float r = distance(pos, sourcePos) / width;
    return sin(t - 2.0*PI * wavenumber * r);
}

float cast_rays(vec2 pos, vec2 sourcePos) {
    float amplitude = 0.0;

    float x = pos.x;
    float y = pos.y;
    float w = 0.5 * slit_width * spacing / float(num_slits - 1); 
    float dy = y - grating_y*height;
    float dx_min = pos.x - (centers[0] - w) * width;
    float dx_max = pos.x - (max_x + w) * width;
    float theta_min = atan(dy, -dx_max);
    float theta_max = atan(dy, -dx_min);

   // float theta_min = 0.0;
   // float theta_max = PI;
    float dtheta = (theta_max - theta_min) / float(MAX_RAYS);
    float frac = (theta_max - theta_min) / PI;

    float num_hits = 0.0;

    for (int i = 0; i < MAX_RAYS; i++) {
        float theta = theta_min + (float(i)+0.5) * dtheta;
        // check here for sign convention
        vec2 ray = vec2(cos(theta), sin(theta));

        // find intercept location 
        float t = dy / ray.y;
        float ix = (pos.x + ray.x*t)/width;
        
        // determine if there is a slit there
        for (int i = 0; i < MAX_SLITS; i++) {
            if (i >= num_slits) {break;}
            if (ix > centers[i] - w && ix < centers[i] + w) {
                vec2 rayPos = vec2(ix*width, grating_y*height);
                float dist = distance(rayPos, pos);
                float group_vel = 1.0 / (2.0 * PI * wavenumber / width);
                float time_delay = dist / group_vel;
                amplitude += wave_amplitude(rayPos, sourcePos, time - time_delay);
                num_hits += 1.0;
                break;
            }
        }
    }
    return amplitude / float(num_hits);
}

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

vec3 draw_grate(vec3 base, vec2 pos) {
    float x = pos.x / width;
    float y = pos.y / height;
    float w = 0.5 * slit_width * spacing / float(num_slits - 1); 
    float grating_thickness = 0.01;

    if (y < (grating_y - grating_thickness / 2.0) ||
        y > (grating_y + grating_thickness / 2.0)) {
        return base;
    }

    for (int i = 0; i <= MAX_SLITS; i++) {
        if (i >= num_slits) {break;}
        if (x >= centers[i] - w && x <= centers[i] + w) {
            return base;
        }  
    }
    return WHITE;
}

vec3 draw_base(vec2 pos, vec2 sourcePos) {
    float x = pos.x / width;
    float y = pos.y / height;

    // draw region downstream of grating
    if (y > grating_y) {
        return wave_color(cast_rays(pos, sourcePos));
    }

    vec3 color = wave_color(wave_amplitude(pos, sourcePos, time));
    return color;
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
            max_x = centers[i];
        }
    }

    vec2 pos = gl_FragCoord.xy - vec2(width/2.0, height/2.0);
    vec2 sourcePos = vec2(0.0, -source_distance * width + grating_y * height);

    vec3 color = draw_grate(draw_base(pos, sourcePos), pos);   
    gl_FragColor = vec4(color, 1.0);
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
}
spacing_input.addEventListener("input", (event) => {set_spacing(event.target.value)});

var slitwidth_input = document.querySelector("#slitwidth_input");
set_slitwidth = (val) => {
    gl.uniform1f(gl.getUniformLocation(program, 'slit_width'), val);
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

var sourcedist_input = document.querySelector("#sourcedist_input");
var sourcedist_output = document.querySelector("#sourcedist_output");
set_sourcedist = (val) => {
    sourcedist_output.textContent = Math.round(100*val)/100;
    gl.uniform1f(gl.getUniformLocation(program, 'source_distance'), val);
}
sourcedist_input.addEventListener("input", (event) => {set_sourcedist(event.target.value)});

// initialize controls
set_spacing(spacing_input.value);
set_slitwidth(slitwidth_input.value);
set_wavenumber(wavenumber_input.value);
set_sources(sources_input.value);
set_sourcedist(sourcedist_input.value);

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
