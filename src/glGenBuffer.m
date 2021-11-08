function b = glGenBuffer(fcn,nb)
    jb = javabuffer(zeros(nb,1,'int32'));
    fcn(nb,jb);
    b = jb.array;
end