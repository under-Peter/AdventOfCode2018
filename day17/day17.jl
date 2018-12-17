function getclay(f="input.txt")
    lines = readlines(f)
    clay = Vector{Tuple{Union{UnitRange,Int}, Union{UnitRange,Int}}}()
    xmin, xmax, ymin, ymax = typemax(Int), 0, typemax(Int), 0
    for line in lines
        isx = ifelse(line[1] == 'x', true, false)
        i1, i2, i3 = map(x -> parse(Int,x.captures[1]), eachmatch(r"(\d+)",line))
        if isx
            xmin, xmax = min(xmin, i1), max(xmax, i1)
            ymax, ymin = max(ymax, i2, i3), min(ymin, i2, i3)
            push!(clay, (i1, i2:i3))
        else
            xmin, xmax = min(xmin, i2, i3), max(xmax, i2, i3)
            ymax, ymin = max(ymax, i1), min(ymin, i1)
            push!(clay, (i2:i3, i1))
        end
    end
    xmax += 2
    xmin -= 4
    ymax += 1
    claymat = zeros(Int8,ymax, xmax-xmin)
    for (ix,iy) in clay
        claymat[iy, ix .- xmin] .= 1
    end
    return (claymat, (xmin, xmax), (ymin, ymax))
end

fillclay(c, ex, ey) = fillclay!(deepcopy(c), ex, ey)
function fillclay!(c, (xmin, xmax), (ymin, ymax))
    #empty => 0
    #clay  => 1
    #source => 2
    #standing water => 3
    ws  = Vector{NTuple{2,Int}}(undef, 10_000) #watersources
    nws = Vector{NTuple{2,Int}}(undef, 10_000)
    ws[1] = (1,500) .- (-ymin, xmin)
    c[ws[1]...] = 2
    lws, lnws = 1, 0
    stop = false
    while !stop
        stop = true
        for (y,x) in ws[1:lws]
            if y+1 >= ymax
                c[y,x] = 2
                stop = false
            elseif c[y+1,x] == 0 #flow down
                c[y+1,x] = 2
                nws[lnws+1] = (y,x)
                lnws += 1
                nws[lnws+1] = (y+1,x)
                lnws += 1
                stop = false
            else
                cond1 = c[y,x-1] == 0
                cond2 = c[y,x+1] == 0
                if (cond1 || cond2) && !isflowing(c,y+1,x)#flow sideways
                    if cond1
                        c[y,x-1] = 2
                        nws[lnws+1] = (y,x-1)
                        lnws += 1
                    end
                    if cond2
                        c[y,x+1] = 2
                        nws[lnws+1] = (y,x+1)
                        lnws += 1
                    end
                    c[y,x] = 3
                    stop = false
                elseif (c[y,x-1] in (1,2,3)) && (c[y,x+1] in (1,2,3))
                    c[y,x] = 3
                    stop = false
                else #keep watersource
                    nws[lnws+1] = (y,x)
                    lnws += 1
                end
            end
        end
        ws, nws = nws, ws
        lws, lnws = lnws, 0
    end
    return c
end

function fastf(pred, c, y, r)
    for i in r
        pred(c[y,i]) && return i
    end
    return nothing
end

function isflowing(c,y,x)
    val = c[y,x]
    val == 2 && return true
    (val == 1 || val == 0) && return false
    i = fastf(b -> b!=3, c, y, (x+1):size(c,2))
    c[y,i] == 2 && return true
    i = fastf(b -> b!=3, c, y, (x-1):-1:1)
    c[y,i] == 2 && return true
    return false
end

function removewater!(c, I)
    y,x = I.I
    i = fastf(b -> b!=3, c, y, (x+1):size(c,2))
    j = fastf(b -> b!=3, c, y, (x-1):-1:1)
    c[y,j+1:x-1] .= 0
    c[y,x+1:i-1] .= 0
    c[y,x] = 0
end

function day17_1(f="input.txt")
    clay = getclay(f)
    c = fillclay!(clay...)
    ymin = clay[3][1]
    return count(x -> x in (2,3),c)+1
end

function day17_2(f="input.txt")
    clay = getclay(f)
    c = fillclay!(clay...)
    i = findfirst(==(2), c)
    while i != nothing
        removewater!(c, i)
        i = findnext(==(2), c,i)
    end
    return count(==(3), c)
end
