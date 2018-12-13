using DelimitedFiles

datas = readdlm("input.txt")
lines = [datas[i,:] for i in 1:size(datas,1)]

function myparse(datas)
    dict = Dict()
    for line in datas
        x,y = [parse(Int,s) for s in split(line[3][1:end-1],',')]
        Δx, Δy = [parse(Int,s) for s in split(line[4],'x')]
        dict[line[1]] = (x,y,Δx,Δy)
    end
    return dict
end

function countpatches(lines)
    dict = myparse(lines)
    arr = zeros(Int, 1_000, 1_000)
    for (x,y,Δx,Δy) in values(dict)
        x += 1
        y += 1
        Δx -= 1
        Δy -= 1
        arr[x:x+Δx, y:y+Δy] .+= 1
    end
    count(x -> x>1, arr)
end

#1 count overlapping patches
countpatches(lines)
# = 124850

#2 find claim that does not overlap with any

function findnonoverlap(lines)
    dict = myparse(lines)
    arr = zeros(Int, 1_000, 1_000)
    for (x,y,Δx,Δy) in values(dict)
        x, y = x+1, y+1
        Δx, Δy = Δx-1, Δy-1
        arr[x:x+Δx, y:y+Δy] .+= 1
    end
    ks = Set()
    for (k, (x,y,Δx,Δy)) in dict
        x, y = x+1, y+1
        Δx, Δy = Δx-1, Δy-1
        if all(arr[x:x+Δx, y:y+Δy] .== 1)
            push!(ks,k)
        end
    end
    return length(ks) == 1 ? first(ks) : error()
end

findnonoverlap(lines) == 1097
# = "#1097"
