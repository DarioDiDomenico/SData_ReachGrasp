
%% STRADIVARI plots a combination of half-violins, and raw datapoints (1d or 2d scatter).
% [h,u,med] = STRADIVARI(X,Name,Value)
% displays the violin plots of X. X is a data matrix with columns 
% corresponding to data points and rows to different cases. 
% Each case gets its own violin.
% 
% [h,u,med] = STRADIVARI(AX,...)
% plots into the axes with handle AX. If no axes are given it creates a new
% figure.
%
% Seee below for optional inputs.
%
% ---------------------------- INPUT ----------------------------
%
% X                  - vector of data to be plotted, required.
%
% --------------------- OPTIONAL ARGUMENTS ----------------------
%
% ViolinColor        - Color vector for violins. Can either be a single
%                      vector (all violins the same color) or a matrix 
%                      M x 3, where M is the first dimension of X (one
%                      color per violin). Default colors are the the
%                      ColorBrewer pastel1 palette. If you don't know the
%                      ColorBrewer project, go check it out. It's awesome.
% ViolinAlpha        - scalar positive value to increase cloud Alpha.
%                      (default = .8)
% ScatterColor       - Color vector for scatter. Can either be a single
%                      vector (all scatter the same color) or a matrix 
%                      M x 3, where M is the first dimension of X (one
%                      color per scatter). Default colors are the the
%                      ColorBrewer set1 palette.
% If only ViolinColor or ScatterColor is provided, it sets the other to the
% same value and ViolinAlpha to 0.6 in order to increase contrast. To
% contral all three parameters, please provide them explicitely.
%
% BandWidth          - BandWidth of smoothing kernel (default = 1)
% DensityType        - choice of density algo ('ks' or 'rash'). Default = 'ks'
% ScatterOffset      - scalar value to increase dot dodge amounts (defalut =0.6)
% ScatterSize        - Matrix the same size as X that defines the size of
%                      each marker in the scatterplot
% ScatterWidth       - scalar value that defines the percentual amount of
%                      cloud area occupied by the scatter
% ScatterJitter      - Same size as X. Used to encode a second dimension
%                      in the scatterplot.
% Vertical          - 1 or zero. Plot clouds Vertical or horizzontal
% LineWidth         - scalar value to set global line width of clouds
%                     contour (default = 2)
% Normalization     - 'max' or 'area'. Normalization method (default =
%                     'area')
% Coupled           - Matrix. determines which rows of X to couple in a 
%                     full violin. Row numbers along its first dimension 
%                     get Coupled  Ex:
%                       X = rand(5,20); 
%                       ind = [1 3 nan;...
%                              2 4 5]
%                       stradivari(X,'Coupled',ind);
%
%                     This would plot rows 1,2 and 3,4 together and 5
%                     alone.
% GridOn            - 1 or zero. Plots small markers on the side
%                     corresponding to the median value of each
%                     distribution
% BoxOn             - logical to turn box-plots on/off (default = 0)
%
% ---------------------------- OUTPUT ----------------------------
% h   - figure handle to change more stuff
% u   - parameter from kernel density estimate
% med - median value foreach distribution
%
%
% Heavilly based on <a href="matlab: 
% web('https://github.com/RainCloudPlots/RainCloudPlots')">raincloud_plot</a>.
%
% (C) Federico Barban 2019, modification of RaincloudPlot to add 
% functionalities and improve flexibility. 
% Released under GNU General Public License. 
 
%%
% ---GNU General Public License Copyright---
% 
% stradivari is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, version 2.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details in COPYING.txt found
% in the main DataHigh directory.
% 
% You should have received a copy of the GNU General Public License
% along with stradivari.  If not, see <http://www.gnu.org/licenses/>.



function [h, u, med] = stradivari(varargin)




%% check all the inputs and if they do not exist then revert to default settings
%% input parsing settings
p = inputParser;
p.CaseSensitive = true;
p.Parameters;
p.Results;
p.KeepUnmatched = true;
validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
isNumOrLogic = @(x)isnumeric(x) | islogical(x);

%% Parse and validate X
if  isgraphics(varargin{1})    
    ax = varargin{1};
    varargin(1) = [];
else
    ax = axes(figure);
end


if isnumeric(varargin{1})
    X = varargin{1};
    varargin(1) = [];
