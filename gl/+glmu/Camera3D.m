classdef Camera3D < glmu.internal.Base
    
    properties
        viewParams = struct('O',[0 0 0]','R',[-45 0 -45]','T',[0 0 -1]');
        MView % 4x4 matrix
        viewUni % glmu.Uniform

        projParams = struct('size',[500 500],'near',0.01,'far',100,'F',1);
        MProj % 4x4 matrix
        projUni % glmu.Uniform

        click = struct('button',false(1,3));
    end

    properties(Hidden)
        MProj_need_recalc = 1
        MView_need_recalc = 1
    end
    
    methods
        function obj = Camera3D(projUni,viewUni)
            obj.projUni = projUni;
            obj.viewUni = viewUni;
        end

        function Update(obj)
            obj.projUni.Set(obj.MProj);
            obj.viewUni.Set(obj.MView);
        end

        function SetNearFar(obj,near,far)
            obj.projParams.near = near;
            obj.projParams.far = far;
            obj.MProj_need_recalc = 1;
        end

        function Resize(obj,sz)
            obj.projParams.size = sz;
        end

        function M = get.MProj(obj)
            if obj.MProj_need_recalc
                p = obj.projParams;
                obj.MProj = MProj3D('P',[[p.size/mean(p.size) p.F].*p.near p.far]);
                obj.MProj_need_recalc = 0;
            end
            M = obj.MProj;
        end

        function M = get.MView(obj)
            if obj.MView_need_recalc
                v = obj.viewParams;
                obj.MView =  MTrans3D(v.T) * MRot3D(v.R,1,[1 2 3]) * MTrans3D(-v.O);
                obj.MView_need_recalc = 0;
            end
            M = obj.MView;
        end
        
        function MousePressed(obj,evt)
            obj.click.view = obj.viewParams;
            obj.click.proj = obj.projParams;
            obj.click.coords = getEvtXY(evt);
            obj.click.button(evt.getButton) = 1;
        end

        function MouseReleased(obj,evt)
            obj.click.button(evt.getButton) = 0;
        end

        function dxy = GetDxy(obj,evt)
            dxy = getEvtXY(evt) - obj.click.coords;
        end

        function MouseDragged(obj,evt)
            if ~any(obj.click.button), return, end
            dxy = obj.GetDxy(evt);
            mod = evt.getModifiers;
            ctrlPressed = bitand(mod,evt.CTRL_MASK);

            if obj.click.button(1)
                obj.viewParams.R([3 1]) = obj.click.view.R([3 1])+dxy*0.2;
                obj.MView_need_recalc = 1;
            end

            if obj.click.button(2)
                if ctrlPressed
                    % focal length: half or double per 500 px
                    s = 2^(dxy(2)./500);
                    obj.projParams.F = obj.click.proj.F * s;
                    obj.MProj_need_recalc = 1;
                else
                    % zoom: half or double cam distance from O per 100 px
                    s = 2^(dxy(2)./100);
                    obj.viewParams.T = obj.click.view.T .* s;
                    obj.MView_need_recalc = 1;
                end
            end

            if obj.click.button(3)
                % right click
                % translate 1:1 (clicked point follows mouse)
                v = obj.click.view;
                p = obj.projParams;
                dxy = dxy.*[1 -1]';
                obj.viewParams.T([1 2]) = v.T([1 2])+dxy./mean(p.size).*-v.T(3)./p.F;
                obj.MView_need_recalc = 1;
            end
            
        end

        function MouseWheelMoved(obj,evt)
            s = evt.getUnitsToScroll / 40;
            obj.viewParams.T = obj.viewParams.T .* (1+s);
            obj.MView_need_recalc = 1;
        end

        function SetRotationOrigin(obj,coord)
            if isempty(coord), return, end
            v = obj.viewParams;
            M =  MTrans3D(v.T) * MRot3D(v.R,1,[1 2 3]);
            camTranslate = M * [coord-v.O ; 1];
            obj.viewParams.T = camTranslate(1:3);
            obj.viewParams.O = coord;
            obj.MView_need_recalc = 1;
        end
    end
end

function xy = getEvtXY(evt)
    xy = [evt.getX evt.getY]';
end

