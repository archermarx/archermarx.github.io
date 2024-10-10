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

<label for="method">Generation method:</label> 
<select name = "Method" id = "method">
    <option value = "random" selected>Random</option>
    <option value = "rn">R-N</option>
</select>

<canvas id = "canvas" width = 550, height = 550</canvas>
<script src = "../scripts/webgl.js"></script>
<script>
// Create listener for the dropdown box
function changeListener() {
    var value = this.value;
    if (value === "rn") {
        gl.uniform4f(color, 0.0, 0.8, 1.0, 1.0);
    } else {
        gl.uniform4f(color, 1.0, 0.8, 0.0, 1.0);
    }
    drawPoints();
}

document.getElementById("method").onchange = changeListener;

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
gl.vertexAttrib1f(size, 10);

// Set point color
gl.uniform4f(color, 0.0, 0.8, 1.0, 1.0);

var N = 1000;
var x = new Float32Array(N);
var y = new Float32Array(N);

function drawPoints() {
    // create new points

    // draw
    gl.clear(gl.COLOR_BUFFER_BIT);

    for (let i = 0; i < N; i++) {
        x[i] = Math.random() * 2 - 1;
        y[i] = Math.random() * 2 - 1;
        gl.vertexAttrib4f(position, x[i], y[i], 0, 1);
        gl.drawArrays(gl.POINTS, 0, 1);
    }
}

changeListener();

</script>
