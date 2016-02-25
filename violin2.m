function violin2(y1, n1, y2, n2, num_points)

if nargin <  5
    num_points = 1000;
end

% First spline
DF1 = smhist(y1, n1);

% Second spline
DF2 = smhist(y2, n2);

% Make the second one negative
DF2.coefs = -1 * DF2.coefs;

% Make the plots
x_01 = linspace(DF1.breaks(1), DF1.breaks(end), num_points);
x_02 = linspace(DF2.breaks(1), DF2.breaks(end), num_points);

y_01 = fnval(DF1, x_01);
y_02 = fnval(DF2, x_02);

y_01(y_01 < 0) = 0;
y_02(y_02 > 0) = 0;

fill(x_01, y_01, 1 / 255 * [231, 150, 118], 'facealpha', 0.6);
hold on
fill(x_02, y_02,  1 / 255 * [114, 183, 161], 'facealpha', 0.6); 
hold off;
axis square
set(gca, 'view', [90, 90]);
axis off
pbaspect([2.5, 1, 1]);


end