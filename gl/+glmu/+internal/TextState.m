classdef TextState < glmu.internal.ObjectState
    
    properties
        newFcn
        delFcn
        isInit = 0;

        FF
        RS
        RR
        TRU
        LoadedFont
    end
    
    methods
        
        function obj = New(obj)
            if obj.isInit, return, end
            obj.FF = com.jogamp.graph.font.FontFactory;
            renderMode = com.jogamp.graph.curve.Region.VARWEIGHT_RENDERING_BIT;
            
            VF = com.jogamp.graph.geom.SVertex.factory();
            obj.RS = com.jogamp.graph.curve.opengl.RenderState.createRenderState(VF);
            
            obj.RS.setHintMask(obj.RS.BITHINT_GLOBAL_DEPTH_TEST_ENABLED);
            a = com.jogamp.graph.curve.opengl.RegionRenderer.defaultBlendEnable;
            b = com.jogamp.graph.curve.opengl.RegionRenderer.defaultBlendDisable;
            obj.RR = com.jogamp.graph.curve.opengl.RegionRenderer.create(obj.RS,a,b);
            obj.TRU = com.jogamp.graph.curve.opengl.TextRegionUtil(renderMode);
            obj.RR.init(obj.gl,renderMode);
            obj.RR.enable(obj.gl,0);
            obj.isInit = 1;
        end

        function Render(obj,font,strb,sz,rgba,modelview,projection,anchor)
            F = obj.getFont(font);
            w = obj.getWidth(font,strb.array)*sz;
            M = obj.RR.getMatrix;
            M.glMatrixMode(M.GL_PROJECTION);
            M.glLoadMatrixf(javabuffer(single(projection)).p);
            M.glMatrixMode(M.GL_MODELVIEW);
            M.glLoadMatrixf(javabuffer(single(modelview * MTrans3D([-w*anchor(1) -sz*anchor(2) 0]))).p);

            if obj.RR.getRenderState.getWeight ~= 1
                obj.RR.getRenderState.setWeight(1);
            end

            obj.RR.enable(obj.gl,true);
            
            obj.RS.setColorStatic(rgba(1),rgba(2),rgba(3),rgba(4));
            obj.TRU.drawString3D(obj.gl,obj.RR,F,sz,strb.p,[],4);
            obj.RR.enable(obj.gl,false);
        end

        function w = getWidth(obj,font,str)
            [tf,k] = ismember(str,obj.LoadedFont.(font).c);
            if ~all(tf)
                F = obj.getFont(font);
                c = unique(str(~tf));
                obj.LoadedFont.(font).c = [obj.LoadedFont.(font).c c];
                obj.LoadedFont.(font).w = [obj.LoadedFont.(font).w arrayfun(@(a) F.getAdvanceWidth(F.getGlyph(a).getID,1),c)];
                [~,k] = ismember(str,obj.LoadedFont.(font).c);
            end
            w = sum(obj.LoadedFont.(font).w(k));
        end

        function F = getFont(obj,font)
            if ~isfield(obj.LoadedFont,font)
                if ispc
                    fnt = fullfile('C:\Windows\Fonts',[font '.ttf']);
                elseif isunix
                    fnt = fullfile('/usr/share/fonts', [font '.ttf']);
                end
                try
                    newF = obj.FF.get(java.io.File(fnt));
                catch
                    newF = obj.FF.get(obj.FF.JAVA).getDefault;
                end
                obj.LoadedFont.(font).java = newF;
                obj.LoadedFont.(font).c = [];
                obj.LoadedFont.(font).w = [];
            end
            F = obj.LoadedFont.(font).java;
        end

        function Delete(obj,id)
            
        end

    end
end

