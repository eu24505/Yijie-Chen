%% 读取 CSV（把文件名改成你的）
M = readmatrix('dta.csv');

% 找到两段表头行（首列为 NaN）
hdr_rows = find(isnan(M(:,1)));
if numel(hdr_rows) < 2
    error('未检测到两段表头，请检查CSV格式。');
end
h1 = hdr_rows(1);   % 第一段（应力）表头
h2 = hdr_rows(2);   % 第二段（形变）表头

%% ===== 上半段：Stress (Pa) -> MPa =====
force_stress = M(h1, 2:end);          % 列表头：力(N)
thick_stress = M(h1+1 : h2-1, 1);      % 行标签：厚度(mm)
Z_stress_MPa = M(h1+1 : h2-1, 2:end) / 1e6;   % 主体：Pa->MPa

[Xs, Ys] = meshgrid(thick_stress, force_stress);
Zs = Z_stress_MPa.';   % 与 meshgrid 尺寸匹配

% 3D 曲面 + 安全平面(32.5 MPa)
safe_stress = 32.5; % MPa
figure;
surf(Xs, Ys, Zs, 'EdgeColor','none'); hold on;
sp = surf(Xs, Ys, safe_stress*ones(size(Zs)));
set(sp,'FaceAlpha',0.35,'EdgeColor','none');
xlabel('Thickness (mm)'); ylabel('Force (N)'); zlabel('Stress (MPa)');
title('Stress vs Thickness & Force'); colorbar; grid on; view(135,30);
legend('Stress surface', 'Safe stress = 32.5 MPa');
ax = gca; ax.XAxis.Exponent=0; ax.YAxis.Exponent=0; ax.ZAxis.Exponent=0;

% 等高图 + 32.5 MPa 等值线
figure;
contourf(Xs, Ys, Zs, 20); hold on;
contour(Xs, Ys, Zs, [safe_stress safe_stress], 'r', 'LineWidth', 2);
xlabel('Thickness (mm)'); ylabel('Force (N)');
title('Stress (MPa) Contours'); colorbar; grid on;

% 多条 2D 曲线（Stress，不同力，渐变颜色 + 红色安全线）
figure; hold on;

cmap = parula(numel(force_stress));   % 或 jet/turbo/hot
for j = 1:numel(force_stress)
    plot(thick_stress, Z_stress_MPa(:,j), 'LineWidth',1.8, 'Color', cmap(j,:));
end

% 添加红色虚线（安全应力）
yline(safe_stress,'--r','Safe 32.5 MPa', ...
    'LabelHorizontalAlignment','right','LineWidth',1.5);

xlabel('Thickness (mm)'); ylabel('Stress (MPa)');
title('Stress vs Thickness at Different Forces');

colormap(cmap);
cb = colorbar; 
cb.Label.String = 'Force (N)';
caxis([min(force_stress) max(force_stress)]);

grid on;


%% ===== 下半段：Deformation (m) -> mm =====
force_def   = M(h2, 2:end);            % 列表头：力(N)
thick_def   = M(h2+1 : end, 1);        % 行标签：厚度(mm)
Z_def_mm    = M(h2+1 : end, 2:end) * 1e3;  % 主体：m->mm

[Xd, Yd] = meshgrid(thick_def, force_def);
Zd = Z_def_mm.';

% 3D 曲面（形变）
figure;
surf(Xd, Yd, Zd, 'EdgeColor','none'); hold on;
xlabel('Thickness (mm)'); ylabel('Force (N)'); zlabel('Deformation (mm)');
title('Deformation vs Thickness & Force'); colorbar; grid on; view(135,30);
ax = gca; ax.XAxis.Exponent=0; ax.YAxis.Exponent=0; ax.ZAxis.Exponent=0;

% 等高图（形变）
figure;
contourf(Xd, Yd, Zd, 20);
xlabel('Thickness (mm)'); ylabel('Force (N)');
title('Deformation (mm) Contours'); colorbar; grid on;

% 多条 2D 曲线（不同力，渐变颜色）
figure; hold on;
cmap = parula(numel(force_def));   % 或 jet/hot/turbo 等
for j = 1:numel(force_def)
    plot(thick_def, Z_def_mm(:,j), 'LineWidth',1.8, 'Color', cmap(j,:));
end
xlabel('Thickness (mm)'); ylabel('Deformation (mm)');
title('Deformation vs Thickness at Different Forces');
colormap(cmap);
cb = colorbar; cb.Label.String = 'Force (N)';
caxis([min(force_def) max(force_def)]);
grid on;

% （可选）允许形变基准线，例如 0.5 mm
% allow_def = 0.5;
% yline(allow_def,'--k','Allow = 0.5 mm');
