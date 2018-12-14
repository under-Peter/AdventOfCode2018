mutable struct Recipes{T}
    v::T
    l::Int
    Recipes(v) = new{typeof(v)}(v, length(v))
end

Base.eltype(p::Recipes) = eltype(p.v)
Base.getindex(rs::Recipes,i) = rs.v[i]
function Base.push!(rs::Recipes, n)
    resize!(rs, rs.l+1)
    rs.v[rs.l] = n
    return nothing
end
Base.length(rs::Recipes) = rs.l
Base.show(io::IO,rs::Recipes) = show(io, rs.v[1:rs.l])

function Base.resize!(rs::Recipes, l)
    l > length(rs.v) && Base.resize!(rs.v, l * 2)
    rs.l = l
end

function addrecipes!(rs, elfs, escore)
    nelfs = length(elfs)
    for i in 1:nelfs;
        escore[i] = rs[elfs[i]]
    end
    d, r = divrem(sum(escore),10)
    d != 0 && push!(rs,d)
    push!(rs, r)
    l = length(rs)
    @. elfs = mod1(elfs + escore + 1, l)
end

function day14_1(nr=9, init=[3,7], nelfs=2)
    elfs, escore = collect(1:nelfs), zeros(Int,nelfs)
    rs = Recipes(init)
    while length(rs) < nr + 10 + 1
        addrecipes!(rs, elfs, escore)
    end
    join(map(string,rs.v[(1:10) .+ nr]))
end

day14_1(9) == "5158916779"
day14_1(5) == "0124515891"
day14_1(18) == "9251071085"
day14_1(2018) == "5941429882"

@time day14_1(540561) == "1413131339"

function fastcompare(rs, dinput, inds)
    for (i,j) in enumerate(inds)
        dinput[i] == rs[j] || return false
    end
    return true
end

function day14_2(input, init=[3,7], nelfs=2)
    dinput = parse.(Int,collect(input))
    len = length(dinput)
    elfs, escore = collect(1:nelfs), zeros(Int,nelfs)
    rs = Recipes(init)
    while true
        addrecipes!(rs, elfs, escore)
        if length(rs) > len+1
            inds = (length(rs)-len+1):length(rs)
            fastcompare(rs, dinput, inds) && return (length(rs)-len)
            fastcompare(rs, dinput, inds .- 1) && return (length(rs)-len-1)
        end
    end
    error()
end

day14_2("51589") == 9
day14_2("01245") == 5
day14_2("92510") == 18
day14_2("59414") == 2018

@time day14_2("540561")
