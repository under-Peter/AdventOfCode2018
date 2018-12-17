struct Streets
    str::Matrix{Char}
    occ::Matrix{Bool}
    function Streets(str)
        inds = findall(x -> x in ('^','<','v','>'), str)
        occ = zeros(Bool, size(str))
        occ[inds] .= true
        str = replace(str, '^' => '|', 'v' => '|', '<' => '-', '>' => '-')
        return new(str, occ)
    end
end

mutable struct Car
    xy::CartesianIndex{2}
    dir::Int # 1,2,3,4 = {up, left, down, right}
    m::Int #0-2 to decide how to turn
    function Car(xy, c)
        dir = 0
        c == '^' && (dir = 1)
        c == '>' && (dir = 2)
        c == 'v' && (dir = 3)
        c == '<' && (dir = 4)
        return new(xy, dir, 0)
    end
end

initcars(nw) = [Car(I, nw[I]) for I in findall(x -> x in ('v','^','<','>'),nw)]
removecar!(nw, I) = (nw.occ[I] = false; nw)
crash(nw, I) = nw.occ[I]

function parsefile(f = "input.txt")
    lines = readlines(f)
    lx, ly = maximum(length.(lines)), length(lines)
    nw = Matrix{Char}(undef,ly,lx)
    for i in eachindex(nw)
        nw[i] = ' '
    end
    for (x,line) in enumerate(lines)
        for (y,c) in enumerate(line)
            nw[x,y] = c
        end
    end
    return Streets(nw), initcars(nw)
end

function advancecar!(nw, car)
    Δxy = (CartesianIndex(-1,0), CartesianIndex(0,1), CartesianIndex(1,0),CartesianIndex(0,-1))
    removecar!(nw, car.xy)
    car.xy += Δxy[car.dir]
    crash(nw, car.xy) &&  return car.xy
    addcar!(car, nw)
    return nothing
end

function addcar!(car, nw)
    I = car.xy
    nw.occ[I] = true
    f = nw.str[I]
    dir = car.dir
    if f == '\\'
        dir == 1 && (car.dir = 4)
        dir == 4 && (car.dir = 1)
        dir == 2 && (car.dir = 3)
        dir == 3 && (car.dir = 2)
    elseif f ==  '/'
        dir == 1 && (car.dir = 2)
        dir == 2 && (car.dir = 1)
        dir == 3 && (car.dir = 4)
        dir == 4 && (car.dir = 3)
    elseif f == '+'
        m = car.m -1
        car.dir = mod1(car.dir + m,4)
        car.m   = mod(car.m + 1, 3)
    end
end

function advancetick1!(nw, cars)
    crashsite::Union{Nothing,CartesianIndex{2}} = nothing
    for i in 1:length(cars)
        crashsite  = advancecar!(nw, cars[i])
        crashsite != nothing && return crashsite
    end
    sort!(cars, by = c -> c.xy)
    return crashsite
end

function day13_1(f="input.txt")
    nw, cars = parsefile(f)
    crashsite::Union{Nothing, CartesianIndex{2}} = nothing
    while crashsite == nothing
        crashsite = advancetick1!(nw,cars)
    end
    return reverse(crashsite.I) .-1
end

function advancetick2!(nw, cars)
    crashsite::Union{Nothing,CartesianIndex{2}} = nothing
    skipinds = Int[]
    for i in 1:length(cars)
        i in skipinds && continue
        crashsite = advancecar!(nw, cars[i])
        if crashsite != nothing
            removecar!(nw, crashsite)
            inds = findall(==(crashsite), getproperty.(cars,:xy))
            append!(skipinds, inds)
        end
    end
    !isempty(skipinds) && deleteat!(cars, sort(skipinds))
    sort!(cars, by = c -> c.xy.I)
    return nothing
end

function day13_2(f="input.txt")
    nw, cars = parsefile(f)
    crashsite::Union{Nothing, CartesianIndex{2}} = nothing
    nws = [copy(nw.occ)]
    while length(cars) > 1
        advancetick2!(nw,cars)
        push!(nws, copy(nw.occ))
    end
    return (reverse(cars[1].xy.I) .- 1, nws)
end

# nws = day13_2()[2];
# nwsa = accumulate(+,nws)
# using Plots
# heatmap(nwsa[end],leg = nothing, axis = nothing)
# an = @gif for i in 1:1000
#     heatmap(nwsa[i],leg = nothing, axis = nothing)
# end
