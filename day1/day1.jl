day1_1(f="input.txt") = sum(parse.(Int,readlines(f)))

function findrep(v)
    c = 0
    s = Set{Int}(c)
    for n in Iterators.cycle(v)
        c += n
        (c in s) && return c
        push!(s,c)
    end
end
day1_2(f="input.txt") = findrep(parse.(Int,readlines(f)))
