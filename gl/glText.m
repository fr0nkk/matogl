classdef glText < handle
    
    properties
        LoadedFont
        FF
        RS
        TRU
        RR
        VAO
        shaders
        
    end
    
    methods
        function obj = glText(gl,shaders)
            import com.jogamp.graph.*;
            obj.shaders=shaders;
            obj.VAO = glGenBuffer(@gl.glGenVertexArrays,1);
            gl.glBindVertexArray(obj.VAO);
            obj.FF = font.FontFactory;
            renderMode = curve.Region.VARWEIGHT_RENDERING_BIT;
            
            VF = geom.SVertex.factory();
            obj.RS = curve.opengl.RenderState.createRenderState(VF);
            
            obj.RS.setHintMask(obj.RS.BITHINT_GLOBAL_DEPTH_TEST_ENABLED);
            a = curve.opengl.RegionRenderer.defaultBlendEnable;
            b = curve.opengl.RegionRenderer.defaultBlendDisable;
            obj.RR = curve.opengl.RegionRenderer.create(obj.RS,a,b);
            obj.TRU = curve.opengl.TextRegionUtil(renderMode);
            obj.RR.init(gl,renderMode);
            obj.RR.enable(gl,0);
        end
        
        function Reshape(obj,sz,near,far,ang)
            sz = int32(sz);
            if nargin < 5
                obj.RR.reshapeOrtho(sz(1),sz(2),near,far);
            else
                obj.RR.reshapePerspective(ang,sz(1),sz(2),near,far);
            end
        end
        
        function Render(obj,gl,font,str,sz,rgba,transf)
            if ~isfield(obj.LoadedFont,font)
                if ~endsWith(font,'.ttf')
                    fnt = ['C:\Windows\Fonts\' font '.ttf'];
                end
                assert(logical(exist(fnt,'file')),['font not found: ' fnt])
                obj.LoadedFont.(font) = obj.FF.get(java.io.File(fnt));
            end
            gl.glBindVertexArray(obj.VAO);
            obj.RS.setColorStatic(rgba(1),rgba(2),rgba(3),rgba(4));
            F = obj.LoadedFont.(font);
%             b = obj.newBuffer(str);
            str = javabuffer(str);
%             newLineCount = obj.TRU.getCharCount(str,newline);
%             lineHeight = F.getLineHeight(sz);
%             offsetX = -30 + F.getAdvanceWidth(int32('X'),sz);
%             offsetY = 30 - lineHeight * newLineCount;
            M = obj.RR.getMatrix;
            M.glMatrixMode(M.GL_MODELVIEW);
            M.glLoadMatrixf(javabuffer(transf));
            if obj.RR.getRenderState.getWeight ~= 1
                obj.RR.getRenderState.setWeight(1);
            end
            pxSz = F.getPixelSize(sz,72);
            obj.RR.enable(gl,true);
            obj.TRU.drawString3D(gl,obj.RR,F,pxSz,str,rgba,4);
            obj.RR.enable(gl,false);
            obj.shaders.lastProg = 0;
        end
    end
end

