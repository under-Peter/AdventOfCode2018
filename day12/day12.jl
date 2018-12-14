mutable struct PlantVec{T}
    v::T
    l::Int
    PlantVec(v) = new{typeof(v)}(v, length(v))
    PlantVec{T}() where T = new{T}(T(undef,8), 0)
end

Base.eltype(p::PlantVec) = eltype(p.v)
Base.setindex!(ps::PlantVec,n,i) = setindex!(ps.v,n,i)
Base.length(ps::PlantVec) = ps.l

function Base.getindex(ps::PlantVec,i)
    i < 1 && return zero(eltype(ps))
    i > ps.l && return zero(eltype(ps))
    @inbounds return ps.v[i]
end

function grow!(ps::PlantVec, l)
    l > length(ps.v) && resize!(ps.v, l * 2)
    ps.l = l
end

function Base.fill!(ps::PlantVec, x)
    @inbounds for i in 1:ps.l
        ps.v[i] = x
    end
    return ps
end

indfrombin(t) = sum(t .* (1,2,4,8,16))+1

function parsefile(T=Vector{Int})
    tobool(x) = ifelse(x=='#', true, false)
    file = readlines("input.txt")
    plants = map(tobool,collect(match(r"[#.]+",file[1]).match))
    rules = zeros(Int8,2^5)
    fill!(rules, false)
    for line in file[3:end]
        arr = map(tobool,collect(line[1:5]))
        rules[indfrombin(arr)] = tobool(line[10])
    end
    return (PlantVec(convert(T,plants)), rules)
end

function timestep(plants::PlantVec{T}, rules, i0 = 1, nplants = PlantVec{T}()) where T
    lp = length(plants)
    z = zero(eltype(plants))
    npf = ifelse(plants[1] == z,  ifelse(plants[2]    == z, 0, 1), 2)
    npl = ifelse(plants[lp] == z, ifelse(plants[lp-1] == z, 0, 1), 2)
    grow!(nplants, lp + npf + npl)
    fill!(nplants, z)
    @simd for i in (1-npf):(lp+npl)
        t = (plants[i-2], plants[i-1], plants[i], plants[i+1], plants[i+2])
        nplants[i+npf] = rules[indfrombin(t)]
    end
    return (nplants, rules, i0 + npf, plants)
end


function evolve(plants, rules, ngens; verbose::Bool=false)
    res = (plants, rules, 1, PlantVec{Vector{eltype(plants)}}())
    verbose && println("Generation: ", 0)
    verbose && printplants(res[1], res[3])
    for i in 1:ngens
        res = timestep(res...)
        verbose && println("Generation: ", i)
        verbose && printplants(res[1], res[3])
    end
    return (res[1], res[3])
end

function addpots(plants, i0)
    s, et = 0, eltype(plants)
    for i in 1:plants.l
        s += ifelse(plants[i] == one(et), (i-i0), 0)
    end
    return s
end

function printplants(plants, i0)
    print("Plants:")
    print(" "^max(25-i0,0))
    for (i,j) in enumerate(collect(plants.v[1:plants.l]))
        print(ifelse(i == i0,
            ifelse(j == one(eltype(plants)), "P", "X"),
            ifelse(j == one(eltype(plants)), "#", ".")))
    end
    println()
end

function ap_evolve(ngens=20; v = false, T = Vector{Int})
    pf = parsefile(T)
    p, i0  = evolve(pf...,ngens, verbose=v)
    return addpots(p, i0)
end

day12_1() = ap_evolve(20)
function day12_2()
    p200 = ap_evolve(200)
    p300 = ap_evolve(300)
    return (p300-p200) * (500_000_000-2) + p200
end

@time day12_1() == 3798
@time day12_2() == 3900000002212
