function myparse(f="input.txt")
    lines = readlines(f)
    v = Vector{NTuple{4,Int}}(undef, length(lines))
    rx = r"#\d+ @ (\d+),(\d+): (\d+)x(\d+)"
    for (i,line) in enumerate(lines)
        x, y, Δx, Δy = parse.(Int, match(rx, line).captures)
        v[i] = (x,y,Δx,Δy)
    end
    return v
end

function day3_1(f="input.txt")
    v = myparse(f)
    xmax = maximum(getindex.(v,1) .+ getindex.(v,3))
    ymax = maximum(getindex.(v,2) .+ getindex.(v,4))
    arr = zeros(Int, xmax, ymax)
    for (x,y,Δx,Δy) in v
        arr[x .+ (1:Δx),y .+ (1:Δy)] .+= 1
    end
    count(x -> x>1, arr)
end

#1 count overlapping patches
@time day3_1() == 124850

#2 find claim that does not overlap with any

function day3_2(f="input.txt")
    v = myparse(f)
    xmax = maximum(getindex.(v,1) .+ getindex.(v,3))
    ymax = maximum(getindex.(v,2) .+ getindex.(v,4))
    arr = zeros(Int, xmax, ymax)
    for (x,y,Δx,Δy) in v
        arr[x .+ (1:Δx),y .+ (1:Δy)] .+= 1
    end
    for (i, (x,y,Δx,Δy)) in enumerate(v)
        all(==(1), arr[x .+ (1:Δx),y .+ (1:Δy)]) && return i
    end
end

day3_2() == 1097