elseif ~isempty(varargin) && iscell(varargin{1})
% if X is cellarray, stack it in matrix form wrapping shorter lines with
% nans
    AllL = cellfun(@length,varargin{1});
    Lmax = max(AllL);
    nSig = length(varargin{1});
    X = nan(nSig,Lmax);
    for ii=1:nSig
        X(ii,1:AllL(ii)) = varargin{1}{ii};
    end
    varargin{1} = X;
    [h, u, med] = stradivari(varargin{:});
    return;
else
    error('No input data provided!');
end
[M,N]=size(X);

%% Add validation for optional inputs
% Color pars
addOptional(p, 'ViolinColor', MyColors(1:M,'Violin'), @isnumeric)
addOptional(p, 'ViolinAlpha', 1, validScalarPosNum)
addOptional(p, 'ScatterColor', MyColors(1:M,'Scatter'), @isnumeric)

% Density estimation pars
addOptional(p, 'BandWidth', [])
addOptional(p, 'DensityType', 'ks', @ischar)
addOptional(p, 'lwrBnd', 1, @isnumeric)  % deprecated?

% Violin pars
addOptional(p, 'LineWidth', 0.01, validScalarPosNum)
addOptional(p, 'Coupled', (1:M), @isnumeric);
addOptional(p, 'Normalization', 'area', @ischar)
addOptional(p, 'Vertical', false, isNumOrLogic);

% Scatter pars
addOptional(p, 'ScatterOffset', 0.5, @isnumeric)
addOptional(p, 'ScatterSize', 10, @isnumeric);
addOptional(p, 'ScatterWidth', 0.25, @isnumeric);
addOptional(p, 'ScatterJitter',rand(M,N), @isnumeric)

% Cosmetics
addOptional(p, 'BoxOn', false, isNumOrLogic)
addOptional(p, 'GridOn', false, isNumOrLogic)
addOptional(p, 'Legend', true, isNumOrLogic)

% manual position control
addOptional(p, 'Xoffs', nan, @isnumeric)
addOptional(p, 'Yoffs', nan, @isnumeric)

%% parse and validate optional inputs
parse(p,varargin{:});
ValidInArgs = p.Results;

if M>N
 warning('Looks like there are more cases than observations!');
end

if isscalar(ValidInArgs.ScatterSize)
    ValidInArgs.ScatterSize = ones(M,N) * ValidInArgs.ScatterSize;
elseif any(size(ValidInArgs.ScatterSize) ~= [M,N])
    error('ScatterSize size does not match input size.');    
end

if any(size(ValidInArgs.ScatterJitter) ~= [M,N])
    error('ScatterJitter size does not match input size.');    
elseif min(ValidInArgs.ScatterJitter(:))<=0 || max(ValidInArgs.ScatterJitter(:))>1 
    error('ScatterJitter must be (0 1] range');
end

if ValidInArgs.Vertical
    AxDir = 'XLim';
    
else
    AxDir = 'YLim';
end

if ~ismember('ViolinColor',p.UsingDefaults) && ismember('ScatterColor',p.UsingDefaults)
    ValidInArgs.ScatterColor = ValidInArgs.ViolinColor;
    ValidInArgs.ViolinAlpha = .6;
elseif ismember('ViolinColor',p.UsingDefaults) && ~ismember('ScatterColor',p.UsingDefaults)
    ValidInArgs.ViolinColor = ValidInArgs.ScatterColor;
    ValidInArgs.ViolinAlpha = .6;
end

ind = ValidInArgs.Coupled;

if exist('rst_RASH', 'file') ~= 2
    RSTpresent = false;
elseif exist('rst_RASH', 'file') == 2
    RSTpresent = true;
end

PlotLegend = false;
if ~any(ismember(p.UsingDefaults,'ScatterSize')) && ~all(isnan(p.Results.ScatterSize(:))) && ValidInArgs.legend
    PlotLegend = true;
end

if ~all(isnan(ValidInArgs.Xoffs(:))) && any(size(ValidInArgs.Xoffs)~=size(ind))
    error('Xoffs size does not match violins distribution (defined in Coupled).')
elseif ~all(isnan(ValidInArgs.Xoffs(:))) && isnumeric(ValidInArgs.Xoffs)
    ValidInArgs.Xoffs = num2cell(ValidInArgs.Xoffs);
