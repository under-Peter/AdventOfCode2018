frequs =
#1 result of all frequencies

day1_1() = sum(parse.(Int,readlines("input.txt")))

@time day1_1() == 435

#2 first repeat
function findrep(v)
    c = 0
    s = Set{Int}(c)
    for n in Iterators.cycle(v)
        c += n
        (c in s) && return c
        push!(s,c)
    end
end
day1_2() = findrep(parse.(Int,readlines("input.txt")))
@time day1_2() == 245
