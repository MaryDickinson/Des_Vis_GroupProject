function RingSizeGUI()

% Script Name : RingSizeGUI.m
% Created on  : 04/03/2026
% Authors     : Mary Dickinson, Nicole Stott, Eleni Papatheofanous
%
% Purpose     : Hand-Based Ring Size Estimator using Vision-Based
%               Anthropometry. The user places their hand flat next to a
%               reference object (credit card). The system segments the
%               fingers, measures finger width, and maps the measurement
%               to a UK ring size.
%
% GUI Layout:
%   Panel 1: Browse for a hand image, select hand side (left/right),
%            choose finger to measure, set measurement position (0-1),
%            and click estimate ring size.
%   Panel 2: Displays a fixed reference photo and written instructions
%            to guide correct image capture.
%   Panel 3: Displays the processed image with skeleton overlay,
%            fingertip markers, measurement line, card outline,
%            and labelled size annotation.
%
% Pipeline:
%   1.  Load image
%   2.  Skin segmentation (HSV thresholding)
%   3.  Morphological cleaning, used for
%       skeleton and fingertip detection
%   4.  Connected components to isolate the dominant hand region
%   5.  Skeletonisation to locate fingertips
%   6.  Reference card calibration (pixels to mm), edge
%       detection with PCA-based axis fitting
%   7.  Finger width measurement
%   8.  Map circumference to UK ring size
%   9.  Build annotated output image with overlays and labels
%
% Dependencies:
%   - Image Processing Toolbox
%   - Computer Vision Toolbox
%

    %% Colour Palette
    C_BG        = [0.97 0.95 0.90];    % light beige
    C_PANEL     = [0.99 0.97 0.93];    % slightly lighter beige
    C_BLACK     = [0.08 0.07 0.07];    % near-black
    C_HYD       = [0.58 0.50 0.75];    % hydrangea blue-purple
    C_HYD_DARK  = [0.38 0.30 0.58];    % deeper hydrangea
    C_BTN       = [0.88 0.84 0.93];    % button background
    C_RUN       = [0.58 0.50 0.75];    % run button (hydrangea)
    C_RESULT    = [0.90 0.86 0.95];    % result box tint
    C_BADGE     = [0.38 0.30 0.58];    % large badge background (dark hydrangea)

    %% Figure
    fig = figure('Name', 'Ring Size Estimator', 'NumberTitle', 'off', ...
        'Position', [50 50 1300 740], 'Resize', 'off', 'MenuBar', 'none', ...
        'ToolBar', 'none', 'Color', C_BG);

    % Header bar
    uipanel(fig, 'Position',[0 0.945 1 0.055], 'BackgroundColor',C_HYD, ...
        'BorderType','none');
    uicontrol(fig,'Style','text', 'String','Ring Size Estimator', ...
        'Units','normalized','Position',[0 0.945 1 0.055], 'BackgroundColor', ...
         C_HYD,'ForegroundColor',C_BG, 'FontSize',15,'FontWeight','bold',...
         'HorizontalAlignment','left');

    %% Section label helper
    function sectionLabel(parent, ypos, txt)
        uicontrol(parent,'Style','text','String',txt, 'Units','normalized', ...
            'Position',[0.04 ypos 0.92 0.040], 'BackgroundColor',C_PANEL, ...
            'ForegroundColor',C_HYD_DARK, 'FontSize',9,'FontWeight','bold', ...
            'HorizontalAlignment','left');
    end

    %%  Settings
    pCtrl = uipanel(fig, ...
        'Position',        [0.005 0.01 0.205 0.930], 'BackgroundColor', C_PANEL, ...
        'ForegroundColor', C_HYD_DARK, 'BorderType','line','HighlightColor',C_HYD, ...
        'Title','  Settings','FontSize',12,'FontWeight','bold');

    % Hand image
    sectionLabel(pCtrl, 0.875, '1.  Hand Image');
    uicontrol(pCtrl,'Style','pushbutton','String','Browse…', 'Units', ...
        'normalized','Position',[0.04 0.815 0.46 0.052], 'BackgroundColor', ...
        C_BTN,'ForegroundColor',C_BLACK, 'FontSize',9,'Callback',@browseHandCallback);
    hFileLbl = uicontrol(pCtrl,'Style','text','String','No file selected', ...
        'Units','normalized','Position',[0.04 0.745 0.92 0.062], ...
        'BackgroundColor',C_PANEL,'ForegroundColor',[0.50 0.46 0.46], ...
        'FontSize',8,'HorizontalAlignment','left');

    % Hand side
    sectionLabel(pCtrl, 0.695, '2.  Hand Side');
    hBtnGrp = uibuttongroup(pCtrl, ...
        'Units','normalized','Position',[0.04 0.620 0.92 0.070], ...
        'BackgroundColor',C_PANEL,'BorderType','none');
    hRadioL = uicontrol(hBtnGrp,'Style','radiobutton','String','Left hand', ...
        'Units','normalized','Position',[0.02 0.05 0.46 0.90], ...
        'BackgroundColor',C_PANEL,'ForegroundColor',C_BLACK,'FontSize',9);
    hRadioR = uicontrol(hBtnGrp,'Style','radiobutton','String','Right hand', ...
        'Units','normalized','Position',[0.52 0.05 0.46 0.90], ...
        'BackgroundColor',C_PANEL,'ForegroundColor',C_BLACK,'FontSize',9);
    hBtnGrp.SelectedObject = hRadioR;

    % Finger
    sectionLabel(pCtrl, 0.570, '3.  Finger to Measure');
    hFingerPop = uicontrol(pCtrl,'Style','popupmenu', ...
        'String',{'Ring','Middle','Index','Pinky','Thumb'}, ...
        'Units','normalized','Position',[0.04 0.505 0.92 0.052], ...
        'BackgroundColor',C_BTN,'ForegroundColor',C_BLACK,'FontSize',9);

    % Measurement position
    sectionLabel(pCtrl, 0.445, '4.  Measurement Position');
    uicontrol(pCtrl,'Style','text', ...
        'String','0 = tip  ·  0.45 = mid  ·  1 = knuckle', ...
        'Units','normalized','Position',[0.04 0.395 0.92 0.040], ...
        'BackgroundColor',C_PANEL,'ForegroundColor',[0.50 0.46 0.46], ...
        'FontSize',7.5,'HorizontalAlignment','left');
    hMeasEdit = uicontrol(pCtrl,'Style','edit','String','0.45', ...
        'Units','normalized','Position',[0.04 0.330 0.44 0.052], ...
        'BackgroundColor',C_BTN,'ForegroundColor',C_BLACK,'FontSize',10);

    % RUN button
    hRun = uicontrol(pCtrl,'Style','pushbutton', ...
        'String','▶  ESTIMATE RING SIZE', ...
        'Units','normalized','Position',[0.04 0.215 0.92 0.090], ...
        'BackgroundColor',C_RUN,'ForegroundColor',C_BG, ...
        'FontSize',10,'FontWeight','bold','Callback',@runCallback);

    % Status bar
    hStatus = uicontrol(pCtrl,'Style','text', ...
        'String','Ready — browse an image to begin.', ...
        'Units','normalized','Position',[0.04 0.155 0.92 0.052], ...
        'BackgroundColor',C_PANEL,'ForegroundColor',[0.45 0.42 0.42], ...
        'FontSize',8,'HorizontalAlignment','left');

    % Result section heading
    uicontrol(pCtrl,'Style','text','String','RESULT', ...
        'Units','normalized','Position',[0.04 0.108 0.50 0.035], ...
        'BackgroundColor',C_PANEL,'ForegroundColor',C_HYD_DARK, ...
        'FontSize',9,'FontWeight','bold','HorizontalAlignment','left');
    uicontrol(pCtrl,'Style','text','String','UK SIZE', ...
        'Units','normalized','Position',[0.56 0.108 0.40 0.035], ...
        'BackgroundColor',C_PANEL,'ForegroundColor',C_HYD_DARK, ...
        'FontSize',9,'FontWeight','bold','HorizontalAlignment','center');

    % Result detail text
    hResult = uicontrol(pCtrl,'Style','text','String','—', ...
        'Units','normalized','Position',[0.04 0.010 0.50 0.094], ...
        'BackgroundColor',C_RESULT,'ForegroundColor',C_BLACK, ...
        'FontSize',8,'FontWeight','bold','HorizontalAlignment','left');

    % Large UK ring size badge
    hBadge = uicontrol(pCtrl,'Style','text','String','—', ...
        'Units','normalized','Position',[0.56 0.010 0.40 0.094], ...
        'BackgroundColor',C_BADGE,'ForegroundColor',C_BG, ...
        'FontSize',34,'FontWeight','bold','HorizontalAlignment','center');

    %% Reference photo and instructions
    pInstr = uipanel(fig, ...
        'Position',        [0.218 0.01 0.295 0.930], ...
        'BackgroundColor', C_BG, ...
        'ForegroundColor', C_HYD_DARK, ...
        'BorderType','line','HighlightColor',C_HYD, ...
        'Title','  How to Position Your Hand', ...
        'FontSize',12,'FontWeight','bold');

    % Reference photo axes
    hAxRef = axes(pInstr,'Units','normalized', ...
        'Position',[0.03 0.43 0.94 0.545], ...
        'Color',C_PANEL,'XTick',[],'YTick',[], ...
        'Box','on','XColor',C_HYD,'YColor',C_HYD);
    axis(hAxRef,'image'); axis(hAxRef,'off');

    % Load reference photo
    try
        refImg = imread('assets/REFERENCE.png');
        imshow(refImg,'Parent',hAxRef);
        axis(hAxRef,'image'); axis(hAxRef,'off');
    catch
        showRefPlaceholder(hAxRef);
    end

    % Instructions text
    instrStr = sprintf([ ...
        'Place your hand flat on a plain light-coloured background with fingers spread apart.\n\n' ...
        'Place a standard credit card in portrait orientation (54 mm wide 85.6 mm tall) beside your hand.\n\n' ...
        'Take the photo from directly above, an overhead shot only.\n\n'  ...
        'The card should be placed portrait but slight angles will still work, make sure hand and card do not overlap.' ...
    ]);
    uicontrol(pInstr,'Style','text','String',instrStr, ...
        'Units','normalized','Position',[0.03 0.01 0.94 0.41], ...
        'BackgroundColor',C_BG,'ForegroundColor',C_BLACK, ...
        'FontSize',9.5,'HorizontalAlignment','left');

    %% Annotated result
    pRes = uipanel(fig, ...
        'Position',        [0.520 0.010 0.474 0.930], ...
        'BackgroundColor', C_BG,'ForegroundColor',C_HYD_DARK, ...
        'BorderType','line','HighlightColor',C_HYD, ...
        'Title','  Annotated Result','FontSize',11,'FontWeight','bold');
    hAxResult = axes(pRes,'Position',[0.02 0.04 0.96 0.91], ...
        'Color',C_PANEL,'XTick',[],'YTick',[], ...
        'Box','on','XColor',C_HYD,'YColor',C_HYD);
    axis(hAxResult,'image'); axis(hAxResult,'off');
    text(0.5,0.5,'Result will appear here after processing', ...
        'Parent',hAxResult,'Color',[0.55 0.50 0.50], ...
        'FontSize',12,'HorizontalAlignment','center','Units','normalized');

    % Shared variable
    imagePath = '';

    %%  Callbacks
    function browseHandCallback(~,~)
        [fname,fpath] = uigetfile( ...
            {'*.jpg;*.jpeg;*.png;*.bmp;*.tif;*.tiff','Image files'}, ...
            'Select hand image to measure');
        if isequal(fname,0), return; end
        imagePath = fullfile(fpath,fname);
        dispName  = fname;
        % Shorten long filenames for display
        if numel(dispName)>36, dispName=['...' dispName(end-33:end)]; end
        set(hFileLbl,'String',dispName,'ForegroundColor',C_BLACK);
        set(hStatus,'String','Image selected. Press ▶ ESTIMATE RING SIZE to begin.');
    end

    function runCallback(~,~)
        if isempty(imagePath)
            set(hStatus,'String','Please select a hand image first.');
            return
        end
        measPos = str2double(get(hMeasEdit,'String'));
        if isnan(measPos)||measPos<0||measPos>1
            set(hStatus,'String','Measurement position must be 0 – 1.');
            return
        end

        handSide = 'R';
        if hBtnGrp.SelectedObject == hRadioL, handSide = 'L'; end

        % Determine finger order depending on hand side
        fingerLabels = {'Ring','Middle','Index','Pinky','Thumb'};
        selFinger    = fingerLabels{get(hFingerPop,'Value')};
        if strcmpi(handSide,'L')
            fnames = {'Pinky','Ring','Middle','Index','Thumb'};
        else
            fnames = {'Thumb','Index','Middle','Ring','Pinky'};
        end
        tgtFinger = find(strcmpi(fnames,selFinger),1);
        if isempty(tgtFinger)
            set(hStatus,'String', ...
                sprintf('"%s" unavailable for %s hand.',selFinger,handSide));
            return
        end

        % Disable run button during processing
        set(hStatus,'String','Processing… please wait.');
        set(hRun,'Enable','off');
        set(hBadge,'String','…');
        set(hResult,'String','Processing…');
        drawnow;

        try
            [d_mm,c_mm,ring_letter,annotated] = runPipeline( ...
                imagePath,tgtFinger,fnames,measPos);

            imshow(annotated,'Parent',hAxResult);
            axis(hAxResult,'image'); axis(hAxResult,'off');

            set(hResult,'String',sprintf( ...
                'Hand   : %s\nFinger : %s\nDiam   : %.2f mm\nCirc   : %.2f mm\nUK     : %s', ...
                handSide,selFinger,d_mm,c_mm,ring_letter));
            set(hBadge,'String',ring_letter);
            set(hStatus,'String',sprintf( ...
                'Done.  UK size: %s  |  %.1f mm diam  |  %.1f mm circ', ...
                ring_letter,d_mm,c_mm));
        catch ME
            set(hStatus,'String',['Error: ' ME.message]);
            set(hResult,'String','Processing failed.');
            set(hBadge,'String','!');
        end
        set(hRun,'Enable','on');
    end
