%% Boom Sizing Function
function ro_boom_mm = BoomSizing(P,wt,lt,E,W,v)

%%Simplified Boom Loading with Cantilever Case
%Weight of the tail in N
wt = wt*9.81;
%Distance from fuselage to tail in m
lt = lt/1000;
%Maximum Bending moment on the boom in Nm
M_boom = (P-wt)*lt;

%%Solving ro_boom by Energy Method and 2nd moment of area of boom
%solve boom ro_boom
%Total Weight of the UAV in N
W = W*9.81;
a = 128*((P-wt)^2)*(lt^3)/(6*E*pi*W(v^2));
ro_boom_m = roots([1 -3 4 -4-(a/4)]);
%Real roots for ro_boom in metres
ro_boom_m = ro_boom_m(real(ro_boom_m)& imag(ro_boom_m)==0);
ro_boom_mm = ro_boom_m*1000;
%Second moment area of boom in m^4
I_boom_m4 = ((pi/64)*((ro_boom_m^4)-((ro_boom_m-2)^4)));
I_boom_mm4 = I_boom_m4*(10^12);
%Equation of beam static energy of boom
U_boom_PE_J = (0.5/(E*I_boom_m4))*sum_M_sqr;
%kinetic energy calculated by stall speed
U_boom_KE_J = 0.5*W*(v^2);

%%
%Maximum stress applied on the boom
stress_boom_Pa = M_boom * ro_boom/I_m4;
end