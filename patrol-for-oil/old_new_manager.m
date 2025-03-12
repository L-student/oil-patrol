clear
clc
% Manipula os arquivos automaticamnete
output_name_txt = 'step.txt';
output_name_nc = 'step.nc';
delete(output_name_txt); % Exclui o arquivo
delete(output_name_nc); % Exclui o arquivo

% Caminho do arquivo a ser copiado
file_initial_txt = 'step_initial.txt';
file_initial_nc = 'step_16_9.nc';
file_modified_txt = 'step.txt';
file_modified_nc = 'step.nc';
copyfile(file_initial_txt, file_modified_txt); % Copia o arquivo
copyfile(file_initial_nc, file_modified_nc); % Copia o arquivo


% Time
t = datetime(2020, 9, 15, 12, 0, 0);
tf = datetime(2020,9 , 20, 12, 0, 0);
t_step = minutes(10);

% Load shp file for Alagoas
sl_alagoas = shaperead('.\shp\BRA_admin_AL.shp');

% Getting region of interest
region = kml2struct('search_region.kml');
res_grid = 111;
width = ceil(res_grid * (region.BoundingBox(2,1) - region.BoundingBox(1,1)));
height = ceil(res_grid * (region.BoundingBox(2,2) - region.BoundingBox(1,2)));
grid = zeros(height, width);
mask = zeros(height, width);
dist_grid = zeros(height, width);
for i = 1:width
    for j = 1:height
        if inpolygon((i/res_grid) + region.BoundingBox(1,1), (j/res_grid) + region.BoundingBox(1,2), region.Lon, region.Lat) == 0
            grid(j, i) = -Inf;
            mask(j, i) = 1;
        else
            dist_grid(j, i) = res_grid * min(sqrt(((i/res_grid) + region.BoundingBox(1,1) - sl_alagoas(1).X).^2 + ((j/res_grid) + region.BoundingBox(1,2) - sl_alagoas(1).Y).^2));
        end
    end
end
max_dist=max(max(dist_grid));
dist_grid = 1/max_dist*5*(~mask.*max_dist-dist_grid)+grid;

x = linspace(region.BoundingBox(1,1), region.BoundingBox(2,1), width);
y = linspace(region.BoundingBox(1,2), region.BoundingBox(2,2), height);
[X, Y] = meshgrid(x, y);

grid_initial = grid;

lon = 0;
lat = 0;

prev_simul = 0;
release = 0;
%%
% 1 day loop
if (prev_simul)
    while t < tf
        t
        
        if (lon == 0)
            [lon, lat] = gnome_sim(t, release);
        else
            [lon, lat] = gnome_sim(t, release, lon, lat);
        end
        
        % Define limits
        xmin = region.BoundingBox(1,1);
        xmax = region.BoundingBox(2,1);
        ymin = region.BoundingBox(1,2);
        ymax = region.BoundingBox(2,2);
        
        I1=find(lon<=xmax);
        lonI=lon(I1,:);
        latI=lat(I1,:);
        I2=find(lonI>=xmin);
        lonI=lonI(I2,:);
        latI=latI(I2,:);
        I3=find(latI>=ymin);
        lonI=lonI(I3,:);
        latI=latI(I3,:);
        I4=find(latI<=ymax);
        lonI=lonI(I4,:);
        latI=latI(I4,:);
        
        I = I1(I2(I3(I4)));
        
        [h, ~, ~] = histcounts2(latI,lonI,size(grid));
        
        % Prepare grid with histogram values and boundaries
        for i = 1:size(grid, 1)
            for j = 1:size(grid, 2)
                if (grid(i, j) > -1)
                    grid(i, j) = h(i, j);
                end
            end
        end
        
        t = t + t_step;
        %lon = lonI;
        %lat = latI;
        
    end
end

%%
t = tf;
tf = datetime(2020, 9, 20, 18, 0, 0);

[lon, lat] = gnome_sim(t,release);
% Define limits
xmin = region.BoundingBox(1,1);
xmax = region.BoundingBox(2,1);
ymin = region.BoundingBox(1,2);
ymax = region.BoundingBox(2,2);

I1=find(lon<=xmax);
lonI=lon(I1,:);
latI=lat(I1,:);
I2=find(lonI>=xmin);
lonI=lonI(I2,:);
latI=latI(I2,:);
I3=find(latI>=ymin);
lonI=lonI(I3,:);
latI=latI(I3,:);
I4=find(latI<=ymax);
lonI=lonI(I4,:);
latI=latI(I4,:);

I = I1(I2(I3(I4)));

[h, yEdges, xEdges, binY, binX] = histcounts2(latI,lonI,size(grid));

% Prepare grid with histogram values and boundaries
for i = 1:size(grid, 1)
    for j = 1:size(grid, 2)
        if (grid(i, j) > -1)
            grid(i, j) = h(i, j);
        end
    end
end



