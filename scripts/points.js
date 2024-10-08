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

var N = 100;
var x = new Float32Array(N);
var y = new Float32Array(N);
var r = new Float32Array(N);
var g = new Float32Array(N);
var b = new Float32Array(N);
var s = new Float32Array(N);

var i = 0;
var n = 1;
setInterval(() => {
    // create new points
    x[i%N] = Math.random() * 2 - 1;
    y[i%N] = Math.random() * 2 - 1;
    r[i%N] = Math.random();
    g[i%N] = Math.random();
    b[i%N] = Math.random();
    s[i%N] = 20 + 20 * Math.random();

    // draw
    gl.clear(gl.COLOR_BUFFER_BIT);

    for (let j = 0; j < n; j++) {
        gl.vertexAttrib4f(position, x[j], y[j], 0, 1);
        gl.vertexAttrib1f(size, s[j])
        gl.uniform4f(color, r[j], g[j], b[j], 1);
        gl.drawArrays(gl.POINTS, 0, 1);
    }

    console.log("i = ", i);

    i += 1;
    n = Math.max(n+1, N);

}, 200);
