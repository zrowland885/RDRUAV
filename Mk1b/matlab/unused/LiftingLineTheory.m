%% Lifting-line Theory
%
% This is a simple function for solving lifting-line theory / monoplane equation
% on an unswept wing of any taper ratio.
% It assumes that the wing is not maneuvering, i.e., there are no aileron
% deflections, and so only odd terms on the sine series are used to create a
% symmetric lift distribution.
%
% Inputs:
%         a0      = Sectional lift curve slope per radians ( normally 2*pi )
%         AR      = Aspect ratio of wing
%         lambda  = Taper ratio, c_t/c_r
%         alpha0l = Sectional zero lift angle of attack in degrees
%         alpha   = Geometric angle of attack in degrees
%         numlocs = Number of spanwise stations / terms in sine series
%
% There are no checks on the correctness of your inputs, so tread carefully!
%
% Outputs:
%         CL  = Wing lift coefficient
%         CDi = Induced drag coefficient
%         e   = Span efficiency factor
%
% I've left a few notes on where this could be vectorized for Matlab,
% but since it's such a small function, and it could be ported to other
% languages, it's not worth obfuscating the code.
%
% Created by: Joseph Derlaga, 10/16/09

function [CL, CDi, e] = ...
    LiftingLineTheory( a0, AR, lambda, alpha0l, alpha, numlocs)

%% Convert degree values to radians
%  Depending on your version of Matlab, you can use either of these methods
alphar = alpha*pi/180;
alpha0lr = alpha0l*pi/180;

%alphar = degtorad(alpha);
%alpha0lr = degtorad(alpha0l);

%% Initialize work arrays
LHS = zeros(numlocs,numlocs);
RHS = zeros(numlocs,1);
phi = zeros(numlocs,1);
Cl  = zeros(numlocs,1);

%% Angles for station locations
for n = 1:numlocs
    phi(n) = n*pi/(2*numlocs);
end
% Could vectorize the above lines

%% Create the system of equations for solving LLT/Monoplane Equation
for a = 1:numlocs
    
    mu = (a0 / ( 2 * AR * ( 1 + lambda ) )) * (1 + ( lambda - 1 )*cos(phi(a)));
    RHS(a,1) = mu * ( alphar - alpha0lr ) * sin(phi(a));

    for n = 1:2:2*numlocs-1
        LHS(a,(n+1)/2) = sin(n*phi(a)) * ( n*mu + sin(phi(a)) );
    end
    
end
% Could vectorize some of the above lines

%% Solve
A = LHS\RHS;

%% Extract quantities of interest
CL = A(1)*pi*AR;

for n = 1:numlocs
    Asum = 0;
    for m = 1:numlocs
        Asum = Asum + A(m) * sin( (2*m-1) * phi(n) );
    end
    % Could replace the above for loop with:
    %Asum = sum(A(1:numlocs).*sin(2*(1:numlocs)-1)'*phi(n));
    Cl(n) = 2 * AR *( 1 + lambda ) * ...
        (1 / ( 1 + ( lambda - 1 ) * cos(phi(n)) )) * Asum;
end

einv = 0;
for n = 1:numlocs
    einv = einv + (2*n-1)*A(n)^2/A(1)^2;
end
% Could replace the above for loop with:
%einv = sum( (2*(1:numlocs)-1)*A(1:numlocs).^2/A(1)^2 );

CDi = einv*CL^2/(pi*AR);

e = 1/einv;
