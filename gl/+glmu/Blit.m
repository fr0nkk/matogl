function Blit(src,dst,mask,filter,src_i,src_xy0,src_xy1,dst_i,dst_xy0,dst_xy1)

if nargin < 8, dst_i = src_i; end
if nargin < 9, dst_xy0 = src_xy0; end
if nargin < 10, dst_xy1 = src_xy1; end

gl = src.gl;

if isnumeric(dst)
    src.state.framebuffer.Bind(gl.GL_DRAW_FRAMEBUFFER,dst);
else
    dst.DrawTo(dst_i);
end

src.ReadFrom(src_i);

gl.glBlitFramebuffer(src_xy0(1),src_xy0(2),src_xy1(1),src_xy1(2),...
                     dst_xy0(1),dst_xy0(2),dst_xy1(1),dst_xy1(2),...
                     mask,filter);

end

