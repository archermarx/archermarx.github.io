// Get the webgl rendering context
var gl = canvas.getContext('webgl');

const vshader = `
attribute vec4 position;

void main () {
    gl_Position = position;
}
`;

const fshader = `
precision mediump float;
uniform vec4 color;

void main () {
    gl_FragColor = color;
}
`;

// Compile shader program
const program = compile(gl, vshader, fshader);
const color = gl.getUniformLocation(program, 'color');

// set color
gl.uniform4f(color, 1, 0, 0, 1);

// Fill buffer with x/y/z coords and then pass to position attrib of vertex shader
const vertices = new Float32Array([
    -0.5, -0.5, 0.0, // point 1
     0.5, -0.5, 0.0, // point 2
     0.0,  0.5, 0.0, // point 3
]);

// create buffer, load data, and enable it
buffer(gl, vertices, program, 'position', 3, gl.FLOAT);

// clear canvas
gl.clearColor(0, 0, 0, 1);
gl.clear(gl.COLOR_BUFFER_BIT);

// draw triangles
gl.drawArrays(
    gl.TRIANGLES,   // mode
    0,              // start
    3,              // count
);
