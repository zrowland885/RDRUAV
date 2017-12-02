%% Strut Sizing Function
function ro_strut_mm = SparSizing(lw,wf,k,M,E,v)

%%
% Force and Moment Equilibrium with Maclaulay's Method
% Moments in Nm
% Wing Strut cuts into 4 section to calculate maximum bending moment
W = M*9.81;
lw = lw/1000;
wf = wf/1000;
k = k*1000;
R1 = -((W*9.81/2)-(k*lw)-(0.5*k*wf));    %Reaction force at fixed point

%Range of x in interval of (0<=x<=lw)
x1 = 0:.01:lw;
M1 = (k*x1.^2)/2;   %Bending moment equation for interval x1

%Range of x in interval of (lw<=x<=lw+0.5wf)
x2 = lw:.01:lw+0.5*wf;
M2 = ((k*x2.^2)/2)-R1*(x2-lw);  %Bending moment equation for interval x2

%Range of x in interval of (wl+0.5wf<=x<=wl+wf)
x3 = lw+0.5*wf:.01:lw+wf;
 %Bending moment equation for interval x3
M3 = ((k*x3.^2)/2)-R1*(x3-lw)- W*(x3-lw-0.5*wf);

%Range of x in interval of (wl+wf<=x<=2wl+wf)
x4 = lw+wf:.01:2*lw+wf;
%Bending moment equation for interval x4
M4 = ((k*x4.^2)/2)-R1*(x4-lw)-R1*(x4-lw-wf)- W*(x4-lw-0.5*wf);

%Assign the x intervals and moment intervals into array
x = [x1 x2 x3 x4];
M = [M1 M2 M3 M4];
indexmax = find(max(M) == M);
xmax = x(indexmax);
Mmax = M(indexmax);  %Maximum Bending Moment applied on the strut

%%
%Energy Method and calculate ro_strut for required stall speed
%Integrate square of Bending Moment for according to its interval
intM1 = (lw^3)/3;
intM2 = (R1^2*wf^3)/24 + (R1*k*lw^2*wf^2)/8 + (R1*k*lw*wf^3)/12+ ...
        (R1*k*wf^4)/64 + (k^2*lw^4*wf)/8 + (k^2*lw^3*wf^2)/8 + ...
        (k^2*lw^2*wf^3)/16 + (k^2*lw*wf^4)/64 + (k^2*wf^5)/640;
intM3 = (7*R1^2*wf^3)/24 - (5*R1*W*wf^3)/24 + (3*R1*k*lw^2*wf^2)/8 + ...
        (7*R1*k*lw*wf^3)/12 + (15*R1*k*wf^4)/64 + (W^2*wf^3)/24 - ...
        (W*k*lw^2*wf^2)/8 - (5*W*k*lw*wf^3)/24 - (17*W*k*wf^4)/192 + ...
        (k^2*lw^4*wf)/8 + (3*k^2*lw^3*wf^2)/8 + (7*k^2*lw^2*wf^3)/16 + ...
        (15*k^2*lw*wf^4)/64 + (31*k^2*wf^5)/640;
intM4 = (4*R1^2*lw^3)/3 + 2*R1^2*lw^2*wf + R1^2*lw*wf^2 - ...
        (4*R1*W*lw^3)/3 - 2*R1*W*lw^2*wf - R1*W*lw*wf^2 + ...
        (17*R1*k*lw^4)/6 + (17*R1*k*lw^3*wf)/3 + 4*R1*k*lw^2*wf^2 + ...
        R1*k*lw*wf^3 + (W^2*lw^3)/3 + (W^2*lw^2*wf)/2 + ...
        (W^2*lw*wf^2)/4 - (17*W*k*lw^4)/12 - (17*W*k*lw^3*wf)/6 - ...
        2*W*k*lw^2*wf^2 - (W*k*lw*wf^3)/2 + (31*k^2*lw^5)/20 + ...
        (15*k^2*lw^4*wf)/4 + (7*k^2*lw^3*wf^2)/2 + ...
        (3*k^2*lw^2*wf^3)/2 + (k^2*lw*wf^4)/4;
% Sum ofIntergration of M^2 for different x intervals
sum_M_sqr = intM1+intM2+intM3+intM4;
%Simplified Energy Method for outer strut radius
ro_strut_m = roots([1 -3 4 -4-16*sum_M_sqr/(pi*W*(v^2)*E)]);
%Real roots for outer strut radius
ro_strut_m = ro_strut_m(real(ro_strut_m)& imag(ro_strut_m)==0);
ro_strut_mm = ro_strut_m*1000;
%Second moment area of strut
I_strut_m4 = ((pi/64)*((ro_strut_m^4)-((ro_strut_m-2)^4)));
I_strut_mm4 = I_strut_m4*(10^12);
%Strain Energy of the strut
U_strut_PE_J = (0.5/(E*I_strut_m4*(10^-12)))*sum_M_sqr;  
%Kinetic Energy applied on the strut with stall speed
U_strut_KE_J = 0.5*W*(v^2);    
%%
%Calculate maximum stress applied on strut
stress_strut_Pa = (Mmax(1))* ro_strut_m/I_strut_m4;
end
