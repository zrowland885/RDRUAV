function d = PointToLine(pt, v1, v2)
%POINTTOLINE Finds the shortest distance from a point to a line.

a = v1 - v2;
b = pt - v2;
d = norm(cross(a,b))/norm(a);

end

