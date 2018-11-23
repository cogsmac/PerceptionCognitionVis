function [nn] = DrawTriangle(win,ex,wy,ori,hite,wdth,col)

%% Draw Triangle function
%  Written by Adriane E. Seiffert, July 2008
%  
%  Simple function that draws an isosceles triangle 
%  in the window (win) at center position (ex, wy), 
%  with orientation (ori) clockwise relative to vertical
%  and height (hite) and width (wdth)
%  and in the color triplet (col).  
%
%  DrawTriangle(window, ex, wy, ori, hite, wdth, col)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nn=1;

xv1 = (hite/2)*(sin(ori));  %Front vertex
yv1 = -(hite/2)*(cos(ori));
xv2 = (-xv1)+ (wdth/2)*(cos(ori));  %Right hand vertex
yv2 = (-yv1)+ (wdth/2)*(sin(ori));
xv3 = xv2 - (wdth)*(cos(ori));  %Left hand vertex
yv3 = yv2 - (wdth)*(sin(ori));

vertlist = [xv1+ex, yv1+wy; xv2+ex, yv2+wy; xv3+ex, yv3+wy];

Screen('FillPoly', win ,col, vertlist);

end

