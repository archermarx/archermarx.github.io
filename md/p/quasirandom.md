---
pagetitle: Quasirandom sampling
bibliography: '../assets/bib/references.bib'
csl: '../assets/csl/iop-style.csl'
suppress-bibliography: false
link-citations: true
citations-hover: true
---

# Quasi-random sampling widget

This widget allows you to play around with a few different quasi-random sampling methods

<div class = "centered-block">
<label for="method">Generation method:</label> 
<select name = "Method" id = "method" autocomplete="off">
    <option value = "random" selected>Random</option>
    <option value = "rn">R-N</option>
</select>
<button type = "button" id = "generate">Generate</button>

<canvas id="canvas" width=1000 height=1000></canvas>
</div>

<script src = "../scripts/webgl.js"></script>
<script>

// Create listener for the dropdown box
function changeListener() {
    generationMethod = this.value; 
    switch(generationMethod) {
    case ("rn"):
        gl.uniform4f(color, rnColor[0], rnColor[1], rnColor[2], 1.0);
        break;
    case ("random"):
        gl.uniform4f(color, randomColor[0], randomColor[1], randomColor[2], 1.0);
        break;
    }
    drawPoints();
}

var methodSelect = document.getElementById("method");
methodSelect.onchange = changeListener;
var generationMethod = "random";
const randomColor = [0.0, 0.8, 1.0, 1.0];
const rnColor = [1.0, 0.8, 0.0, 1.0];

var generateButton = document.getElementById("generate");
generateButton.onclick = drawPoints;

// Get the webgl rendering context
var gl = canvas.getContext('webgl');

// vertex shader
var vshader = `
attribute vec4 position;
attribute float size;
void main() {
    // set vertex position
    gl_Position = position;

    // point size in pixels
    gl_PointSize = size;
}
`;

// fragment shader
var fshader = `
precision mediump float;
uniform vec4 color;

void main () {
    // make pixels rounded
    float d = distance(gl_PointCoord, vec2(0.5, 0.5));
    if (d < 0.5) {
        // set fragment color
        gl_FragColor = color;
    } else {
        discard;
    }
}
`;

program = compile(gl, vshader, fshader);

// Set the clear color (black)
gl.clearColor(0.0, 0.0, 0.0, 1.0);

// Get uniform locations
var position = gl.getAttribLocation(program, "position");
var size = gl.getAttribLocation(program, "size");
var color = gl.getUniformLocation(program, "color");

// Set point size
gl.vertexAttrib1f(size, 6);

// Set point color
gl.uniform4f(color, randomColor[0], randomColor[1], randomColor[2], 1.0);

var N = 1000;
var x = new Float32Array(N);
var y = new Float32Array(N);

// setup / rng state for R-N method
// c-f. https://extremelearning.com.au/unreasonable-effectiveness-of-quasirandom-sequences/https://extremelearning.com.au/unreasonable-effectiveness-of-quasirandom-sequences/
const g = 1.32471795724474602596;
const a1 = 1.0/g;
const a2 = 1.0/(g*g);
var count = 0;

function drawPoints() {
    gl.clear(gl.COLOR_BUFFER_BIT);
    for (let i = 0; i < N; i++) {
        switch(generationMethod) {
        case "random":
            x[i] = Math.random() * 2 - 1;
            y[i] = Math.random() * 2 - 1;
            break;
        case "rn":
            x[i] = (0.5 + a1 * count) % 1;
            y[i] = (0.5 + a2 * count) % 1;
            x[i] = 2 * x[i] - 1;
            y[i] = 2 * y[i] - 1;
            count += 1;
            break;
        }
        gl.vertexAttrib4f(position, x[i], y[i], 0, 1);
        gl.drawArrays(gl.POINTS, 0, 1);
    }
}

drawPoints();

</script>