end

if ~all(isnan(ValidInArgs.Yoffs(:))) && any(size(ValidInArgs.Yoffs)~=size(ind))
    error('Yoffs size does not match violins distribution (defined in Coupled).')
elseif ~all(isnan(ValidInArgs.Yoffs(:))) && isnumeric(ValidInArgs.Yoffs)
    ValidInArgs.Yoffs = num2cell(ValidInArgs.Yoffs);
end
%% Compute distribution and ScatterJittering
% preallocate stuff
Ydist       = cell(size(ind));
Xdist       = cell(size(ind));
outliers    = cell(size(ind));
WiskX       = cell(size(ind));
WiskY       = cell(size(ind));
Xqrtls      = cell(size(ind));
Yqrtls      = cell(size(ind));
drops_posY  = cell(size(ind));
drops_posX  = cell(size(ind));
XGrid       = cell(size(ind));
YGrid       = cell(size(ind));
XBox        = cell(size(ind));
YBox        = cell(size(ind));

h           = cell(size(ind));

% start distribution computation
for ii=1:size(ind,1)
    for jj=1:size(ind,2)
        if(isnan(ind(ii,jj))),Ydist{ii,jj}=0;continue;end
        %% calculate kernel density
        nanInd = isnan(X(ind(ii,jj),:));
        if RSTpresent,outliers{ii,jj} = logical(rst_outlier(X(ind(ii,jj),:),1));
        else,         outliers{ii,jj} = logical(isoutlier(X(ind(ii,jj),:),'quartiles'));end
        
        switch ValidInArgs.DensityType
            case 'ks'
                [Ydist{ii,jj}, Xdist{ii,jj}, u] = ksdensity(X(ind(ii,jj),~outliers{ii,jj}), 'bandwidth', ValidInArgs.BandWidth);
                
            case 'rash'
                if  ~RSTpresent
                    % must have 
                    % https://github.com/CPernet/Robust_Statistical_Toolbox
                    % for this to work.
                    error('%s\n%s\n', ...
                        'Could not find the Robust Stats toolbox on your path.',...
                        'Download it from <a href="https://github.com/CPernet/Robust_Statistical_Toolbox">here</a> and add it to your path.');
                end
                [Xdist{ii,jj}, Ydist{ii,jj}] = rst_RASH(sort(X(ind(ii,jj),~nanInd & ~outliers{ii,jj})),200);
                u = NaN; % not sure how to handle this with RASH yet
