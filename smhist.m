function DF = smhist(y, num_bins)


[heights,centers] = hist(y, num_bins);

n = length(centers);
w = centers(2)-centers(1);
t = linspace(centers(1)-w/2,centers(end)+w/2,n+1);

dt = diff(t);
Fvals = cumsum([0,heights.*dt]);

F = spline(t, [0, Fvals, 0]);

DF = fnder(F);  % computes its first derivative

end