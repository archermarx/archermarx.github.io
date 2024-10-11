compile = (gl, vshader, fshader) => {
    // compile the vertex shader
    var vs = gl.createShader(gl.VERTEX_SHADER);
    gl.shaderSource(vs, vshader);
    gl.compileShader(vs);

    // compile the fragment shader
    var fs = gl.createShader(gl.FRAGMENT_SHADER);
    gl.shaderSource(fs, fshader);
    gl.compileShader(fs);

    // create shader program and use it
    var program = gl.createProgram();
    gl.attachShader(program, vs);
    gl.attachShader(program, fs);
    gl.linkProgram(program);
    gl.useProgram(program);

    // log compilation errors, if any
    console.log('vertex shader: ', gl.getShaderInfoLog(vs) || 'OK');
    console.log('fragment shader: ', gl.getShaderInfoLog(fs) || 'OK');
    console.log('shader program: ', gl.getProgramInfoLog(program) || 'OK');

    return program;
}

createBuffer = (gl, data) => {
    gl.bindBuffer(gl.ARRAY_BUFFER, gl.createBuffer());
    gl.bufferData(gl.ARRAY_BUFFER, data, gl.STATIC_DRAW);
}

setAttrib = (gl, program, attribute, size, type, stride, offset) => {
    var attr = gl.getAttribLocation(program, attribute);
    gl.vertexAttribPointer(
      attr,     // target
      size,     // interleaved data size
      gl.FLOAT, // type
      false,    // normalize
      stride,   // stride (chunk size)
      offset    // offset (position of interleaved data in chunk) 
    );
    gl.enableVertexAttribArray(attr);
}
