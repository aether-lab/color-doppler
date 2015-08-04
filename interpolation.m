function [UU velocity_map reconstructed mapp ]=interpolation(Im_color,rgb_error, Vmin, Vmax,sp_rgb,full_scale)

tic
for i=1:size(Im_color,1)
    for j=1:size(Im_color,2)
        rgb3 = permute(double(Im_color(i,j,:)),[3,1,2]);
        if sum(rgb3 ~= [0;0;0]) > 0 
            [ velocity, errvel] = fminbnd(rgb_error,Vmin,Vmax,optimset('TolX',1e-3),sp_rgb,permute(double(Im_color(i,j,:)),[3,1,2]));
            color_err(i,j)    = errvel;
            velocity_map(i,j) = velocity;
        else
            color_err(i,j)    = 0;
            velocity_map(i,j) = 0;
        end
    end
end
toc

% go back from velocities to colors
reconstructed = permute(uint8(fnval(sp_rgb,velocity_map)),[2,3,1]);

%plot some results
 mapp = flipud(fnval(sp_rgb,full_scale')')./255;
for i=1:length(full_scale)
    for j=1:3,
        if mapp(i,j) > 1
            mapp(i,j) = 1;
        end,
        if mapp(i,j) < 0
            mapp(i,j) = 0;
        end
    end
end

for i=1:length(full_scale)
    for j=1:3
        if mapp(i,j) > 1
            mapp(i,j) = 1;
        end
        if mapp(i,j) < 0
            mapp(i,j) = 0;
        end
    end
end

UU=flipdim(velocity_map,1);