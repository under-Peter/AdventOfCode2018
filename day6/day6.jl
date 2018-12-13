data = readlines("exampleinput.txt")
data = readlines("input.txt")

parseline(line) = parse.(Int,match(r"(\d+), (\d+)", line).captures)
idata = parseline.(data)

dmanhattan((x1,y1),(x2,y2)) = abs(x1-x2) + abs(y1-y2)
function areas(data, l=100)
    field = zeros(Int,l,l)
    distances = zeros(Int, length(data))
    for (x,y) in Iterators.product(1:l,1:l)
        map!(xy -> dmanhattan((x,y),xy), distances, data)
        inds = findall(==(minimum(distances)),distances)
        field[x,y] = ifelse(length(inds) > 1, 0, inds[1])
    end
    infiniteareas = union(field[1,:], field[l,:], field[:,1], field[:,l])
    maximum(count(==(i), field) for i in 1:length(data) if !(i in infiniteareas))
end

#1 size of largest area closest to one point
@time areas(idata,1_000)

#2
data = readlines("input.txt")

parseline(line) = parse.(Int,match(r"(\d+), (\d+)", line).captures)
idata = parseline.(data)

dmanhattan((x1,y1),(x2,y2)) = abs(x1-x2) + abs(y1-y2)
function areassum(data, l=1000)
    field = zeros(Int,l,l)
    for (x,y) in Iterators.product(1:l,1:l)
        distances = [dmanhattan((x,y), xy) for xy in data]
        field[x,y] = sum(distances)
    end
    count(x -> x < 10_000, field)
end

areassum(idata,1000)
count(x -> x < 10_000,  areassum(idata,2_000))
count(x -> x < 10_000,  areassum(idata,2_000))
count(x -> x < 10_000,  areassum(idata,1_000))


#= Flood  by Kristoffer Carlsson=#

struct Point
    id::Int
    x::Int
    y::Int
end

function run_6(data)
    points = Point[]
    min_x, min_y, max_x, max_y = typemax(Int), typemax(Int), 0, 0
    for (i, l) in enumerate(data)
        s = split(l, ", ")
        x, y = parse.(Int, (s[1], s[2]))
        min_x, max_x, min_y, max_y = min(min_x, x), max(max_x, x), min(min_y, y),  max(max_y, y)
        push!(points, Point(i, x, y))
    end
    n_points = length(points)

    # The area contains (time, id)
    area = fill((0,0), max_y-min_y+1, max_x-min_x+1)

    # Shift coords to our origin (we are only interested in areas anyway)
    for i in eachindex(points)
        point = points[i]
        shifted_point = Point(point.id, point.x - min_x + 1, point.y - min_y + 1)
        points[i] = shifted_point
        area[shifted_point.y, shifted_point.x] = (0, shifted_point.id)
    end

    t = 0
    new_points = Point[]
    while t == 0 || !isempty(points)
        resize!(new_points, 0)
        t += 1
        for point in points
            for (dx, dy) in ((-1, 0), (1, 0), (0, -1), (0, 1))
               flood_fill!(area, new_points, point.x + dx, point.y + dy, point.id, t)
            end
        end
        new_points, points = points, new_points
    end

    area_ids = [v[2] for v in area]
    # Each id on the edge will be infinite, discared them
    infinites = unique(vcat(area_ids[:, 1], area_ids[1, :], area_ids[end, :], area_ids[:, end]))
    replace!(x -> x in infinites ? -1 : x, area_ids)

    # Count the areas in each
    count = Dict{Int, Int}()
    foreach(i -> count[i] = 0, -1:n_points)
    for i in area_ids
        count[i] += 1
    end
    delete!(count, -1)
    return findmax(count)[1]
end

function flood_fill!(area, new_coords, x, y, id, t)
    0 < x <= size(area, 2) || return
    0 < y <= size(area, 1) || return
    t0, v = area[y, x]
    if v == 0
        area[y, x] = (t, id)
        push!(new_coords, Point(id, x, y))
    elseif v != id && t0 == t
        # Use -1 as a sentinel for equal distance
        push!(new_coords, Point(-1, x, y))
        area[y, x] = (t, -1)
    end
    return
end

using BenchmarkTools

@btime run_6($data) #11.4ms (153134 allocs: 4.90 MiB)
