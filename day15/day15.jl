mutable struct Elf
    xy::CartesianIndex{2}
    hp::Int
    ap::Int
end

mutable struct Goblin
    xy::CartesianIndex{2}
    hp::Int
    ap::Int
end

const Unit = Union{Elf,Goblin}

mutable struct World
    chart::Matrix{Int8}
    units::Vector{Unit}
end

function parsefile(f="input.txt")
    dict = Dict{Char,Int}('#' => 1, '.' => 0, 'G' => 2, 'E' => 3)
    lines = readlines(f)
    height, width = length(lines), maximum(length.(lines))
    chart = Matrix{Int8}(undef,height, width)
    units = Unit[]
    for (y,line) in enumerate(lines), (x, c) in enumerate(line)
            chart[x,y] = dict[c]
            chart[x,y] == 2 && push!(units, Goblin(CartesianIndex(x,y), 200, 3))
            chart[x,y] == 3 && push!(units, Elf(CartesianIndex(x,y), 200, 3))
    end
    World(chart, units)
end

function printworld(w::World)
    l = size(w.chart,1)
    println("="^(l+3))
    printchart(w.chart)
    for u in w.units
        isalive(u) || continue
        println(u)
    end
    println("="^(l+3))
end

function printchart(chart)
    dict = Dict{Int,Char}(1 => '#', 0 => '.', 2 => 'G', 3 => 'E', -1 => '!', -2 => '~')
    h, w = size(chart)
    print("   ")
    foreach(x -> print(div(x,10)), 1:w)
    println()
    print("   ")
    foreach(x -> print(rem(x,10)), 1:w)
    println()
    println("-"^(w+2))
    for y in 1:h
        print(divrem(y,10)..., '|')
        for x in 1:w
            print(dict[chart[x,y]])
        end
        println()
    end
end

urange(xy) =  [xy + CartesianIndex(0,-1), xy + CartesianIndex(-1,0),
                xy + CartesianIndex(1,0), xy + CartesianIndex(0,1)]
urange(xy, chart) = filter(z -> chart[z] == 0 || chart[z] == -1, urange(xy))
enemiesof(u::T, w) where T = filter(x -> T != typeof(x) && isalive(x), w.units)

function adjacencypoints!(chart, enemies, unit)
    for e in enemies
        ur = urange(e.xy, chart)
        chart[ur] .= -1
        unit.xy in urange(e.xy) &&  (chart[unit.xy] = -1)
    end
    return chart
end

function identifytarget(u::Unit, w)
    chart = copy(w.chart)
    adjacencypoints!(chart, enemiesof(u, w), u)
    agents = Vector{CartesianIndex{2}}(undef, 32^2)
    nagents = Vector{CartesianIndex{2}}(undef, 32^2)
    sol = CartesianIndex{2}[]
    agents[1], la = u.xy, 1
    chart[u.xy] == -1 && return u.xy
    while isempty(sol) && la > 0
        i = 0
        for a in agents[1:la]
            chart[a] = -2
            for x in urange(a, chart)
                i = i+1
                chart[x] == -1 && push!(sol,x)
                chart[x] = -2
                nagents[i] = x
            end
        end
        la = i
        agents, nagents = nagents, agents
    end
    isempty(sol) && return nothing
    return sort(sol)[1]
end

function action!(u::Unit, w::World)
    p = identifytarget(u, w)
    p == nothing && return
    if p != u.xy
        s = nextloc(u,p, w)
        move!(u,s,w)
    end
    if p  == u.xy
        t = pickenemy(u, w)
        attack!(u,t)
        isalive(t) || (w.chart[t.xy] = 0)
    end
end

function nextloc(u::Unit, p::CartesianIndex, w)
    chart = copy(w.chart)
    paths = map(x -> [x], urange(u.xy, chart))
    npaths = Vector{CartesianIndex{2}}[]
    chart[last.(paths)] .= 1
    while !in(p, last.(paths))
        for path in paths
            for x in urange(last(path), chart)
                npath = push!(copy(path), x)
                chart[x] = 1
                push!(npaths, npath)
            end
        end
        length(unique(first.(npaths))) == 1 && return npaths[1][1]
        paths = npaths
    end
    paths = sort(filter(x -> last(x) == p ,paths), by=first)
    return paths[1][1]
end

function move!(u, p, w)
    w.chart[p], w.chart[u.xy] = w.chart[u.xy], w.chart[p]
    u.xy = p
end

isalive(u::Unit) = (u.hp > 0)

function pickenemy(u, w)
    es = filter(e -> in(e.xy, urange(u.xy)), enemiesof(u, w))
    sort!(es, by = x->x.xy)
    minhp = minimum(getproperty.(es,:hp))
    i = findfirst(e -> e.hp == minhp, es)
    es[i]
end

attack!(u, t) = (t.hp -= u.ap)

function counttroops(units)
    ng = count(isalive, filter(x -> x isa Goblin, units))
    ne = count(isalive, units) - ng
    return (ng, ne)
end

isover(w::World) = any(==(0), counttroops(w.units))
fight(w::World;kw...) = fight!(deepcopy(w); kw...)
function fight!(w::World; verbose = false)
    units = w.units
    sort!(units, by = x -> x.xy)
    t = 0
    verbose && println("Initially")
    verbose && printworld(w)
    while !isover(w)
        t += 1
        for u in units
            isalive(u) || continue
            action!(u, w)
        end
        sort!(units, by = x -> x.xy)
        verbose && println("After ",t, " round", ifelse(t==1,"","s"))
        verbose && printworld(w)
        verbose && println()
        verbose && sleep(0.1)
    end
    return (w, t-1)
end

function day15_1(f="input.txt"; verbose=false)
    w = parsefile(f)
    w, t = fight!(w, verbose=verbose)
    s = sum(ifelse(isalive(u), u.hp, 0) for u in w.units)
    @show t, s
    return s * t
end

day15_1("einput1.txt") == 47*590
day15_1("einput2.txt") == 37*982
day15_1("einput3.txt") == 46*859
day15_1("einput4.txt") == 35*793
day15_1("einput5.txt") == 54*536
day15_1("einput6.txt") == 20*937
day15_1("input.txt") == 243390

function day15_2(f="input.txt";verbose=false)
    w = parsefile(f)
    nelfs = count(x -> x isa Elf, w.units)
    elfwin(w) = count(x -> x isa Elf && isalive(x), w.units) == nelfs
    won, wpost, ap, t = false, w, 3, 0
    while  !won
        ap += 1
        for u in w.units
            u isa Elf && (u.ap = ap)
        end
        wpost, t = fight(w, verbose=verbose)
        won = elfwin(wpost)
    end
    s = sum(ifelse(isalive(u), u.hp, 0) for u in wpost.units)
    return s * t
end

day15_2("einput1.txt") == 29*172
day15_2("einput3.txt") == 33*948
day15_2("einput4.txt") == 37*94 #36 94
day15_2("einput5.txt") == 39*166 #38 166
day15_2("einput6.txt") == 30*38 #29 38
day15_2("input.txt") == 59886
