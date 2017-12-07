%% Spar Sizing Using Symbolic Lift Equation
function ro_spar_cyl_mm = SparSizing(lw,W,Ws,n,Co,Ct,Uts,t)
syms x
% W = Total Aircraft Mass, kg
% Ws = Wing Structural Mass, kg
% lw = Distance from root to wing tip, m
% t = thickness for the spar, m
% n = Load Factor, Lift/Weight, n=1 for normal flight;
% Co = Chord length of wing at wing root, m
% Ct = Chord length of wing at wing tip, m
% Uts = Ultimate Tensile Strength of CF, 600*(10^6) Pa;
W = W *9.81; % Total Aircraft Weight, N
Ws = Ws * 9.81; % Wing Structural Weight, N
Co = Co /1000; % If Co is in mm
Ct =  Ct/1000; % If Ct is in mm
lw = lw/1000; % If lw is in mm
s = 0.002*tan(30*pi/180); % Small distance 

%% Lift Force Generated on the wing
ql = (2*W*n)*sqrt((lw^2)-(x^2))/(pi*lw^2);

%% Structural Weight of Wing
qw = Ws*n*(Co*x-Ct*x-Co*lw)/((lw^2)*(Co+Ct));


%% Total Load on the Wing Spar
qt = ql+qw;

%%Shear Force Equation Acting on the Spar
V =  int(-qt,x);

%% Bending Moment Acting on the Spar
M = int(V,x);
C = (Co*Ws*lw*n)/(2*(Co + Ct)) - (lw^3*(Co*Ws*n - Ct*Ws*n))/(6*Co*lw^2 + 6*Ct*lw^2) + real((W*lw*n*log(lw*1i)*1i))/pi;
M0 = M - C;
fplot(M0,[0 lw]);
xlabel('Distance from root, m') % x-axis label
ylabel('Bending Moment, Nm') % y-axis label
x = 0;
MaxM0 = subs(M0);
MaxM0 = double(MaxM0);

%% Minimum Outer Radius for Cylinder CF Tube
a = 4*t;
b = -6*(t^2);
c = 4*(t^3)-(4*MaxM0/(pi*Uts));
d = -(t^4);
r = roots([a b c d]);
ro_spar_cyl_m = r(real(r) & imag(r)==0);
ro_spar_cyl_mm = ro_spar_cyl_m*1000;

%%Minimum Side Length of Hexagonal Tube
a = s;
b = -3*(s^2);
c = (4*(s^3))-(0.2*MaxM0/Uts);
d = -2*(s^4);
a_spar_hex_m = roots([a b c d]);
a_spar_hex_m = a_spar_hex_m(real(a_spar_hex_m)& imag(a_spar_hex_m)==0);
a_spar_hex_mm = a_spar_hex_m*1000;
%I_hex_m4 = (5*(13^0.5)/16)*(((a_spar_hex_m)^4)-(((a_spar_hex_m)-s)^4));

%%Maximum Stress Calculation

%Stress_hex = MaxM0*(a_spar_hex_m)/(I_hex_m4);
%Stress_cyl = MaxM0*(ro_spar_cyl_m)/(I_cyl_m4);
end