n_robots = 7;
heading = zeros(n_robots, 1);
robots = [22, 23; 23, 23; 24, 23;22, 24;23, 24;24, 24;22 25];
% weights = [omega_concentration omega_sensitivity omega_distance
% omega_neighbors]
c = ['r'; 'g';'y'; 'c'; 'm';'w'; 'k'];
weights =...
    [2.0 0.1 0.3 0.2 1;
    2.0 0.1 0.3 0.2 1;
    2.0 0.1 0.3 0.2 1;
    0.1 2.0 0.5 0.1 1;
    0.1 2.0 0.5 0.1 1;
    0.1 2.0 0.5 0.1 1;
    0.1 2.0 0.5 0.1 1];
weights_2 =...
    [1.0 0.0 0.3 0.2 0;
    1.0 0.0 0.3 0.2 0;
    1.0 0.0 0.3 0.2 0;
    1.0 0.0 0.5 0.1 0;
    1.0 0.0 0.5 0.1 0;
    1.0 0.0 0.5 0.1 0;
    1.0 0.0 0.5 0.1 0];
path_robots = zeros(n_robots, (tf - t)/minutes(1) + 1, 2);
for robot = 1:n_robots
    path_robots(robot, 1, 1) = robots(robot, 1);
    path_robots(robot, 1, 2) = robots(robot, 2);
end
cnt = 2;

release_cnt = 0;

