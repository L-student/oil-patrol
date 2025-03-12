function procedure()

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
robots = [1, 15; 2, 15; 3, 15;1, 16;2, 16;3, 16;1 17];
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
end