classdef TextState < glmu.internal.ObjectState
    
    properties
        newFcn
        isInit = 0;

        array
        FF
        RS
        RR
        TRU
        LoadedFont
    end
    
    methods
        
        function obj = New(obj)
            if obj.isInit, return, end
            obj.array = glmu.Array;
            obj.array.Bind;
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

        function Render(obj,font,str,sz,rgba,modelview,projection)
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
                obj.LoadedFont.(font) = newF;
            end
            F = obj.LoadedFont.(font);
            obj.array.Bind;
            obj.RS.setColorStatic(rgba(1),rgba(2),rgba(3),rgba(4));
            M = obj.RR.getMatrix;
            M.glMatrixMode(M.GL_PROJECTION);
            M.glLoadMatrixf(javabuffer(single(projection)));
            if obj.RR.getRenderState.getWeight ~= 1
                obj.RR.getRenderState.setWeight(1);
            end
            M.glMatrixMode(M.GL_MODELVIEW);
            obj.RR.enable(obj.gl,true);
            for i=1:numel(str)
                M.glLoadMatrixf(javabuffer(single(modelview{i})));
                pxSz = F.getPixelSize(sz(i),72);
                obj.RS.setColorStatic(rgba(i,1),rgba(i,2),rgba(i,3),rgba(i,4));
                obj.TRU.drawString3D(obj.gl,obj.RR,F,pxSz,javabuffer(str{i}),[],4);
            end
            obj.RR.enable(obj.gl,false);
        end

        function Delete(obj,id)
            
        end

    end
end

