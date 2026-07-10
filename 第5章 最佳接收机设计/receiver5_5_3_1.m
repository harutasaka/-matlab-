b = [0.5 1 -0.6];
m = 1000;
s = sign(randn(1,m));
r = filter(b,1,s);
n = 4;
f = zeros(n,1);
mu = 0.1;
delta = 3;
for i=n+1:m
    rr = r(i:-1:i-n+1)';
    e = s(i-delta)-f'*rr;
    f = f+mu*e*rr;
end
y = filter(f,1,r);
dec = sign(y);
for sh=0:n
    err(sh+1) = 0.5*sum(abs(dec(sh+1:end)-s(1:end-sh)));
end

disp(err)