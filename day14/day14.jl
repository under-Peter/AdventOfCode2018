mutable struct Recipes{T,S}
    v::T
    l::Int
    function Recipes(v,l=length(v))
        lv = length(v)
        v = copy(v)
        resize!(v, l)
        return new{typeof(v), eltype(v)}(v, lv)
    end
end

Base.eltype(p::Recipes{T,S}) where {S,T} = S
Base.getindex(rs::Recipes,i) = rs.v[i]
function Base.push!(rs::Recipes, n)
    grow!(rs, rs.l+1)
    rs.v[rs.l] = n
    return nothing
end
Base.length(rs::Recipes) = rs.l
Base.show(io::IO,rs::Recipes) = show(io, rs.v[1:rs.l])

function grow!(rs::Recipes, l)
    l > length(rs.v) && Base.resize!(rs.v, l * 2)
    rs.l = l
end

function addrecipes!(rs, elfs)
    nelfs = length(elfs)
    e1, e2 = elfs[1], elfs[2]
    es1, es2 = rs[e1], rs[e2]
    d, r = divrem(es1 + es2, eltype(rs)(10))
    d != 0 && push!(rs,d)
    push!(rs, r)
    l = length(rs)
    elfs[1] = mod1(elfs[1] + es1 + 1,l)
    elfs[2] = mod1(elfs[2] + es2 + 1,l)
    return ifelse(iszero(d), 1, 2)
end

function day14_1(nr=9, init=Int8[3,7], nelfs=2)
    elfs = collect(1:nelfs)
    rs = Recipes(init, nr+10+1)
    while length(rs) < nr + 10 + 1
        addrecipes!(rs, elfs)
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

function day14_2(input, init=Int8[3,7], nelfs=2)
    dinput = parse.(Int8,collect(input))
    len = length(dinput)
    elfs = collect(1:nelfs)
    rs = Recipes(init)
    while true
        n = addrecipes!(rs, elfs)
        if length(rs) > len+1
            inds = (length(rs)-len+1):length(rs)
            fastcompare(rs, dinput, inds) && return (length(rs)-len)
            (n==2) && fastcompare(rs, dinput, inds .- 1) && return (length(rs)-len-1)
        end
    end
    error()
end

day14_2("51589") == 9
day14_2("01245") == 5
day14_2("92510") == 18
day14_2("59414") == 2018

day14_2("540561") == 20254833