[row, col] = find(~mask');

xls = mean([xEdges(1:end-1);xEdges(2:end)]);
yls = mean([yEdges(1:end-1);yEdges(2:end)]);
[xx yy] = meshgrid(xls,yls);

positions = [xx(:) yy(:)];
sum1 = 0;
sum2 = 0;
sum3 = 0;
for i =1:3

for a = 1:5
    for it = 1:3
        
        % Define limits
        xmin = region.BoundingBox(1,1);
        xmax = region.BoundingBox(2,1);
        ymin = region.BoundingBox(1,2);
        ymax = region.BoundingBox(2,2);
        
        % Filtering particles inside xmin, xmax, ymin, ymax
        I1=find(lon<=xmax);
        size(I1)
        lonI=lon(I1,:);
        size(lonI)
        latI=lat(I1,:);
        size(latI)
        I2=find(lonI>=xmin);
        size(I2)
        lonI=lonI(I2,:);
        size(lonI)
        latI=latI(I2,:);
        size(latI)
        I3=find(latI>=ymin);
        size(I3)
        lonI=lonI(I3,:);
        size(lonI)
        latI=latI(I3,:);
        size(latI);
        I4=find(latI<=ymax);
        lonI=lonI(I4,:);
        latI=latI(I4,:);
        
        I = I1(I2(I3(I4)));
        
        [h, ~, ~, binY, binX] = histcounts2(latI,lonI,size(grid));
        
        
        lonp=[];
        latp=[];
        for k=1:length(row)
            lonp = [lonp;lon(I(binX==row(k) & binY==col(k)))];
            latp = [latp;lat(I(binX==row(k) & binY==col(k)))];
        end
        data = [lonp, latp];
        
        %f = mvksdensity(data,positions,'Bandwidth',0.02);
        [f,~] = ksdensity(data,positions,'Bandwidth',0.02);
        f= reshape(f,size(grid));
        grid = 5/max(max(f))*~mask.*f.*(h>0)+grid_initial;
          % Plot em 3d usando meshgrid
        %X = positions(:,1);
        %Y = positions(:,2);
        %[xMesh, yMesh] = meshgrid(unique(X), unique(Y));
        %figure(1);
        %mesh(xMesh, yMesh, f);  % 'f' já está reshaped para o formato do grid
        %xlabel('X');
        %ylabel('Y');
        %zlabel('Density');
        %title('Densidade Kernel Estimada (ksdensity)');
        
        % Plot 2d Kdensity
        %figure(2);
        %plot(f);
        %title('Densidade Kernel Estimada (ksdensity)');
        switch i
            case 1
                [robots, heading] = random_walk(grid, robots, heading, mask);
                sum1 = dirty_accumulator(grid, sum1);
                
            case 2
                [robots, heading] = reactive_patrol(grid, robots, heading, mask, dist_grid, weights);
                sum2 = dirty_accumulator(grid, sum2);
                
            case 3
                [robots, heading] = reactive_patrol(grid, robots, heading, mask, dist_grid, weights);
                sum3 = dirty_accumulator(grid, sum3);

        end        % Consume particles
        for robot = 1:n_robots
            h(robots(robot, 2), robots(robot, 1)) = 0;
            grid(robots(robot, 2), robots(robot, 1)) = 0;
            % binX and binY address the indexes from histcounts2, and I has
            % the indexes on whole coastal range lat lon.
            lon(I(binX==robots(robot, 1) & binY==robots(robot, 2))) = NaN;
            lat(I(binX==robots(robot, 1) & binY==robots(robot, 2))) = NaN;
            
            % Saving path
            path_robots(robot, cnt, 1) = robots(robot, 1);
            path_robots(robot, cnt, 2) = robots(robot, 2);
        end
        
        % Removing NaN particles
        lon = lon(~isnan(lon));
        lat = lat(~isnan(lat));
        
        %t = t + seconds(40);
        %t = t + t_step;
        figure(2)
        
        pcolor(X, Y, grid);
        set(gca, 'YDir', 'normal');
        hold on
        mapshow(sl_alagoas,'FaceColor',[1 1 1],'HandleVisibility','off');
        title(string(t));ylabel('Latitude');xlabel('Longitude'); axis equal, axis([xmin xmax ymin ymax]);
        caxis([-1, 5])
        colormap jet
        colorbar
        for robot = 1:n_robots
            scatter(region.BoundingBox(1,1) + (robots(robot, 1)-0.5)/res_grid, ...
                region.BoundingBox(1,2) + (robots(robot, 2)-0.5)/res_grid, ...
                50, c(robot, :), 'filled');
        end
        drawnow
        tstr=t;
        tstr.Format='ddMMuuuu-HH-mm-ss';
        saveas(gcf,'pos'+string(tstr)+'.png')
        for robot = 1:n_robots
            pp=plot((path_robots(robot, 1:cnt, 1) - 0.5)/res_grid + region.BoundingBox(1,1), (path_robots(robot, 1:cnt, 2) - 0.5)/res_grid + region.BoundingBox(1,2), c(robot, :), 'LineWidth', 5);
            pp.Color(4) = 0.4;
            scatter(region.BoundingBox(1,1) + (robots(robot, 1)-0.5)/res_grid, ...
                region.BoundingBox(1,2) + (robots(robot, 2)-0.5)/res_grid, ...
                50, c(robot, :), 'filled');
        end
        
        hold off
        drawnow
        saveas(gcf,'traj'+string(tstr)+'.png')
        %pause
        
        cnt = cnt + 1;
    end
    %release = 0; 
    %release_cnt = release_cnt + 1;
    %if (release_cnt == 5)
        % Passed 10 minutes
      %  release = 1;
     %   release_cnt = 0;
    %else
        % Do not release new particles
     %   release = 0;
    %end
    %if (release_cnt >= 5)
        
     %   break;
    %end
    %disp(a);
    %     % Removing NaN particles
    %     lon = lon(~isnan(lon));
    %     lat = lat(~isnan(lat));
    %disp("----------------------------------------")
    [lon, lat] = gnome_sim(t,release, lon, lat);
    %disp("++++++++++++++++++++++++++++++++++++++++")
    size(lon)
    size(lat)
end
% Fecha todos os arquivos abertos para garantir que não estão em uso
fclose('all');

% Define os nomes dos arquivos de saída e os arquivos iniciais para cópia
output_name_txt = 'step.txt';
output_name_nc = 'step.nc';
file_initial_txt = 'step_initial.txt';
file_initial_nc = 'step_16_9.nc';
file_modified_txt = 'step.txt';
file_modified_nc = 'step.nc';

% Tenta deletar os arquivos antigos
deleteFileWithRetry(output_name_txt);
deleteFileWithRetry(output_name_nc);

% Aguarda um curto período para garantir que os arquivos foram apagados
pause(0.1);

% Copia os arquivos iniciais para resetar o ambiente
copyFileWithRetry(file_initial_txt, file_modified_txt);
copyFileWithRetry(file_initial_nc, file_modified_nc);

% Pausa final para garantir a cópia completa
pause(0.1);


robots = [1, 15; 2, 15; 3, 15;1, 16;2, 16;3, 16;1 17];
% weights = [omega_concentration omega_sensitivity omega_distance
% omega_neighbors]
path_robots = zeros(n_robots, (tf - t)/minutes(1) + 1, 2);
for robot = 1:n_robots
    path_robots(robot, 1, 1) = robots(robot, 1);
    path_robots(robot, 1, 2) = robots(robot, 2);
end
cnt = 2;

release_cnt = 0;

[row, col] = find(~mask');

xls = mean([xEdges(1:end-1);xEdges(2:end)]);
yls = mean([yEdges(1:end-1);yEdges(2:end)]);
[xx yy] = meshgrid(xls,yls);

positions = [xx(:) yy(:)];

t = datetime(2020,9 , 20, 12, 0, 0);
tf = datetime(2020, 9, 20, 18, 0, 0); 

end
%disp(sum1);
%disp(sum2);
%disp(sum3);
pcolor(X, Y, grid);
set(gca, 'YDir', 'normal');
hold on
mapshow(sl_alagoas,'FaceColor',[1 1 1],'HandleVisibility','off');
ylabel('Latitude');xlabel('Longitude'); axis equal, axis([xmin xmax ymin ymax]);
for robot = 1:n_robots
    scatter(region.BoundingBox(1,1) + (robots(robot, 1)-0.5)/res_grid, ...
        region.BoundingBox(1,2) + (robots(robot, 2)-0.5)/res_grid, ...
        50, c(robot, :), 'filled'); % Need that 0.5 because pcolor is based on vertices
    plot((path_robots(robot, :, 1) - 0.5)/res_grid + region.BoundingBox(1,1), (path_robots(robot, :, 2) - 0.5)/res_grid + region.BoundingBox(1,2), c(robot, :), 'LineWidth', 5);
end
hold off
caxis([-1, 5])
title('omega_0 = -0.02; omega_1 = 0.07');
colormap jet
colorbar