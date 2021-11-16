function b = glGenBuffer(fcn,nb)
% make 1 or multiple java buffers defined by fcn
% example
% b = glGenBuffer(@gl.glGenBuffers,2) : make 2 buffers

jb = javabuffer(zeros(nb,1,'int32'));
fcn(nb,jb);
b = jb.array;
end