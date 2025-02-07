---
pagetitle: Phased array simulation
bibliography: '../assets/bib/references.bib'
csl: '../assets/csl/iop-style.csl'
suppress-bibliography: false
link-citations: true
citations-hover: true
---

# Phased array simulation

The simulation below models the wave pattern created by several point sources next to each other.
By increasing the number of sources and reducing the spacing, these waves can be made to interfere with each other in such a way that they form a focused beam.
The beam can be steered by tuning the phase delay.
This arrangement of point sources used to generate a tuneable beam is known as a [phased array](https://en.wikipedia.org/wiki/Phased_array), and is widely used across many areas of technology.

This simulation also works as simple model of diffraction of a plane wave through a number of slits.
We assume the slits are infinitely thin, which allows us to model them as point sources.
The field amplitude is then just computed by summing the contribution from each slit.
This is most accurate at large distances from the point sources, and gets less accurate as we get closer to the "slits" and the point-like approximation breaks down.
For a more accurate simulation of wave propagation through a diffraction grating, see the [full diffraction grating simulation](/p/advanced-diffraction-sim) page.

<div class="centered-block">
<div class="controls">
<fieldset>
    <legend><b>Controls</b></legend>
    <div class="input-container">
        <label for="sources_input">Sources: <output id="sources_output"/></label>
        <br>
        <input type="range" id="sources_input" min="1" max="16" value="2" step="1" autocomplete="off"/>
    </div>
    <div class="input-container">
        <label for="spacing_input">Spacing: <output id = "spacing_output"/></label>
        <br>
        <input type="range" id="spacing_input" min="0" max="1" value="0.5" step="any" autocomplete="off"/>
    </div>
    <div class="input-container">
        <label for="wavenumber_input">Wavenumber: <output id="wavenumber_output"/></label>
        <br>
        <input type="range" id="wavenumber_input" min="1" max="64" value="8" step="1" autocomplete="off"/>
    </div>
    <div class="input-container">
        <label for="phase_input">Phase delay: <output id="phase_output"/></label>
        <br>
        <input type="range" id="phase_input" min="-180" max="180" value="0" step="2" autocomplete="off"/>
    </div>
</fieldset>
<fieldset>
    <legend><b>Display</b></legend>
    <div class = "input-container">
        <label for ="display_input">Field to display:</label>
        <br>
        <select name="display_input" id="display_input" autocomplete = "off">
            <option value="display-power" selected>Power</option>
            <option value="display-amplitude">Amplitude</option>
        </select>
    </div>
    <div class = "input-container">
        <label for="phase_average_input" style="float:left">Phase average:</label>
        <br>
        <input type="checkbox" id="phase_average_input" value = "phase_average" autocomplete="off"/>
    </div>
</fieldset>
</div>
<canvas id="canvas" width=600 height=800></canvas>
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
precision highp float;

uniform float width;
uniform float height;
#define PI 3.141592653589
float timefreq = 100.0;
uniform float time;
uniform float phase_delay;

#define RED vec3(162., 30., 37.) / 256.0;
#define BLUE vec3(11., 102., 188.) / 256.0;
#define WHITE vec3(1.0, 1.0, 1.0)
#define MIN_DIST 0.0125
#define BLUR_RADIUS 1.05
#define SLIT_HEIGHT 0.02

#define MAX_SOURCES 16
vec2 positions[16];

uniform int num_sources;
uniform float spacing;
uniform float wavenumber;
uniform int display_type;
uniform bool phase_average;

float colormap_f1(float x) {
    return -510.0 * x + 255.0;
}

float colormap_f2(float x) {
    return (-1891.7 * x + 217.46) * x + 255.0;
}

float colormap_f3(float x) {
    return 9.26643676359015e1 * sin((x - 4.83450094847127e-1) * 9.93) + 1.35940451627965e2;
}

float colormap_f4(float x) {
    return -510.0 * x + 510.0;
}

float colormap_f5(float x) {
    float xx = x - 197169.0 / 251000.0;
    return (2510.0 * xx - 538.31) * xx;
}

float colormap_red(float x) {
    if (x < 0.0) {
        return 1.0;
    } else if (x < 10873.0 / 94585.0) {
        float xx = colormap_f2(x);
        if (xx > 255.0) {
            return (510.0 - xx) / 255.0;
        } else {
            return xx / 255.0;
        }
    } else if (x < 0.5) {
        return 1.0;
    } else if (x < 146169.0 / 251000.0) {
        return colormap_f4(x) / 255.0;
    } else if (x < 197169.0 / 251000.0) {
        return colormap_f5(x) / 255.0;
    } else {
        return 0.0;
    }
}

float colormap_green(float x) {
    if (x < 10873.0 / 94585.0) {
        return 1.0;
    } else if (x < 36373.0 / 94585.0) {
        return colormap_f2(x) / 255.0;
    } else if (x < 0.5) {
        return colormap_f1(x) / 255.0;
    } else if (x < 197169.0 / 251000.0) {
        return 0.0;
    } else if (x <= 1.0) {
        return abs(colormap_f5(x)) / 255.0;
    } else {
        return 0.0;
    }
}

float colormap_blue(float x) {
    if (x < 0.0) {
        return 0.0;
    } else if (x < 36373.0 / 94585.0) {
        return colormap_f1(x) / 255.0;
    } else if (x < 146169.0 / 251000.0) {
        return colormap_f3(x) / 255.0;
    } else if (x <= 1.0) {
        return colormap_f4(x) / 255.0;
    } else {
        return 0.0;
    }
}

vec3 colormap(float x) {
    return vec3(colormap_red(x), colormap_green(x), colormap_blue(x));
}

float wave_amplitude(float A, float k, float phi, float x, float t) {
    float k1 = 2.0 * PI * wavenumber;
    const float vg = 1.0 / (16.0 * PI);
    float w = k1 * vg;
    
    return A * cos(k1*x - w*t + phi) / x;
}

vec3 color_amplitude(float amplitude) {
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

const float inv_log10 = 1.0 / log(10.0);
float log10(float x) {
    return inv_log10 * log(x);
}

float rescale(float x, float min, float max) {
    return (x - min) / (max - min);
}

vec3 color_power(float amplitude) {
    float power = amplitude*amplitude;
    float max_color = phase_average ? 2.2 : 2.0;
    float min_color = phase_average ? -1.5: -1.0;
    float power_db = rescale(log10(power), min_color, max_color);
    return colormap(1.0 - power_db);
}

void main () {
    // position sources
    if (num_sources == 1) {
        positions[0] = vec2(0, -0.5 * height);
    } else {
        float increment = spacing / float(num_sources-1);
        for (int i = 0; i < MAX_SOURCES; i++) {
            if (i >= num_sources) {break;}
            positions[i].x = (-0.5 * spacing + float(i)*increment) * width;
            positions[i].y = -0.45 * height;
        }
    }

    vec2 pos = gl_FragCoord.xy - vec2(width/2.0, height/2.0);

    float f = 0.0;
    float min_distance = width * height;
    float distances[MAX_SOURCES];
    for (int i = 0; i < MAX_SOURCES; i++) {
        if (i >= num_sources) {break;}
        float phi = float(i) * phase_delay * PI/180.0;
        distances[i] = distance(pos, positions[i]) / width;
        min_distance = min(min_distance,distances[i]);
        f += wave_amplitude(1.0, wavenumber, phi, distances[i], time) / float(num_sources);
    }
    if (phase_average) {
        f *= f;
        for (int j = 1; j < 4; j++) {
            float phase = PI * float(j) / 2.0;
            float a = 0.0;
            for (int i = 0; i < MAX_SOURCES; i++) {
                if (i >= num_sources) {break;}
                float phi = float(i) * phase_delay * PI/180.0;
                a += wave_amplitude(1.0, wavenumber, phi+phase, distances[i], time) / float(num_sources);
            }
            f += a*a;
        }
        f = sqrt(0.25 * f);
    }

    vec3 color;
    if (display_type == 1) {
        color = color_amplitude(f);
    } else {
        color = color_power(f);
    }

    float cutoff = BLUR_RADIUS * MIN_DIST;
    if (min_distance < MIN_DIST) {
        color = WHITE;
    } else if (min_distance < cutoff) {
        float t = (min_distance - MIN_DIST) / (cutoff - MIN_DIST);
        color = (1.0 - t) * WHITE + t * color;
    }
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
console.log(width)
console.log(height)
var widthLoc = gl.getUniformLocation(program, 'width');
var heightLoc = gl.getUniformLocation(program, 'height');
var timeLoc = gl.getUniformLocation(program, 'time');
gl.uniform1f(widthLoc, width);
gl.uniform1f(heightLoc, height);

// Set controls
var spacing_output = document.querySelector("#spacing_output");
const set_spacing_output = () => {
    let n = sources_input.value;
    if (n > 1) {
        let wavelength = 1.0 / wavenumber_input.value;
        let increment = spacing_input.value / (n - 1);
        let spacing_wavelengths = increment / wavelength;
        spacing_wavelengths = Math.round(10*spacing_wavelengths)/10;
        let s = spacing_wavelengths == 1 ? '' : 's';
        spacing_output.textContent = `${spacing_wavelengths} wavelength${s}`;
    } else {
        spacing_output.textContent = 'n/a';
    }
}
var sources_input = document.querySelector("#sources_input");
var sources_output = document.querySelector("#sources_output");
const set_sources = (val) => {
    sources_output.textContent = val;
    gl.uniform1i(gl.getUniformLocation(program, 'num_sources'), val);
    set_spacing_output();
}
sources_input.addEventListener("input", (event) => {set_sources(event.target.value)});

var wavenumber_input = document.querySelector("#wavenumber_input");
var wavenumber_output = document.querySelector("#wavenumber_output");
const set_wavenumber = (val) => {
    wavenumber_output.textContent = Math.round(10*val)/10;
    gl.uniform1f(gl.getUniformLocation(program, 'wavenumber'), val);
    set_spacing_output();
}
wavenumber_input.addEventListener("input", (event) => {set_wavenumber(event.target.value)});

var spacing_input = document.querySelector("#spacing_input");
const set_spacing = (val) => {
    gl.uniform1f(gl.getUniformLocation(program, 'spacing'), val);
    set_spacing_output();
}
spacing_input.addEventListener("input", (event) => {set_spacing(event.target.value)});

var phase_input = document.querySelector("#phase_input");
var phase_output = document.querySelector("#phase_output");
const set_phase = (val) => {
    phase_output.textContent = `${Math.round(10*val)/10} deg`;
    gl.uniform1f(gl.getUniformLocation(program, 'phase_delay'), val);
}
phase_input.addEventListener("input", (event) => {set_phase(event.target.value)});

var display_input = document.querySelector("#display_input");
const set_display_type = (val) => {
    if (val === 'display-amplitude') {
        gl.uniform1i(gl.getUniformLocation(program, 'display_type'), 1);
    } else {
        gl.uniform1i(gl.getUniformLocation(program, 'display_type'), 0);
    }
}
display_input.addEventListener("input", (event) => {set_display_type(event.target.value)});

var phase_average_input = document.querySelector("#phase_average_input");
const set_phase_average = (val) => {
    gl.uniform1i(gl.getUniformLocation(program, 'phase_average'), phase_average_input.checked);
}
phase_average_input.addEventListener("input", (event) => {set_phase_average(event.target.value)});

set_sources(sources_input.value);
set_display_type(display_input.value);
set_phase(phase_input.value);
set_spacing(spacing_input.value);
set_wavenumber(wavenumber_input.value);

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
