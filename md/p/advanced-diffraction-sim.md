---
pagetitle: Diffraction simulation
bibliography: '../assets/bib/references.bib'
csl: '../assets/csl/iop-style.csl'
suppress-bibliography: false
link-citations: true
citations-hover: true
---

# Diffraction grating simulation

Below is a simulation of a linearly-polarized wave emanating from a point source at (X, Y) passing through a diffraction grating.
You can vary several parameters to see how the interference pattern on the other end of the grating changes.

<div class="centered-block">
<div class="controls">
<fieldset>
    <legend><b>Source</b></legend>
    <div class = "input-container">
        <label for="source_x_input">X position: <output id="source_x_output"/></label>
        <input type="range" id="source_x_input" min="-8" max="8" value="0" step="0.1" autocomplete="off"/>
    </div>
        <div class = "input-container">
        <label for="source_y_input">Y position: <output id="source_y_output"/></label>
        <input type="range" id="source_y_input" min="-10" max="-0.1" value="-3" step="0.1" autocomplete="off"/>
    </div>
    <div class = "input-container">
        <label for="wavenumber_input">Wavenumber: <output id="wavenumber_output"/></label>
        <input type="range" id="wavenumber_input" min="1" max="64" value="8" step="1" autocomplete="off"/>
    </div>
</fieldset>
<fieldset>
    <legend><b>Grating</b></legend>
    <div class = "input-container">
        <label for="numslits_input">Slits: <output id="numslits_output"/></label>
        <input type="range" id="numslits_input" min="1" max="16" value="2" step="1" autocomplete="off"/>
    </div>
    <div class = "input-container">
        <label for="slitwidth_input">Slit width: <output id = "slitwidth_output"/></label>
        <input type="range" id="slitwidth_input" min="0.01" max="0.95" value="0.02" step="0.005" autocomplete="off"/>
    </div>
    <div class = "input-container">
        <label for="spacing_input">Spacing: <output id = "spacing_output"/></label>
        <input type="range" id="spacing_input" min="0" max="1" value="0.5" step="0.01" autocomplete="off"/>
    </div>
    <div class = "input-container">
        <label for="position_input">Y position: <output id="position_output"/></label>
        <input type="range" id="position_input" min="-0.5" max="0.0" value="-0.3" step="any" autocomplete="off"/>
    </div>
</fieldset>
<fieldset>
    <legend><b>Display</b></legend>
    <div class = "input-container">
        <label for="gain_input">Gain: <output id="gain_output"/></label>
        <input type="range" id="gain_input" min="0.5" max="10" value="1" step="0.1" autocomplete="off"/>
    </div>
    <div class = "input-container">
        <label for="rays_input">Rays/slit/pixel: <output id="rays_output"/></label>
        <input type="range" id="rays_input" min="1" max="25" value="5" step="1" autocomplete="off"/>
    </div>
    <div class = "input-container">
        <label for ="display_input">Field to display:</label>
        <select name="display_input" id="display_input" autocomplete = "off">
            <option value="display-power" selected>Power</option>
            <option value="display-amplitude">Amplitude</option>
        </select>
    </div>
    <div class = "input-container">
        <label for="phase_average_input" style="float:left">Phase average:</label>
        <input type="checkbox" id="phase_average_input" value = "phase_average" autocomplete="off"/>
    </div>
</fieldset>
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
precision highp float;

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

uniform float grating_y;
uniform int num_slits;
uniform float spacing;
uniform float slit_width;
uniform float wavenumber;
uniform float source_x;
uniform float source_y;
uniform float gain;
uniform int display_type;

uniform bool phase_average;

#define MAX_RAYS 200
uniform int num_rays;

