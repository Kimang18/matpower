function om = add_vars(om, name, idx, varargin)
%ADD_VARS  Adds a set of variables to the model.
%   OM = ADD_VARS(OM, NAME, N, V0, VL, VU)
%   OM = ADD_VARS(OM, NAME, N, V0, VL)
%   OM = ADD_VARS(OM, NAME, N, V0)
%   OM = ADD_VARS(OM, NAME, N)
%   OM = ADD_VARS(OM, NAME, DIM_LIST)
%   OM = ADD_VARS(OM, NAME, IDX_LIST, N, V0, VL, VU)
%   OM = ADD_VARS(OM, NAME, IDX_LIST, N, V0, VL)
%   OM = ADD_VARS(OM, NAME, IDX_LIST, N, V0)
%   OM = ADD_VARS(OM, NAME, IDX_LIST, N)
%   
%   Adds a set of variables to the model, where N is the number of
%   variables in the set, V0 is the initial value of those variables,
%   and VL and VU are the lower and upper bounds on the variables.
%   The defaults for the last three arguments, which are optional,
%   are for all values to be initialized to zero (V0 = 0) and unbounded
%   (VL = -Inf, VU = Inf).
%
%   Examples:
%       om = add_vars(om, 'V', nb, V0, Vmin, Vmax);
%
%       om = add_vars(om, 'x', {2, 3});
%       for i = 1:2
%         for j = 1:3
%           om = add_vars(om, 'x', {i, j}, nx(i,j), ...);
%         end
%       end
%
%   See also OPT_MODEL, GETV.

%   MATPOWER
%   $Id$
%   by Ray Zimmerman, PSERC Cornell
%   Copyright (c) 2008-2012 by Power System Engineering Research Center (PSERC)
%
%   This file is part of MATPOWER.
%   Covered by the 3-clause BSD License (see LICENSE file for details).
%   See http://matpower.org/ for more info.

%% set up default args
if iscell(idx)
    if length(varargin)
        s1 = substruct('.', name, '()', idx);
        s2 = substruct('.', name, '{}', idx);

        %% prevent duplicate named var sets
        if subsref(om.var.idx.i1, s1) ~= 0
            str = '%d'; for m = 2:length(idx), str = [str ',%d']; end
            nname = sprintf(['%s(' str, ')'], name, idx{:});
            error('@opt_model/add_vars: variable set named ''%s'' already exists', nname);
        end

        N = varargin{1};
        args = { varargin{2:end} };
    else        %% just setting dimensions for indexed set
        %% prevent duplicate named var sets
        if isfield(om.var.idx.N, name)
            error('@opt_model/add_vars: variable set named ''%s'' already exists', name);
        end

        N = -1;
        args = {};
    end
else
    %% prevent duplicate named var sets
    if isfield(om.var.idx.N, name)
        error('@opt_model/add_vars: variable set named ''%s'' already exists', name);
    end

    N = idx;
    idx = {};
    args = varargin;
end
nargs = length(args);

if N ~= -1      %% not just setting dimensions for indexed set
    v0 = []; vl = []; vu = [];
    if nargs >= 1
        v0 = args{1};
        if nargs >= 2
            vl = args{2};
            if nargs >= 3
                vu = args{3};
            end
        end
    end
    if isempty(v0)
        v0 = zeros(N, 1);   %% init to zero by default
    end
    if isempty(vl)
        vl = -Inf(N, 1);    %% unbounded below by default
    end
    if isempty(vu)
        vu = Inf(N, 1);     %% unbounded above by default
    end
end

if isempty(idx)     %% simple named set
    %% add info about this var set
    om.var.idx.i1.(name)  = om.var.N + 1;   %% starting index
    om.var.idx.iN.(name)  = om.var.N + N;   %% ending index
    om.var.idx.N.(name)   = N;              %% number of vars
    om.var.data.v0.(name) = v0;             %% initial value
    om.var.data.vl.(name) = vl;             %% lower bound
    om.var.data.vu.(name) = vu;             %% upper bound
    
    %% update number of vars and var sets
    om.var.N  = om.var.idx.iN.(name);
    om.var.NS = om.var.NS + 1;
    
    %% add to ordered list of var sets
    om.var.order(om.var.NS).name = name;
    om.var.order(om.var.NS).idx  = {};
elseif N == -1      %% just setting dimensions for indexed set
    %% add info about this var set
    om.var.idx.i1.(name)  = zeros(idx{:});  %% starting index
    om.var.idx.iN.(name)  = zeros(idx{:});  %% ending index
    om.var.idx.N.(name)   = zeros(idx{:});  %% number of vars
    om.var.data.v0.(name) = cell(idx{:});   %% initial value
    om.var.data.vl.(name) = cell(idx{:});   %% lower bound
    om.var.data.vu.(name) = cell(idx{:});   %% upper bound
else                %% indexed named set
    %% add info about this var set
    om.var.idx.i1  = subsasgn(om.var.idx.i1, s1, om.var.N + 1); %% starting index
    om.var.idx.iN  = subsasgn(om.var.idx.iN, s1, om.var.N + N); %% ending index
    om.var.idx.N   = subsasgn(om.var.idx.N,  s1, N);            %% number of vars
    om.var.data.v0 = subsasgn(om.var.data.v0, s2, v0);          %% initial value
    om.var.data.vl = subsasgn(om.var.data.vl, s2, vl);          %% lower bound
    om.var.data.vu = subsasgn(om.var.data.vu, s2, vu);          %% upper bound
    
    %% update number of vars and var sets
    om.var.N  = subsref(om.var.idx.iN, s1);
    om.var.NS = om.var.NS + 1;
    
    %% add to ordered list of var sets
    om.var.order(om.var.NS).name = name;
    om.var.order(om.var.NS).idx  = idx;
end