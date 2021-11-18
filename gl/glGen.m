function b = glGen(fcn,nb)
% make 1 or multiple gl buffers defined by fcn
% example
% b = glGen(@gl.glGenBuffers,2) : make 2 buffers

jb = javabuffer(zeros(nb,1,'int32'));
fcn(nb,jb);
b = jb.array;
end