% test_plot

num_points = 10;

x = linspace(0, 2*pi, num_points);
y = zeros(num_points, 1);

t = 0;

amplitude = 2E3;
size_min = 1;

while t < 10
    
   sizes = amplitude * (sin(x + t * 2 * pi) + 1) + eps;
   
   scatter(x, y, sizes, 'blue', 'filled', 'markerfacealpha', 0.5, 'markeredgecolor', 'black');
   
   grid on
   
   xlim([-1, 2*pi + 1]);
   ylim([-1, 1]);
   axis square;
   
   t = t + 0.01; 
   
   pause(0.01);
end


