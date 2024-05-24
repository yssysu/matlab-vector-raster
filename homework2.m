clear,clc,close all

% 读取矢量数据
I = shaperead('Maps_1/GHM_region.shp');
% 读取栅格数据
% 读取 GeoTIFF 文件的空间参考信息
[G,R] = geotiffread("map.tif");
G = double(G);
% 将小于0的值转换成NAN以减小其影响
G(G < 0) = NaN;
% 读取tif文件信息
info = geotiffinfo('map.tif');

% 创建相同大小的网格
[rows, cols] = size(G);
[colGrid, rowGrid] = meshgrid(1:cols, 1:rows);
% 划定裁剪的范围，即确定shp文件的经纬度范围
xboundary = info.BoundingBox(:,1);
yboundary = info.BoundingBox(:,2);
% 调整像素的大小以适应网格
xscale = info.PixelScale(1);
yscale = info.PixelScale(2);
xlon = xboundary(1) + (colGrid - 1) * xscale;
ylat = yboundary(2) - (rowGrid - 1) * yscale;

% 创建一个与栅格数据相同大小的遮罩
mask = false([rows, cols]);
% 对每个区域生成遮罩并应用
for k = 1:length(I)
    % 去除 NaN 值
    % X = I(k).X(~isnan(I(k).X));
    % Y = I(k).Y(~isnan(I(k).Y));
    % 发现如果加上上面两句会使裁剪后的图像缺少部分数据，像是被挖空了一样

    % 生成区域的遮罩，
    % 这里规避了之前出现的只有一两个点的问题，将shp文件进行遍历（不知道这样说对不对？
    maskRegion = inpolygon(xlon,ylat,I(k).X,I(k).Y);
    % 将区域遮罩与整体遮罩合并
    mask =mask|maskRegion;
end

% 将遮罩应用到栅格数据上
G(~mask) = NaN;
% 显示矢量数据
subplot(221);mapshow(I);title('矢量数据图');axis off
% 显示栅格数据
map = imread("map.tif");subplot(222);imshow(map);title('栅格数据图')

% 显示裁剪后的栅格数据
subplot(223)
% 这里如果不对生成的图像进行处理则会导致裁剪后的图像不是居中
imshow(G);
axis off;title('裁剪后的栅格数据-未处理');

subplot(224)
geoshow(G,R,'DisplayType','surface');
axis off;title('裁剪后的栅格数据-处理后');

