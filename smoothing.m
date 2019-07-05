function c = smoothing(y, span, method)
y = y(:);
x = (1:length(y))';

t = length(y);
if span < 1, span = ceil(span*t); end % percent convention

idx = 1:t;

sortx = any(diff(isnan(x))<0);   % if NaNs not all at end
if sortx || any(diff(x)<0) % sort x
    [x,idx] = sort(x);
    y = y(idx);
end

c = NaN(size(y));
ok = ~isnan(x);

robust = 0;
iter = 5;
if method(1)=='r'
	robust = 1;
	method = method(2:end);
end
c(ok) = lowess(x(ok), y(ok), span, method, robust, iter);

c(idx) = c;
end

%--------------------------------------------------------------------
function c = lowess(x,y, span, method, robust, iter)
% LOWESS  Smooth data using Lowess or Loess method.
%
% The difference between LOWESS and LOESS is that LOWESS uses a
% linear model to do the local fitting whereas LOESS uses a
% quadratic model to do the local fitting. Some other software
% may not have LOWESS, instead, they use LOESS with order 1 or 2 to
% represent these two smoothing methods.
%
% Reference: 
% [C79] W.S.Cleveland, "Robust Locally Weighted Regression and Smoothing
%    Scatterplots", _J. of the American Statistical Ass._, Vol 74, No. 368 
%    (Dec.,1979), pp. 829-836.
%    http://www.math.tau.ac.il/~yekutiel/MA%20seminar/Cleveland%201979.pdf

n = length(y);
span = floor(span);
span = min(span,n);
c = y;
if span == 1
    return;
end

useLoess = false;
if isequal(method,'loess')
    useLoess = true;
end

diffx = diff(x);

% For problems where x is uniform, there's a faster way
isuniform = uniformx(diffx,x,y);
if isuniform
    % For uniform data, an even span actually covers an odd number of
    % points.  For example, the four closest points to 5 in the
    % sequence 1:10 are {3,4,5,6}, but 7 is as close as 3.
    % Therefore force an odd span.
    span = 2*floor(span/2) + 1;

    c = unifloess(y,span,useLoess);
    if ~robust || span<=2
        return;
    end
end

ynan = isnan(y);
anyNans = any(ynan(:));
seps = sqrt(eps);
theDiffs = [1; diffx; 1];

if isuniform
    % We've already computed the non-robust smooth, so in preparation for
    % the robust smooth, compute the following arrays directly
    halfw = floor(span/2);
    
    % Each local interval is from |halfw| below the current index to |halfw|
    % above
    lbound = (1:n)-halfw;
    rbound = (1:n)+halfw;
    % However, there always has to be at least |span| points to the right of the
    % left bound
    lbound = min( n+1-span, lbound );
    % ... and at least |span| points to the left of the right bound
    rbound = max( span, rbound );
    % Furthermore, because these bounds index into vectors of length n, they
    % must contain valid indices
    lbound = max( 1, lbound );
    rbound = min( n, rbound );
    
    % Since the input is uniform we can use natural numbers for the input when
    % we need them.
    x = (1:numel(x))';
else
    if robust
        % pre-allocate space for lower and upper indices for each fit,
        % to avoid re-computing this information in robust iterations
        lbound = zeros(n,1);
        rbound = zeros(n,1);
    end

    % Compute the non-robust smooth for non-uniform x
    for i=1:n
        % if x(i) and x(i-1) are equal we just use the old value.
        if theDiffs(i) == 0
            c(i) = c(i-1);
            if robust
                lbound(i) = lbound(i-1);
                rbound(i) = rbound(i-1);
            end
            continue;
        end
        
        % Find nearest neighbours
        idx = iKNearestNeighbours( span, i, x, ~ynan );
        if robust
            % Need to store neighborhoods for robust loop
            lbound(i) = min(idx);
            rbound(i) = max(idx);
        end
        
        if isempty(idx)
            c(i) = NaN;
            continue
        end

        x1 = x(idx)-x(i); % center around current point to improve conditioning
        d1 = abs(x1);
        y1 = y(idx);

        weight = iTricubeWeights( d1 );
        if all(weight<seps)
            weight(:) = 1;    % if all weights are 0, just skip weighting
        end

        v = [ones(size(x1)) x1];
        if useLoess
            v = [v x1.*x1]; %#ok<AGROW> There is no significant growth here
        end
        
        v = weight(:,ones(1,size(v,2))).*v;
        y1 = weight.*y1;
        if size(v,1)==size(v,2)
            % Square v may give infs in the \ solution, so force least squares
            b = [v;zeros(1,size(v,2))]\[y1;0];
        else
            b = v\y1;
        end
        c(i) = b(1);
    end
end

