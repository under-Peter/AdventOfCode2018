using Dates

function myparse(f="input.txt")
    data = readlines(f)
    parseddata = Tuple{DateTime, Union{SubString,Int}}[]
    df = DateFormat("y-m-d H:M")
    for line in data
        date = DateTime(line[2:17], df)
        id = match(r"#(\d+)", line)
        if id != nothing
            push!(parseddata,(date, parse(Int,id.captures[1])))
        else
            event = match(r"] (\D+)", line).captures[1]
            push!(parseddata,(date, event))
        end
    end
    return sort!(parseddata, by=first)
end

function groupguards(f="input.txt")
    pa = myparse(f)
    id, i = 0, 1
    d = Dict{Int,Vector{NTuple{3,Int}}}()
    while i < length(pa)
        (t, event) = pa[i]
        if event isa Int
            id, i = event, i+1
        else
            did = get!(d, id, [])
            tdown = minute(first(pa[i]))
            tup   = minute(first(pa[i+1]))
            push!(did, (tdown, tup, tup-tdown))
            i += 2
        end
    end
    return d
end

function sleepyhours(sleeps)
    hour = zeros(Int,60)
    for (sstart,send,stotal) in sleeps
        i1, i2 = (sstart,send) .+ 1
        hour[i1:i2] .+= 1
    end
    return hour
end

function day4_1(f="input.txt")
    guards = groupguards(f)
    maxsleep, maxid = 0, 0
    for (guard, sleep) in guards
        sleeptime = sum(getindex.(sleep,3))
        if sleeptime > maxsleep
            maxsleep = sleeptime
            maxid = guard
        end
    end
    return (argmax(sleepyhours(guards[maxid]))-1) * maxid
end

function day4_2(f="input.txt")
    guards = groupguards(f)
    v = [(guard, findmax(sleepyhours(sleeps))...) for (guard, sleeps) in guards]
    i = argmax(getindex.(v,2))
    id, t = v[i][[1,3]]
    return id * (t-1)
end
