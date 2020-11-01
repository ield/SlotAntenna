%				VECP

% Vectorial product
% Calcula el producto vectorial de dos matrices de tres
% filas (componentes) y n columnas
function y=vecp(u,v)
y(1,:)=u(2,:).*v(3,:)-u(3,:).*v(2,:);
y(2,:)=u(3,:).*v(1,:)-u(1,:).*v(3,:);
y(3,:)=u(1,:).*v(2,:)-u(2,:).*v(1,:);

