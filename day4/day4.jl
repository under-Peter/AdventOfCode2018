using Dates

# a = readlines("exampleinput.txt")
a = readlines("input.txt")

function myparse(data)
    parseddata = Tuple{DateTime, Union{SubString,Int}}[]
    for line in data
        date = DateTime(parse.(Int,match(r"(\d+)-(\d+)-(\d+)\s(\d+):(\d+)", line).captures)...)
        id = match(r"#(\d+)", line)
        if id != nothing
            push!(parseddata,(date, parse(Int,id.captures[1])))
        else
            event = match(r"] (\D+)", line).captures[1]
            push!(parseddata,(date, event))
        end
    end
    return sort(parseddata, by=first)
end

pa = myparse(a)

function groupguards(pa)
    id, i, d = 0, 1, Dict{Int,Any}()
    while i < length(pa)
        (t, event) = pa[i]
        if event isa Int
            id, i = event, i+1
        else
            !haskey(d, id) && (d[id] = [])
            tdown, tup = first(pa[i]), first(pa[i+1])
            push!(d[id], (tdown, tup, convert(Minute,tup-tdown)))
            i += 2
        end
    end
    return d
end

guards = groupguards(pa);
v = [(sum(sleep[3] for sleep in sleeps), guard) for (guard,sleeps) in guards]

function sleepyhours(sleeps)
    hour = zeros(Int,60)
    for (sstart,send,stotal) in sleeps
        i1, i2 = minute.((sstart,send)) .+ 1
        hour[i1:i2] .+= 1
    end
    return hour
end

#1 guard who sleeps most - when is he most asleep?
id = sort(v,by=first)[end][2]
(argmax(sleepyhours(guards[id]))-1) * id == 98680

#2 of all guards, which guard is most frequencly asleep on the same minute?
function mostfrequentminute(guards)
    v = []
    for (guard, sleeps) in guards
        hour = sleepyhours(sleeps)
        push!(v, (guard, findmax(hour)...))
    end
    id, t = sort(v, by= x->x[2])[end][[1,3]]
    id, (t-1)
end

prod(mostfrequentminute(guards)) == 9763
