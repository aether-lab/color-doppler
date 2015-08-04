function [velocity_map] = color_scale_interp(im)
% Find Image Stack Dimensions
[s1,s2,s3,s4] = size(im);

% Create "blank" image entry
Iblank = zeros(1,1,3);

% Pre-allocate Gray-image stack
imgray = zeros(size(im));

% Pre-allocate color-image stack
imcolor = zeros([s1 s2 s3 s4]);

% Set color tolerance (this value uses tolerances to determine whether
% image entry is a gray value or a color value)
color_tol = 16;

% Loop through image stack to seperate gray-scale and color entries
for ii = 1:s4
    Icolor = im(:,:,:,ii);
    for i=1:size(Icolor,1)
        for j=1:size(Icolor,2)
            if abs(double(Icolor(i,j,1)) - double(Icolor(i,j,2))) <= color_tol ...
                    && abs(double(Icolor(i,j,2)) - double(Icolor(i,j,3))) <= color_tol
                Icolor(i,j,:) = Iblank;
            end
        end
    end
    imgray(:,:,:,ii)  = im(:,:,:,ii) - Icolor;
    imcolor(:,:,:,ii) = Icolor;
end

% Color Scale Interpolation
% Select ColorScale for De-aliasing
figure(1);
set(gcf,'Position',[100,100,s2,s1]);

% First Image read to get color-scale
imagesc(uint8(im(:,:,:,1)));

% Set minimum velocity from image
Vmin = input('Enter a Value for Vmin \n');
% Set maximum velocity from image
Vmax = input('Enter a Value for Vmax \n');

% Select Cropped Region for reducing dealising time
[x,y,I_cscale,rect_cscale]=imcrop(uint8(im(:,:,:,1)));                        % Crop Color Scale From Images for Dealiasing
image(I_cscale);
scale3 = permute(mean(I_cscale, 2),[1,3,2]);
full_scale = linspace(Vmax,Vmin,size(scale3,1))';

% Determine ROI Start & End Locations
xstart = rect_cscale(1);
xend   = rect_cscale(1) + rect_cscale(3);
ystart = rect_cscale(2);
yend   = rect_cscale(2) + rect_cscale(4);

% Run Color Scale Interpolation
for ii = 1:s4
    [height, width,bitdepth] = size(imcolor(ystart:yend,xstart:xend,:,ii));
    Iflat = reshape(imcolor(ystart:yend,xstart:xend,:,ii),[height*width,3]);
    
    figure(4);
    [min_full_scale, min_index] = min(abs(full_scale));
    
    %spline fit for colorscale
    knots = augknt([Vmin,Vmin*3/4,Vmin/2,Vmin*1/4,0,Vmax*1/4,Vmax/2,Vmax*3/4,Vmax],4,[1,1,1,3,1,1,1]);
    ww    = ones(size(full_scale.'));
    ww(1) = 10; ww(end) = 10; ww(min_index) = 10;
    sp_rgb = spap2(knots,4,full_scale.',[scale3(:,1),scale3(:,2),scale3(:,3)]',ww);
    sp_rgb.coefs;
    fnplt(sp_rgb)
    
    hold on
    plot3(Iflat(1:10:end,1),Iflat(1:10:end,2),Iflat(1:10:end,3),'ro');
    plot3(scale3(:,1),scale3(:,2),scale3(:,3),'k');
    hold off
    xlabel('red'),ylabel('green'),zlabel('blue')
    legend('reconstructed color scale','original sampled scale','measured values')
    rgb_error = inline('norm(fnval(sp,x)-rgb)','x','sp','rgb');
    
    pause(1E-1);
    
    % Run interpolation
    [UU(:,:,ii),velocity_map(:,:,ii),reconstructed(:,:,:,ii),mapp] = ...
        interpolation(imcolor(ystart:yend,xstart:xend,:,ii),rgb_error, Vmin, Vmax,sp_rgb,full_scale);
end