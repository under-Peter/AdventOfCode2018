parseline(line) = parse.(Int,match(r"(\d+), (\d+)", line).captures)
dmanhattan((x1,y1),(x2,y2)) = abs(x1-x2) + abs(y1-y2)

function areas(data, l=1000)
    field = zeros(Int8,l,l)
    distances = zeros(Int, length(data))
    for (x,y) in Iterators.product(1:l,1:l)
        map!(xy -> dmanhattan((x,y),xy), distances, data)
        m = minimum(distances)
        i = findfirst(==(m), distances)
        j = findnext(==(m), distances, i+1)
        field[x,y] = ifelse(j == nothing, i, 0)
    end
    infiniteareas = union(field[1,:], field[l,:], field[:,1], field[:,l])
    maximum(count(==(i), field) for i in 1:length(data) if !(i in infiniteareas))
end

function areassum(data, l=1000)
    c = 0
    for (x,y) in Iterators.product(1:l,1:l)
        field = 0
        for xy in data
            field += dmanhattan((x,y), xy)
        end
        field < 10_000 && (c += 1)
    end
    return c
end

day6_1(f="input.txt") = areas(parseline.(readlines(f)), 1_000)
day6_2(f="input.txt") = areassum(parseline.(readlines(f)),1_000)
