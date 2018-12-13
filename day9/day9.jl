refs = [8317 146373 2764 54718 37305]
datas = readlines("exampleinputs.txt")
data = readline("input.txt")
parseinput(line) = parse.(Int,match(r"(\d+) players; last marble is worth (\d+) points", line).captures)

mutable struct Circle
    v::Vector{Int}
    cm::Int
    N::Int
    Circle(v,c) = new(v, mod(c,length(v))+1, length(v))
end

function play!(c::Circle, marble)
    if iszero(mod(marble, 23))
        i = mod1(c.cm-7, c.N)
        score = c.v[i] + marble
        deleteat!(c.v, i)
        c.N, c.cm = c.N-1, i
        return score
    else
        i = mod1(c.cm+2, c.N)
        c.N += 1
        insert!(c.v, i, marble)
        c.cm = i
        return 0
    end
end

function highscore(nplayers, maxm)
    scores = zeros(Int, nplayers)
    c = Circle([0],1)
    for m in 1:maxm
        player = mod(m,nplayers)+1
        scores[player] += play!(c, m)
    end
    return maximum(scores)
end

highscore(10,1618)


mutable struct Circ
    arr::Matrix{Int}
    curr::Int
    Circ(n) = (a = zeros(Int,n+1,2);
                a[1,1] = a[1,2] = 1;
                new(a,1))
end

function printcirc(c::Circ)
    curr = c.curr
    list = [curr]
    c = clockwise(c)
    while c.curr != curr
        push!(list,c.curr)
        c = clockwise(c)
    end
    iz = findfirst(==(1), list)
    list = circshift(list, iz+1)
    print("Circle:")
    for ch in list
        if ch == c.curr
            print(">",ch-1,"<")
        else
            print(" ",ch-1," ")
        end
    end
    print("\n")
end

@inline counterclockwise!(c::Circ) = (c.curr = c.arr[c.curr,1]; c)
@inline clockwise!(c::Circ) = (c.curr = c.arr[c.curr,2]; c)
function myinsert!(c::Circ, n)
    p = c.arr[c.curr,1]
    c.arr[n,1], c.arr[p,2] = p, n
    c.arr[n,2], c.arr[c.curr,1] = c.curr, n
    c.curr = n
    return
end

function myremove!(c::Circ)
    p, n = c.arr[c.curr,1], c.arr[c.curr,2]
    c.arr[p,2], c.arr[n,1] = n, p
    c.curr = n
    return
end

function aphighscore(nplayers, nm, verbose::Bool=false)
    circ = Circ(nm)
    curr, player = 1, 1
    scores = zeros(Int64,nplayers)
    for i in 2:nm+1
        if iszero(mod(i-1,23))
            for i in 1:7
                counterclockwise!(circ)
            end
            scores[player] += i  + circ.curr - 2
            myremove!(circ)
        else
            clockwise!(circ)
            clockwise!(circ)
            myinsert!(circ,i)
        end
        # verbose && print("marble ",i-1, "curr ",curr-1, "\t")
        # verbose && printcirc(circ)
        player = ifelse(player == nplayers, 1, player+1)
    end
    return maximum(scores)
end

@time (aphighscore(np, fm), aphighscore(np, fm*100))
using BenchmarkTools
@btime (aphighscore(np, fm), aphighscore(np, fm*100))

refs = [8317 146373 2764 54718 37305]
datas = parseinput.(readlines("exampleinputs.txt"))
