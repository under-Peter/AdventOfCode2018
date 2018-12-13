data = readlines("exampleinput.txt")
data = readlines("input.txt")
parseline(line) = (line[6],line[37])
pdata = parseline.(data)


next(x) = join(_next(x))
function _next(pdata)
    pdata = copy(pdata)
    allto = getindex.(pdata,2)
    n = sort(filter(x -> !in(x,allto), first.(pdata)))[1]
    length(pdata) == 1 && return pdata[1]
    deleteat!(pdata,findall(x -> x[1] == n, pdata))
    return [n, _next(pdata)...]
end

#p1
@time next(pdata)
#p2
# data = readlines("exampleinput.txt")
data = readlines("input.txt")
parseline(line) = (line[6],line[37])
pdata = parseline.(data)
function getcandidates(pdata)
    allto = [x[2] for x in pdata]
    return unique(sort(filter(x -> !in(x,allto), first.(pdata))))
end

function getwork!(pdata, work, nelfs, t, dt)
    lnew = nelfs - length(work)
    lnew == 0 && return work
    cands = filter(x -> !in(x, first.(work)), getcandidates(pdata))
    cands == [] && return work
    for c in Iterators.take(cands,lnew)
        push!(work, (c, t + Int(dt + c - 'A'+1)))
    end
    work
end

function workwithelfs(pdata, nelfs, dt=0)
    pdata = copy(pdata)
    work, done = Tuple{Char,Int}[], Char[]
    t = 0
    while true
        getwork!(pdata, work, nelfs, t, dt)
        length(pdata) == 1 && length(work) == 1 && break
        t = minimum(w[2] for w in work)
        idone = findall(w -> w[2] == t, work)
        irm   = findall(x -> x in first.(work)[idone], first.(pdata))
        foreach(i -> push!(done, work[i][1]), idone)
        deleteat!(work, idone)
        deleteat!(pdata, irm)
    end
    t = work[1][2]
    t += Int(dt + pdata[1][2] - 'A'+1)
    append!(done, pdata[1])
    return (string(done...), t)
end

@time workwithelfs(pdata,5,60)
# @time workwithelfs(pdata,2,60)

next(pdata)


#1 adjacency matrxi (Moritz Schauer)

function myschedule(pdata)
    edgelist = [[dep[1][1] - 'A' + 1, dep[2][1] - 'A' + 1] for dep in pdata]
    A = zeros(Int, 26, 26)
    for e in edgelist
        A[e[2], e[1]] = 1
    end
    k = Int[]
    sched = Char[]
    for i in 1:26
        z = ones(Int, 26)
        z[k] .= 0
        a = findall(A*z .== 0)
        c = first(sort(setdiff(a, k)))
        k = push!(k, c)
        push!(sched, ('A':'Z')[c])
    end
    return join(sched)
end

@time myschedule(pdata)
@time next(pdata)

#modification
function myschedule(pdata)
    edgelist = [[dep[1][1] - 'A' + 1, dep[2][1] - 'A' + 1] for dep in pdata]
    A = zeros(Int, 26, 26)
    for e in edgelist
        A[e[2], e[1]] = 1
    end
    return A
    k = Int[]
    sched = Char[]
    for i in 1:26
        z = ones(Int, 26)
        z[k] .= 0
        a = findall(A*z .== 0)
        c = first(sort(setdiff(a, k)))
        k = push!(k, c)
        push!(sched, ('A':'Z')[c])
    end
    return join(sched)
end