% now that we have a non-robust fit, we can compute the residual and do
% the robust fit if required
maxabsyXeps = max(abs(y))*eps;
if robust
    for k = 1:iter
        r = y-c;
        
        % Compute robust weights
        rweight = iBisquareWeights( r, maxabsyXeps ); 
        
        % Find new value for each point.
        for i=1:n
            if i>1 && x(i)==x(i-1)
                c(i) = c(i-1);
                continue;
            end
            if isnan(c(i)), 
                continue; 
            end
            
            idx = lbound(i):rbound(i);
            if anyNans
                idx = idx(~ynan(idx));
            end
            % check robust weights for removed points
            if any( rweight(idx) <= 0 )
                idx = iKNearestNeighbours( span, i, x, (rweight > 0) );
            end
            
            x1 = x(idx) - x(i);
            d1 = abs(x1);
            y1 = y(idx);

            weight = iTricubeWeights( d1 );
            if all(weight<seps)
                weight(:) = 1;    % if all weights 0, just skip weighting
            end

            v = [ones(size(x1)) x1];
            if useLoess
                v = [v x1.*x1]; %#ok<AGROW> There is no significant growth here
            end
            
            % Modify the weights based on x values by multiplying them by
            % robust weights.
            weight = weight.*rweight(idx);
            
            v = weight(:,ones(1,size(v,2))).*v;
            y1 = weight.*y1;
            if size(v,1)==size(v,2)
                % Square v may give infs in the \ solution, so force least squares
                b = [v;zeros(1,size(v,2))]\[y1;0];
            else
                b = v\y1;
            end
            c(i) = b(1);
        end
    end
end
end

% --------------------------------------------
function ys = unifloess(y,span,useLoess)
%UNIFLOESS Apply loess on uniformly spaced X values

y = y(:);

% Omit points at the extremes, which have zero weight
halfw = (span-1)/2;              % halfwidth of entire span
d = abs((1-halfw:halfw-1));      % distances to pts with nonzero weight
dmax = halfw;                    % max distance for tri-cubic weight

% Set up weighted Vandermonde matrix using equally spaced X values
x1 = (2:span-1)-(halfw+1);
weight = (1 - (d/dmax).^3).^1.5; % tri-cubic weight
v = [ones(length(x1),1) x1(:)];
if useLoess
    v = [v x1(:).^2];
end
V = v .* repmat(weight',1,size(v,2));

% Do QR decomposition
[Q,nouse] = qr(V,0);

% The projection matrix is Q*Q'.  We want to project onto the middle
% point, so we can take just one row of the first factor.
alpha = Q(halfw,:)*Q';

% This alpha defines the linear combination of the weighted y values that
% yields the desired smooth values.  Incorporate the weights into the
% coefficients of the linear combination, then apply filter.
alpha = alpha .* weight;
ys = filter(alpha,1,y);

% We need to slide the values into the center of the array.
ys(halfw+1:end-halfw) = ys(span-1:end-1);

% Now we have taken care of everything except the end effects.  Loop over
% the points where we don't have a complete span.  Now the Vandermonde
% matrix has span-1 points, because only 1 has zero weight.
x1 = 1:span-1;
v = [ones(length(x1),1) x1(:)];
if useLoess
    v = [v x1(:).^2];
end
for j=1:halfw
    % Compute weights based on deviations from the jth point,
    % then compute weights and apply them as above.
    d = abs((1:span-1) - j);
    weight = (1 - (d/(span-j)).^3).^1.5;
    V = v .* repmat(weight(:),1,size(v,2));
    [Q,nouse] = qr(V,0);
    alpha = Q(j,:)*Q';
    alpha = alpha .* weight;
    ys(j) = alpha * y(1:span-1);

    % These coefficients can be applied to the other end as well
    ys(end+1-j) = alpha * y(end:-1:end-span+2);
end
end

% -----------------------------------------
function isuniform = uniformx(diffx,x,y)
%ISUNIFORM True if x is of the form a:b:c

if any(isnan(y)) || any(isnan(x))
    isuniform = false;
else
    isuniform = all(abs(diff(diffx)) <= eps*max(abs([x(1),x(end)])));
end
end

%------------------------
function idx = iKNearestNeighbours( k, i, x, in )
% Find the k points from x(in) closest to x(i)

if nnz( in ) <= k
    % If we have k points or fewer, then return them all
    idx = find( in );
else
    % Find the distance to the k closest point
    d = abs( x - x(i) );
    ds = sort( d(in) );
    dk = ds(k);
    
    % Find all points that are as close as or closer than the k closest point
    close = (d <= dk);
    
    % The required indices are those points that are both close and "in"
    idx = find( close & in );
end
end

% -----------------------------------------
% Bi-square (robust) weight function
function delta = iBisquareWeights( r, myeps )
% Convert residuals to weights using the bi-square weight function.
% NOTE that this function returns the square root of the weights

% Only use non-NaN residuals to compute median
idx = ~isnan( r );
% And bound the median away from zero
s = max( 1e8 * myeps, median( abs( r(idx) ) ) );
% Covert the residuals to weights
delta = iBisquare( r/(6*s) );
% Everything with NaN residual should have zero weight
delta(~idx) = 0;
end

function b = iBisquare( x )
% This is this bi-square function defined at the top of the left hand
% column of page 831 in [C79]
% NOTE that this function returns the square root of the weights
b = zeros( size( x ) );
idx = abs( x ) < 1;
b(idx) = abs( 1 - x(idx).^2 );
end

%------------------------
% Tri-cubic weight function
function w = iTricubeWeights( d )
% Convert distances into weights using tri-cubic weight function.
% NOTE that this function returns the square-root of the weights.
%
% Protect against divide-by-zero. This can happen if more points than the span
% are coincident.
maxD = max( d );
if maxD > 0
    d = d/max( d );
end
w = (1 - d.^3).^1.5;
end