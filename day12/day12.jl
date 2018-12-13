indfrombin(t) = sum(t .* (1,2,4,8,16))+1

mutable struct PlantVec{T}
    v::T
    l::Int
    PlantVec(v) = new{typeof(v)}(v, length(v))
    PlantVec{T}() where T = new{T}(T(undef,8), 0)
end

Base.eltype(p::PlantVec) = eltype(p.v)

function Base.getindex(ps::PlantVec,i)
    (i < 1 || i > ps.l) && return zero(eltype(ps))
    @inbounds return ps.v[i]
end

Base.setindex!(ps::PlantVec,n,i) = (ps.v[i] = n; ps)
Base.length(ps::PlantVec) = ps.l

function Base.resize!(ps::PlantVec, l)
    l > length(ps.v) && Base.resize!(ps.v, l * 2)
    ps.l = l
end

function Base.fill!(ps::PlantVec, x)
    for i in 1:ps.l
        @inbounds ps.v[i] = x
    end
    return ps
end

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
    npf = ifelse(plants[1] == zero(eltype(plants)),
                ifelse(plants[2] == zero(eltype(plants)), 0, 1), 2)
    npl = ifelse(plants[lp] == zero(eltype(plants)),
                ifelse(plants[lp-1] == zero(eltype(plants)), 0, 1), 2)
    npl += ifelse(iseven(npl+npf+lp),0,1)
    i0 += npf
    resize!(nplants, lp + npf + npl)
    fill!(nplants, zero(eltype(plants)))
    @assert iseven(length(nplants))
    @simd for i in (1-npf):2:(lp+npl)
        p1, p2, p3 = (plants[i-2], plants[i-1], plants[i])
        p4, p5, p6 = (plants[i+1], plants[i+2], plants[i+3])
        t = (p1,p2,p3,p4,p5)
        nplants[i+npf] = rules[indfrombin(t)]
        t2 = (p2,p3,p4,p5,p6)
        nplants[i+npf+1] = rules[indfrombin(t2)]
    end
    return (nplants, rules, i0, plants)
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
    s = 0
    et = eltype(plants)
    for i in 1:plants.l
        s += ifelse(plants[i] == one(et), 1, 0)
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

@profiler ap_evolve(10000, T = BitVector)
@time ap_evolve(10000, T = BitVector)

using BenchmarkTools

for T in (Vector{Int}, Vector{Int32}, Vector{Int16}, Vector{Int8}, BitVector)
    print("T = ", T, "\t")
    t = @benchmark ap_evolve(20, T = $T)
    print(minimum(t), " memory: ", t.memory, " allocs: ", t.allocs , "\n")
end

for T in (Vector{Int}, Vector{Int32}, Vector{Int16}, Vector{Int8}, BitVector)
    print("T = ", T, "\t")
    t = @benchmark ap_evolve(200, T = $T)
    print(minimum(t), " memory: ", t.memory, " allocs: ", t.allocs , "\n")
end

for n in (20,200,2000)
    for T in (Vector{Int}, Vector{Int32}, Vector{Int16}, Vector{Int8}, BitVector)
        s1 = rpad("T = $T",20)
        s2 = rpad("periods = $n",16)
        print(s1,s2)
        t = @benchmark ap_evolve($n, T = $T)
        print(minimum(t), "\t memory: ", t.memory, "\t allocs: ", t.allocs , "\n")
    end
end

ts = [@belapsed ap_evolve($i) for i in 1:10:200]
