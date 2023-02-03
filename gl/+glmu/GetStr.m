function str = GetStr(gl,getfcn,args,inLen,inLenPos,outLenPos,strPos)

args{inLenPos} = inLen;
outLen = javabuffer(0,'int32');
args{outLenPos} = outLen.p;
strb = javabuffer(zeros(1,inLen,'uint8'));
args{strPos} = strb.p;

getfcn(gl,args{:});
str = char(strb.array(1:outLen.array));

end