%                 Xdist{ii,jj}(Ydist{ii,jj}==0)=[];
%                 Ydist{ii,jj}(Ydist{ii,jj}==0)=[];
        end
        Ydist{ii,jj}(1)=0;
        Ydist{ii,jj}(end)=0;
        if strcmp(ValidInArgs.Normalization,'area')
            Ydist{ii,jj}=(Ydist{ii,jj})./trapz(Xdist{ii,jj},Ydist{ii,jj})  * (-1)^(ii-1);
        elseif strcmp(ValidInArgs.Normalization,'max')
            Ydist{ii,jj}=(Ydist{ii,jj})./max(Ydist{ii,jj})  * (-1)^(ii-1);
        else
            error(['stradivari:' mfilename 'badInput'],'Invalid Normalization method %s.', Normalization);
        end
        
        %% Calculate ScatterJittering and spacing
        % make some space under the density plot for the boxplot and raindrops
        ylmax = max(abs(Ydist{ii,jj}));
        
        % width of boxplot
        wdth = ylmax * ValidInArgs.ScatterWidth;
        
        % ScatterJitter for raindrops
        jit = (ValidInArgs.ScatterJitter(ind(ii,jj),:)) * wdth;         
        % info for making boxplot
        if RSTpresent
            [quartiles(1),CIQ] = rst_hd(X(ind(ii,jj),~outliers{ii,jj}),0.25);
            [quartiles(2),CIQ] = rst_hd(X(ind(ii,jj),~outliers{ii,jj}),0.75);
            [quartiles(3),CIQ] = rst_hd(X(ind(ii,jj),~outliers{ii,jj}),0.5);
        else
            [quartiles(1)] = quantile(X(ind(ii,jj),~outliers{ii,jj}),0.25);
            [quartiles(2)] = quantile(X(ind(ii,jj),~outliers{ii,jj}),0.75);
            [quartiles(3)] = quantile(X(ind(ii,jj),~outliers{ii,jj}),0.5);
        end
        
        iqr         = quartiles(2) - quartiles(1);
        Xs          = sort(X(ind(ii,jj),:));
        
        %    whiskers(1) = min(Xs(Xs > (quartiles(1) - (1.5 * iqr))));
        %    whiskers(2) = max(Xs(Xs < (quartiles(2) + (1.5 * iqr))));
        whiskers(1) = quartiles(1) - (1.5 * iqr);
        whiskers(2) = quartiles(2) + (1.5 * iqr);
        WiskX{ii,jj}      =  [quartiles(2) whiskers(1);quartiles(1) whiskers(2)];
        
        % finds the first value of the distribution greater than the
        % quartiles (1,2,3 quartiles).
        [~,tmp] = max( (ones(size(quartiles,2),1)*Xdist{ii,jj}) > (ones(size(Xdist{ii,jj},2),1) *quartiles)',[],2);
%         [~,tmp]     = max(Xdist{ii,jj}>quartiles',[],2);
%         Xqrtls{ii,jj}  = [Xdist{ii,jj}(tmp);Xdist{ii,jj}(tmp)];
        Xqrtls{ii,jj}  = [quartiles;quartiles];
        Yqrtls{ii,jj}  = [zeros(1,3);Ydist{ii,jj}(tmp)* (-1)^(ii-1)];
        % raindrops
        drops_posY{ii,jj} = jit + ylmax .* ValidInArgs.ScatterOffset;
        drops_posY{ii,jj} = drops_posY{ii,jj} * (-1)^(ii-1);
        drops_posX{ii,jj} = X(ind(ii,jj),:);
        
        % grid points 
        XGrid{ii,jj} = Xqrtls{ii,jj}(1,3);
        YGrid{ii,jj} = Yqrtls{ii,jj}(1,3);
       
        
    end
end
%% order median values to reflect input order;
med = nan(numel(XGrid));
med(ind(~isnan(ind))) =[XGrid{:}];

%% compute offsets
if ~iscell(ValidInArgs.Yoffs) 
    distW = cellfun(@(x) max(abs(x)),Ydist);
    ldists = max(distW(2:2:end,2:end),[],1);
    rdists = max(distW(1:2:end,1:end-1),[],1);
    tmp =  rdists;
    if ~isempty(ldists),tmp = tmp + ldists;end
    distances = cumsum([0 tmp]).*1.05;
    Yoffs = num2cell(distances);
    Yoffs = repmat(Yoffs,size(ind,1),1);
else
    Yoffs = ValidInArgs.Yoffs;
end
if ~iscell(ValidInArgs.Xoffs) 
    Xoffs = num2cell(zeros(size(Yoffs)));
else
    Xoffs = ValidInArgs.Xoffs;
end

hh = Yoffs{end}(1)/5/numel(ind);
if ~hh,hh=distW(end)/5/numel(ind);end
for jj=1:size(ind,2) % number of violins
    for ii=1:size(ind,1)
        if(isnan(ind(ii,jj))),continue;end

        %         compute box
        x1 = Xqrtls{ii,jj}(1,1);
        x2 = Xqrtls{ii,jj}(1,2);
        xm = mean([x1 x2]);
        ym = Yqrtls{ii,jj}(1,3);
        a = abs(diff([x1 x2]))/2;
        b = hh;
%         create a scaled rectcircle with proportion 5x3x1 (x,y,r)
        [XBox{ii,jj},~] = roundedRect(xm,ym,a,a/5*3,a/5);
        [~,YBox{ii,jj}] = roundedRect(xm,ym,b/3*5,b,b/3);
        YBox{ii,jj} =  YBox{ii,jj} .* (-1)^(ii-1);
        
%  whiskers
        WiskY{ii,jj}      =   ones(size(whiskers))*b./2 * (-1)^(ii-1);

    end
end
%% plot all
tick = 'ytick';
nViolin =1;
for jj=1:size(ind,2) % number of violins   
    for ii=1:size(ind,1)  % cicle throungh "lobes" of each violin 
        if(isnan(ind(ii,jj))),continue;end
        if ValidInArgs.Vertical
            [Xoffs{ii,jj}        , Yoffs{ii,jj}  ] = deal( Yoffs{ii,jj}     , Xoffs{ii,jj});
            [Xdist{ii,jj}     , Ydist{ii,jj}     ] = deal( Ydist{ii,jj}     , Xdist{ii,jj});
            [drops_posX{ii,jj}, drops_posY{ii,jj}] = deal( drops_posY{ii,jj}, drops_posX{ii,jj});
            [WiskX{ii,jj}     , WiskY{ii,jj}     ] = deal( WiskY{ii,jj}     , WiskX{ii,jj});
            [Xqrtls{ii,jj}    , Yqrtls{ii,jj}    ] = deal( Yqrtls{ii,jj}    , Xqrtls{ii,jj});
            tick = 'xtick';
        end
        
        %% density plot
        h{ii,jj}{1} = fill(Xdist{ii,jj} + Xoffs{ii,jj}, Ydist{ii,jj} + Yoffs{ii,jj}, ValidInArgs.ViolinColor(ind(ii,jj),:));
        holdvalue = ishold(ax);
        hold(ax,'on');
        set(h{ii,jj}{1}, 'EdgeColor', 'none');
        set(h{ii,jj}{1}, 'LineWidth', ValidInArgs.LineWidth);
        set(h{ii,jj}{1}, 'FaceAlpha', ValidInArgs.ViolinAlpha);
        set(h{ii,jj}{1}, 'EdgeAlpha', ValidInArgs.ViolinAlpha);
        
        %% scatter
        % robust data
        h{ii,jj}{2} = scatter(drops_posX{ii,jj}(~outliers{ii,jj}) + Xoffs{ii,jj}, drops_posY{ii,jj}(~outliers{ii,jj}) + Yoffs{ii,jj});
        h{ii,jj}{2}.SizeData = ValidInArgs.ScatterSize(ind(ii,jj),~outliers{ii,jj});
        h{ii,jj}{2}.MarkerFaceColor = ValidInArgs.ScatterColor(ind(ii,jj),:);
        h{ii,jj}{2}.MarkerEdgeColor = 'none';
        
        % outliers
        h{ii,jj}{3} = scatter(drops_posX{ii,jj}(outliers{ii,jj})  + Xoffs{ii,jj}, drops_posY{ii,jj}(outliers{ii,jj}) + Yoffs{ii,jj},'x');
        h{ii,jj}{3}.SizeData = ValidInArgs.ScatterSize(ind(ii,jj),outliers{ii,jj});
        h{ii,jj}{3}.MarkerEdgeColor = ValidInArgs.ViolinColor(ind(ii,jj),:);
        
        % update counter
        nViolin = nViolin + 1;
    end
end

%% Box 
if ValidInArgs.BoxOn
    
    nViolin =1;
    axLim = ylim;
    if ValidInArgs.Vertical
        axLim = xlim;
    end % fi
   
    
    for ii=1:size(ind,1)
        for jj=1:size(ind,2)
            
            YMpointOffset = b./2* (-1)^(ii-1);
            XMpointOffset = 0;
            if ValidInArgs.Vertical
                [XMpointOffset,YMpointOffset] = deal(YMpointOffset,XMpointOffset);
                axLim = ylim;
            end % fi
            
            % box points ans coordinates
            [~,Ypix1]=dataPointsToUnit(ax,0,max(YBox{ii,jj} + Yoffs{ii,jj}),'points');
            [~,Ypix2]=dataPointsToUnit(ax,0,min(YBox{ii,jj} + Yoffs{ii,jj}),'points');
            rad1 = (Ypix1-Ypix2)/2;
            Pdim = pi*rad1^2/2;
            
            
            if ValidInArgs.Vertical
                [XBox{ii,jj}        , YBox{ii,jj}  ] = deal( YBox{ii,jj}     , XBox{ii,jj});
                
                [Xpix3]=dataPointsToUnit(ax,max(XBox{ii,jj} + Xoffs{ii,jj}),0,'points');
                [Xpix4]=dataPointsToUnit(ax,min(XBox{ii,jj} + Xoffs{ii,jj}),0,'points');
                rad2 = (Xpix3-Xpix4)/2;
                Pdim = pi*rad2^2/2;
            end % fi
            
            if(isnan(ind(ii,jj))),continue;end
            
            
            
            h{ii,jj}{4} = line(...
                WiskX{ii,jj} + Xoffs{ii,jj} ,...
                WiskY{ii,jj} + Yoffs{ii,jj} ,...
                'col', [73,73,73]./255, ...
                'LineWidth', ValidInArgs.LineWidth);
            
            
            h{ii,jj}{5} = patch(XBox{ii,jj} + Xoffs{ii,jj},...
                YBox{ii,jj} + Yoffs{ii,jj},...
                [73,73,73]./255,'EdgeColor','none');
            
            xm = Xqrtls{ii,jj}(1,3) + Xoffs{ii,jj};
            ym = Yqrtls{ii,jj}(1,3) + Yoffs{ii,jj};
            h{ii,jj}{6} = scatter(xm+XMpointOffset,ym+YMpointOffset,...
                Pdim,...
                [1 1 1],'filled');
            
             uistack(h{ii,jj}{6},'down');
             uistack(h{ii,jj}{5},'down');
             uistack(h{ii,jj}{4},'down');
            
            
            % 'box' of 'boxplot'
            %          h{3} = rectangle('Position', box_pos,'Curvature',0.2);
            %          set(h{3}, 'EdgeColor', bxcl)
            %          set(h{3}, 'LineWidth', ValidInArgs.LineWidth);
            %set(h{3}, 'FaceColor', bxfacecl);
            % could also set 'FaceColor' here, etc
            nViolin = nViolin + 1;
        end % jj
    end % ii
end % fi BoxOn

%% Grid
if ValidInArgs.GridOn
    yl = get(gca,'ylim');
    xl = get(gca,'xlim');
    nViolin =1;
    if ValidInArgs.Vertical
        [xl, yl] = deal( yl, xl);
    end
    for jj=1:size(ind,2) 
        for ii=1:size(ind,1)
            if(isnan(ind(ii,jj))),continue;end
            YGrid{ii,jj} = yl(1);
            Marker = '^';
            if ValidInArgs.Vertical
                Marker = '>';
                [XGrid{ii,jj}    , YGrid{ii,jj}    ] = deal( YGrid{ii,jj}    , XGrid{ii,jj});
            end
            %% grid
            h{ii,jj}{7} = scatter(XGrid{ii,jj},YGrid{ii,jj},Marker);
            h{ii,jj}{7}.MarkerFaceColor = ValidInArgs.ScatterColor(ind(ii,jj),:);
            h{ii,jj}{7}.MarkerEdgeColor = 'none';
%             uistack(h{7},'bottom')       
            nViolin = nViolin + 1;
        end
    end
    
    % restore axes limits
    if ValidInArgs.Vertical
        [xl, yl] = deal( yl, xl);
    end
    set(gca,'xlim',xl);
    set(gca,'ylim',yl);
end

%% Ticks
if ValidInArgs.Vertical
    ax.XTick = unique([Xoffs{:}]);
    ax.XTickLabel = arrayfun(@(x) {num2str(x)},1:size(ind,2));
else
    ax.YTick = unique([Yoffs{:}]);
    ax.YTickLabel = arrayfun(@(x) {num2str(x)},1:size(ind,2));
end


%% Legend
if PlotLegend
    
%     ax.Units = 'pixels';
%     ax = axes(gcf,'Units','pixels','Position',[260 20 250 70]);
    TT1 = quantile(ValidInArgs.ScatterSize(:),100);
    legendPointSize = TT1([20 30 40 50 60 70 80 85 90 95 100]);
    pointsRadius = UnitsToDataPoint(ax,2*sqrt(legendPointSize/pi),1,'points');
    xl = xlim(ax);
    yl = ylim(ax);
    spacer = diff(xl)/(numel(pointsRadius)+1)/5;
    legendx = zeros(size(pointsRadius));
    for ii=2:numel(pointsRadius)
        legendx(ii) = spacer + legendx(ii-1) + pointsRadius(ii-1)/2 + pointsRadius(ii)/2;
    end
    legendy = ones(1,11)*yl(1)*1.05;
    sc = scatter(ax,legendx,legendy,...
        'filled','SizeData',legendPointSize,'MarkerFaceColor',MyColors(10),...
        'MarkerEdgeColor',MyColors(10));
    
    [dim(1), dim(2)] = dataPointsToUnit(ax,legendx(1),yl(1)*1.01,'normalized');
    an = annotation('textbox',[dim 0.3 0.3],...
        'String',num2str(round(legendPointSize(1),2)),...
        'VerticalAlignment','bottom',...
        'Margin',0,...
        'LineStyle','none');
    
    m = find(legendx>0.5*(legendx(end)-legendx(1)),1);
    [dim(1), dim(2)] = dataPointsToUnit(ax,legendx(m),yl(1)*1.01,'normalized');
    an2 = annotation('textbox',[dim 0.3 0.3],...
        'String',num2str(round(legendPointSize(m),2)),...
        'VerticalAlignment','bottom',...
        'Margin',0,...
        'LineStyle','none');
    
    [dim(1), dim(2)] = dataPointsToUnit(ax,legendx(end),yl(1)*1.01,'normalized');
    dim = arrayfun(@(x)min(max(x,0),1),dim);
    an3 = annotation('textbox',[dim 0.3 0.3],...
        'String',num2str(round(legendPointSize(end),2)),...
        'VerticalAlignment','bottom',...
        'Margin',0,...
        'LineStyle','none');
    for ii=1:size(ind,1) 
        for jj=1:size(ind,2) 
            h{ii,jj}{8} = {sc,an,an2,an3};
        end
    end
end
if ~holdvalue,hold(ax,'off');end

box(ax,'off');

end % stradivari


%% Colors 
function Clrs=MyColors(ind,type)
%%%% RGB

switch type
    case 'Scatter'
        Clrs=[
            0.8941    0.1020    0.1098
            0.2157    0.4941    0.7216
            0.3020    0.6863    0.2902
            0.5961    0.3059    0.6392
            1.0000    0.4980         0
            1.0000    1.0000    0.2000
            0.6510    0.3373    0.1569
            0.9686    0.5059    0.7490
            0.6000    0.6000    0.6000];

    case 'Violin'
        Clrs=[0.9843    0.7059    0.6824
            0.7020    0.8039    0.8902
            0.8000    0.9216    0.7725
            0.8706    0.7961    0.8941
            0.9961    0.8510    0.6510
            1.0000    1.0000    0.8000
            0.8980    0.8471    0.7412
            0.9922    0.8549    0.9255
            0.9490    0.9490    0.9490];
end
Clrs=Clrs(mod(ind-1,size(Clrs,1))+1,:);
end

function [x,y] = roundedRect(x0,y0,a,b,r)
% n = 1000;
% k = 1:n;
% x1 = x0-a;
% x2 = x0+a;
% x = (x1+x2)/2+(x2-x1)/2.*cos((2.*k-1)./(2*n).*pi);
x = linspace(-a,a,1000);
expb = 2*b/r;
expa = 2*a/r;
X = abs( x )./a;
y = [abs( b.*(1 - X.^expa ).^(1/expb) )];
x = x + x0;
y = y + y0;
end

function [Xpix,Ypix]=dataPointsToUnit(ax,X,Y,mode)
units=get(ax,'Units');
set(ax,'Units',mode);
axpos = get(ax, 'Position');
lblSpace = get(ax, 'TightInset');

% get axes drawing area in data units
ax_xlim = xlim(ax);
ax_ylim = ylim(ax);

ax_unit_per_xdata = (axpos(3)) ./ diff(ax_xlim);
ax_unit_per_ydata = (axpos(4)) ./ diff(ax_ylim);

% these are figure-relative
Xpix = (X - ax_xlim(1)) .* ax_unit_per_xdata + axpos(1)-0.007;
Ypix = (Y - ax_ylim(1)) .* ax_unit_per_ydata + axpos(2);

set(ax,'Units',units);
end

function [X,Y]=UnitsToDataPoint(ax,Xpix,Ypix,mode)

units=get(ax,'Units');
set(ax,'Units',mode);
axpos = get(ax, 'Position');
lblSpace = get(ax, 'TightInset');

% get axes drawing area in data units
ax_xlim = xlim(ax);
ax_ylim = ylim(ax);

X_per_ax_unit = diff(ax_xlim) ./ axpos(3);
Y_per_ax_unit = diff(ax_ylim) ./ axpos(4);
X = Xpix .*X_per_ax_unit;
Y = Ypix.*Y_per_ax_unit;
set(ax,'Units',units);
end