function S = State(gl)

persistent states
if isempty(states)
    states = {'gl' 'state'};
end

if nargin == 0, gl = glmu.internal.getgl; end

if isjava(gl)
    tf = [false ; cellfun(@(c) gl == c, states(2:end,1))];
    if any(tf)
        S = states{tf,2};
    else
        S = glmu.internal.State;
        states(end+1,:) = {gl S};
    end
else
    if gl
        % cleanup
        tf = [true ; cellfun(@(c) c.getContext.isCreated,states(2:end,1))];
        states = states(tf,:);
    end
    S = states;
end
    
    


end

