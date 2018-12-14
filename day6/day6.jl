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