end

% Placeholder displayed when reference photo is not found
function showRefPlaceholder(ax)
    cla(ax);
    text(0.5, 0.6, 'Reference photo not found.','Parent',ax,'Units','normalized','HorizontalAlignment','center','FontSize',9,'Color',[0.50 0.45 0.45]);
    text(0.5, 0.4, sprintf('Set REF\_PHOTO\_PATH\nat the top of the script.'),'Parent',ax,'Units','normalized', ...
        'HorizontalAlignment','center','FontSize',8.5,'Color',[0.58 0.50 0.75],'FontWeight','bold');
    axis(ax,'off');
end

    %%  Core processing pipeline
function [d_mm, c_mm, ring_letter, annotated] = runPipeline( ...
        IMAGE_FILE, TARGET_FINGER, finger_names, MEASURE_POSITION)

    % Constants
    NARROW        = 25;
    BRIDGE_DISK   = 12;
    CARD_H_MM     = 54.0;
    CARD_W_MM     = 85.6;
    CARD_RATIO    = CARD_W_MM / CARD_H_MM;
    CARD_ERODE_PX = 8;

    % Annotation sizes
    FONT_FINGER = 28;
    FONT_LARGE  = 36;
    FONT_CARD   = 24;

    % Annotation colours
    ANN_BOX_FINGER = uint8([210 200 230]);
    ANN_BOX_MEAS   = uint8([ 97  77 147]);
    ANN_BOX_CARD   = uint8([148 127 191]);
    ANN_LINE       = uint8([148  60 130]);  

    f = imread(IMAGE_FILE);

    %% Skin segmentation
    HSV = rgb2hsv(f); [H,S,V] = imsplit(HSV);
    skin_mask = ((H>=0.00&H<=0.10)|(H>=0.90&H<=1.00)) & (S>=0.10&S<=0.85) & (V>=0.35&V<=1.00);

    %% Morphological cleaning
    mask_eroded = imerode(skin_mask,strel('disk',BRIDGE_DISK));
    CC_e = bwconncomp(mask_eroded);
    np   = cellfun(@numel,CC_e.PixelIdxList); [~,li]=max(np);
    mask_clean = false(size(mask_eroded));
    mask_clean(CC_e.PixelIdxList{li}) = true;
    mask_clean = imfill(mask_clean,'holes');

    %% Skeleton & fingertips
    skeleton      = bwmorph(mask_clean,'thin',Inf);
    endpoints_raw = bwmorph(skeleton,'endpoints');
    hand_rows  = find(any(mask_clean,2));
    row_cutoff = hand_rows(1) + 0.70*(hand_rows(end)-hand_rows(1));
    endpoints_raw(round(row_cutoff):end,:) = false;

    % Cluster nearby endpoints
    [ep_row,ep_col] = find(endpoints_raw);
    used=false(size(ep_col)); merged_col=[]; merged_row=[];
    for i=1:length(ep_col)
        if used(i),continue;end
        d=sqrt((ep_col-ep_col(i)).^2+(ep_row-ep_row(i)).^2);
        cl=d<20;
        merged_col(end+1)=round(mean(ep_col(cl)));
        merged_row(end+1)=round(mean(ep_row(cl)));
        used(cl)=true;
    end
    ep_col=merged_col(:); ep_row=merged_row(:);

    % Divide hand width into 5 columns and pick the highest endpoint in each
    hand_cols=find(any(mask_clean,1));
    bw=(hand_cols(end)-hand_cols(1))/5;
    fc_=zeros(1,5); fr_=zeros(1,5); fv=false(1,5);
    for k=1:5
        bl=hand_cols(1)+(k-1)*bw; br=hand_cols(1)+k*bw;
        ib=ep_col>=bl & ep_col<br;
        if any(ib)
            br2=ep_row(ib); bc=ep_col(ib);
            [~,ti]=min(br2); fc_(k)=bc(ti); fr_(k)=br2(ti); fv(k)=true;
        end
    end

    % Sort detected fingertips left to right
    ep_col=fc_(fv)'; ep_row=fr_(fv)';
    [~,si]=sort(ep_col); ep_col=ep_col(si); ep_row=ep_row(si);

    %% Card calibration
    % Detect edges, close gaps, fill blobs and exclude the hand region
    fe = edge(rgb2gray(f), 'Canny');
    ff = imfill(imclose(fe, strel('rectangle',[5 5])), 'holes');
    fc2 = bwareaopen(ff, 1000) & ~mask_clean;
    CC  = bwconncomp(fc2);
    if CC.NumObjects == 0
        error('No card blob found (Canny method).');
    end

    % Score each blob by how closely its aspect ratio matches a credit card
    st = regionprops(CC, 'BoundingBox', 'Extent');
    bs = Inf;  ci = 1;
    for i = 1:CC.NumObjects
        [ri, ci2] = ind2sub(size(fc2), CC.PixelIdxList{i});
        co = [ci2 - mean(ci2),  ri - mean(ri)];
        [Vi, ~] = eig((co'*co) / size(co,1));
        dm = range(co * Vi(:,2));   dn = range(co * Vi(:,1));
        sc = abs(max(dm,dn) / max(min(dm,dn),1) - CARD_RATIO) ...
             + (1 - st(i).Extent);
        if sc < bs,  bs = sc;  ci = i;  end
    end
   
    card_mask_raw = false(size(fc2));
    card_mask_raw(CC.PixelIdxList{ci}) = true;

    % Get bounding box and erode card mask to remove edge noise
    cb=regionprops(card_mask_raw,'BoundingBox'); card_bb=cb.BoundingBox;
    cem=imerode(card_mask_raw,strel('disk',CARD_ERODE_PX));
    if ~any(cem(:)), cem=card_mask_raw; end

    % Find card axes
    [r_px,c_px]=find(cem); cx=mean(c_px); cy=mean(r_px);
    co=[c_px-cx, r_px-cy]; [Vc,~]=eig((co'*co)/size(co,1));
    mv=Vc(:,2); nv=Vc(:,1);
    dm=range(co*mv); dn=range(co*nv);
    ref_px=min(dm,dn); px_per_mm=ref_px/CARD_H_MM;

    % Compute card corner coordinates
    hw=dm/2; hh=dn/2;
    loc=[hw hh;hw -hh;-hw -hh;-hw hh;hw hh];
    corners_c=cx+loc(:,1)*mv(1)+loc(:,2)*nv(1);
    corners_r=cy+loc(:,1)*mv(2)+loc(:,2)*nv(2);

    %% Finger widths
    wm=zeros(1,length(ep_col)); mr_all=zeros(1,length(ep_col));
    lca=zeros(1,length(ep_col)); rca=zeros(1,length(ep_col));

    for k=1:min(length(ep_col),5)
        tr=ep_row(k); tc=ep_col(k);
        % Restrict search to a narrow column window centred on the fingertip
        nl=max(tc-NARROW,1); nr=min(tc+NARROW,size(mask_clean,2));
        msw=1; knr=round(row_cutoff);
        % Scan downward from fingertip to find the knuckle
        for r=tr:round(row_cutoff)
            w=sum(mask_clean(r,nl:nr));
            if w==0,continue;end
            if w>msw*1.8&&r>tr+10,knr=r;break;end
            msw=max(msw,w);
        end

        % Width at the user-specified fractional position along the finger
        fl=knr-tr; msr=min(max(tr+round(MEASURE_POSITION*fl),tr+1),knr);
        ra=find(skin_mask(msr,:));
        if ~isempty(ra)
            g=find(diff(ra)>1);
            rs=[ra(1),ra(g+1)]; re=[ra(g),ra(end)];
            [~,b]=min(abs((rs+re)/2-tc));
            lc=rs(b); rc2=re(b);
        else, lc=tc; rc2=tc; 
        end

        % Convert pixel width to mm and store measurement row and edges
        wm(k)=(rc2-lc+1)/px_per_mm; mr_all(k)=msr; lca(k)=lc; rca(k)=rc2;
    end

    %% UK ring size
    ul={'F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'};
    uc=[41.7,43.0,44.2,45.5,46.8,48.0,49.3,50.6,51.9,53.1, ...
        54.4,55.7,57.0,58.3,59.5,60.8,62.1,63.4,64.6,65.9,67.2];
    tk=min(TARGET_FINGER,length(ep_col));
    d_mm=wm(tk); c_mm=pi*d_mm;

    % Find the closest matching ring size by circumference
    [~,si]=min(abs(uc-c_mm)); ring_letter=ul{si};

    %% Build annotated image
    annotated = f;

    % Skeleton
    sv=skeleton;
    for i=1:15, et=bwmorph(sv,'endpoints'); sv=sv&~et; end
    [skr,skc]=find(sv);
    for i=1:length(skr)
        annotated=setPixel(annotated,skr(i),skc(i),[185 170 215]);
    end

    % Fingertip circles
    for k=1:min(length(ep_col),5)
        annotated=drawCircle(annotated,ep_row(k),ep_col(k),14, ...
            double(ANN_BOX_MEAS));
    end

    % Measurement line
    if wm(tk)>0
        mr=mr_all(tk); lc=lca(tk); rc=rca(tk);
        for c=lc:rc
            for dt=-2:2
                annotated=setPixel(annotated,mr+dt,c,double(ANN_LINE));
            end
        end
        for dr=-14:14
            for dt=-1:1
                annotated=setPixel(annotated,mr+dr,lc+dt,double(ANN_LINE));
                annotated=setPixel(annotated,mr+dr,rc+dt,double(ANN_LINE));
            end
        end
    end

    % Card outline
    for seg=1:4
        annotated=drawLine(annotated, ...
            round(corners_r(seg)),round(corners_c(seg)), ...
            round(corners_r(seg+1)),round(corners_c(seg+1)), ...
            double(ANN_BOX_CARD));
    end

    % Text labels
    try
        for k=1:min(length(ep_col),5)
            annotated=insertText(annotated, ...
                [ep_col(k)+16, ep_row(k)-14], finger_names{k}, ...
                'FontSize',FONT_FINGER, ...
                'TextColor','black', ...
                'BoxColor',ANN_BOX_FINGER, ...
                'BoxOpacity',0.70);
        end
        if wm(tk)>0
            mr=mr_all(tk); rc=rca(tk);
            txt=sprintf('%.1f mm  |  Circ: %.1f mm  |  UK Size: %s', ...
                d_mm,c_mm,ring_letter);
            annotated=insertText(annotated,[rc+18, mr-14],txt, ...
                'FontSize',FONT_LARGE, ...
                'TextColor','white', ...
                'BoxColor',ANN_BOX_MEAS, ...
                'BoxOpacity',0.82);
        end
        annotated=insertText(annotated, ...
            [card_bb(1), max(card_bb(2)-26,1)], ...
            sprintf('REF: %.1f mm (short edge)',CARD_H_MM), ...
            'FontSize',FONT_CARD, ...
            'TextColor','white', ...
            'BoxColor',ANN_BOX_CARD, ...
            'BoxOpacity',0.75);
    catch
    end
end

%%  Pixel/Drawing Helpers
% Set a single RGB pixel
function img = setPixel(img,r,c,rgb)
    r=round(r); c=round(c);
    if r<1||r>size(img,1)||c<1||c>size(img,2),return;end
    img(r,c,1)=rgb(1); img(r,c,2)=rgb(2); img(r,c,3)=rgb(3);
end

% Draw a circle
function img = drawCircle(img,cr,cc,radius,rgb)
    for a=0:0.5:360
        img=setPixel(img,round(cr+radius*sind(a)), ...
                         round(cc+radius*cosd(a)),rgb);
    end
end

% Draw a line between two points
function img = drawLine(img,r0,c0,r1,c1,rgb)
    n=max(abs(r1-r0),abs(c1-c0))+1;
    rs=round(linspace(r0,r1,n)); cs=round(linspace(c0,c1,n));
    for i=1:n
        for t=-1:1
            img=setPixel(img,rs(i)+t,cs(i),rgb);
            img=setPixel(img,rs(i),cs(i)+t,rgb);
        end
    end
end