float wave_amplitude(vec2 pos, vec2 sourcePos, float k, float t, float phi, float dist) {
    float x = (distance(pos, sourcePos) + dist) / width;
    float k1 = 2.0 * PI * wavenumber;
    const float vg = 1.0 / (16.0 * PI);
    float w = k1 * vg;

    float A = gain * 2.0 * abs(sourcePos.y/height - grating_y);

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

const float inv_log10 = 1.0 / log(10.0);
float log10(float x) {
    return inv_log10 * log(x);
}

float rescale(float x, float min, float max) {
    return (x - min) / (max - min);
}

vec3 color_power(float amplitude) {
    float power = amplitude*amplitude;
    float max_color = phase_average ? 0.5 : 0.75;
    float min_color = phase_average ? -1.5: -0.5;
    float power_db = rescale(log10(power), min_color, max_color);
    return colormap(1.0 - power_db);
}

vec3 wave_color(float amplitude) {
    if (display_type == 1) {
        return color_amplitude(amplitude);
    } else {
        return color_power(amplitude);
    }
}

float get_width() {
    if (num_slits > 1) {
        return 0.5 * slit_width * spacing / float(num_slits - 1);
    } else {
        return 0.5 * slit_width;
    }
}


float cast_rays(vec2 pos, vec2 sourcePos, float phi) {
    float x = pos.x;
    float y = pos.y;

    if (y/height < grating_y) {
        return wave_amplitude(pos, sourcePos, wavenumber, time, phi, 0.0);
    }

    float w = get_width();
    float dy = y - grating_y*height;

    float amplitude = 0.0;

    // iterate over slits
    float num_hits = 0.0;
    float total_angle = 0.0;

    for (int i = 0; i < MAX_SLITS; i++) {
        if (i >= num_slits) {break;}
        
        float dx_min = pos.x - (centers[i] - w) * width;
        float dx_max = pos.x - (centers[i] + w) * width;
        float theta_min = atan(dy, -dx_max);
        float theta_max = atan(dy, -dx_min);
        float angle_frac = theta_max - theta_min;
        total_angle += angle_frac;
        float dtheta = angle_frac / float(num_rays);

        for (int i = 0; i < MAX_RAYS; i++) {
            if (i >= num_rays) {break;}
            float theta = theta_min + (float(i)+0.5) * dtheta;
            // check here for sign convention
            vec2 ray = vec2(cos(theta), sin(theta));

            // find intercept location 
            float t = dy / ray.y;
            float ix = (pos.x + ray.x*t)/width;
                
            // Get wave amplitude here
            vec2 rayPos = vec2(ix*width, grating_y*height);
            float dist = distance(rayPos, pos);
            float a = wave_amplitude(rayPos, sourcePos, wavenumber, time, phi, dist);
            amplitude += a * dtheta;
        }
    }

    return amplitude / total_angle;
}


vec3 draw_grate(vec3 base, vec2 pos) {
    float x = pos.x / width;
    float y = pos.y / height;
    float w = get_width(); 
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
    float amplitude = cast_rays(pos, sourcePos, 0.0);
    if (phase_average) {
        amplitude *= amplitude;
        for (int i = 1; i < 4; i++) {
            float a = cast_rays(pos, sourcePos, 2.0 * PI * float(i) / 4.0);
            amplitude += a*a;
        }
        amplitude = sqrt(amplitude/4.0);
    }

    return wave_color(amplitude);
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
    vec2 sourcePos = vec2(source_x * width, source_y * width + grating_y * height);

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
var spacing_output = document.querySelector("#spacing_output");
const set_spacing_output = () => {
    let n = numslits_input.value;
    if (n > 1 ) {
        let wavelength = 1.0 / wavenumber_input.value;
        let increment = spacing_input.value / Math.max(numslits_input.value - 1, 1);
        let spacing_wavelengths = increment / wavelength;
        spacing_wavelengths = Math.round(10*spacing_wavelengths)/10;
        let s = spacing_wavelengths == 1 ? '' : 's';
        spacing_output.textContent = `${spacing_wavelengths} wavelength${s}`;
    } else {
        spacing_output.textContent = "n/a";
    }
}

var slitwidth_output = document.querySelector("#slitwidth_output");
const set_slitwidth_output = () => {
    let n = numslits_input.value;
    let wavelength = 1.0 / wavenumber_input.value;
    let increment = slitwidth_input.value;
    if (n > 1) {
        increment = spacing_input.value * slitwidth_input.value / (n-1);
    }
    let spacing_wavelengths = increment / wavelength;
    spacing_wavelengths = Math.round(20*spacing_wavelengths)/20;
    let s = spacing_wavelengths == 1 ? '' : 's';
    slitwidth_output.textContent = `${spacing_wavelengths} wavelength${s}`
;
}

var spacing_input = document.querySelector("#spacing_input");
set_spacing = (val) => {
    gl.uniform1f(gl.getUniformLocation(program, 'spacing'), val);
    set_spacing_output();
}
spacing_input.addEventListener("input", (event) => {set_spacing(event.target.value)});

var slitwidth_input = document.querySelector("#slitwidth_input");
set_slitwidth = (val) => {
    gl.uniform1f(gl.getUniformLocation(program, 'slit_width'), val);
    set_slitwidth_output();
}
slitwidth_input.addEventListener("input", (event) => {set_slitwidth(event.target.value)});

var wavenumber_input = document.querySelector("#wavenumber_input");
var wavenumber_output = document.querySelector("#wavenumber_output");
set_wavenumber = (val) => {
    wavenumber_output.textContent = Math.round(10*val)/10;
    gl.uniform1f(gl.getUniformLocation(program, 'wavenumber'), val);
    set_spacing_output();
    set_slitwidth_output();
}
wavenumber_input.addEventListener("input", (event) => {set_wavenumber(event.target.value)});

var gain_input = document.querySelector("#gain_input");
var gain_output = document.querySelector("#gain_output");
set_gain = (val) => {
    gain_output.textContent = Math.round(10*val)/10;
    gl.uniform1f(gl.getUniformLocation(program, 'gain'), val);
    set_spacing_output();
    set_slitwidth_output();
}
gain_input.addEventListener("input", (event) => {set_gain(event.target.value)});

var numslits_input = document.querySelector("#numslits_input");
var numslits_output = document.querySelector("#numslits_output");
set_numslits = (val) => {
    numslits_output.textContent = val;
    gl.uniform1i(gl.getUniformLocation(program, 'num_slits'), val);
    set_spacing_output();
}
numslits_input.addEventListener("input", (event) => {set_numslits(event.target.value)});

var source_x_input = document.querySelector("#source_x_input");
var source_x_output = document.querySelector("#source_x_output");
set_source_x = (val) => {
    source_x_output.textContent = Math.round(100*val)/100;
    gl.uniform1f(gl.getUniformLocation(program, 'source_x'), val);
}
source_x_input.addEventListener("input", (event) => {set_source_x(event.target.value)});

var source_y_input = document.querySelector("#source_y_input");
var source_y_output = document.querySelector("#source_y_output");
set_source_y = (val) => {
    source_y_output.textContent = Math.round(100*val)/100;
    gl.uniform1f(gl.getUniformLocation(program, 'source_y'), val);
}
source_y_input.addEventListener("input", (event) => {set_source_y(event.target.value)});

var rays_input = document.querySelector("#rays_input");
var rays_output = document.querySelector("#rays_output");
set_rays = (val) => {
    rays_output.textContent = val;
    gl.uniform1i(gl.getUniformLocation(program, 'num_rays'), val);
}
rays_input.addEventListener("input", (event) => {set_rays(event.target.value)});

var position_input = document.querySelector("#position_input");
var position_output = document.querySelector("#position_output");
set_position = (val) => {
    position_output.textContent = Math.round(10*val)/10;
    gl.uniform1f(gl.getUniformLocation(program, 'grating_y'), val);
}
position_input.addEventListener("input", (event) => {set_position(event.target.value)});

var display_input = document.querySelector("#display_input");
set_display_type = (val) => {
    if (val === 'display-amplitude') {
        gl.uniform1i(gl.getUniformLocation(program, 'display_type'), 1);
    } else {
        gl.uniform1i(gl.getUniformLocation(program, 'display_type'), 0);
    }
}
display_input.addEventListener("input", (event) => {set_display_type(event.target.value)});
set_display_type(display_input.value);

var phase_average_input = document.querySelector("#phase_average_input");
set_phase_average = (val) => {
    gl.uniform1i(gl.getUniformLocation(program, 'phase_average'), phase_average_input.checked);
}
phase_average_input.addEventListener("input", (event) => {set_phase_average(event.target.value)});

// initialize controls
set_spacing(spacing_input.value);
set_slitwidth(slitwidth_input.value);
set_wavenumber(wavenumber_input.value);
set_gain(gain_input.value);
set_numslits(numslits_input.value);
set_source_x(source_x_input.value);
set_source_y(source_y_input.value);
set_rays(rays_input.value);
set_position(position_input.value);

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
