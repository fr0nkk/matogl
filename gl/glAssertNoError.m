function glAssertNoError(gl)

err = gl.glGetError();
if err
    error(['GL Error 0x' dec2hex(err,4)])
end

end

