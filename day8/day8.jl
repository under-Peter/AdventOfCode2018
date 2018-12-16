function mdsum(tree, i=1, s=0)
    nch, nmd = tree[i], tree[i+1]
    i += 2
    for ch in 1:nch
        i, s = mdsum(tree, i, s)
    end
    for j in i .+ (0:nmd-1)
        s += tree[j]
    end
    i+nmd, s
end

function nodevalue(tree, l=1)
    nch, nmd = tree[l], tree[l+1]
    l += 2
    nvals = zeros(Int, nch)
    for i in 1:nch
        l, nvals[i] = nodevalue(tree, l)
    end
    v = 0
    if nch == 0
        for i in (0:nmd-1) .+ l
            v += tree[i]
        end
    else
        for i in (0:nmd-1) .+ l
            1 ≤ tree[i] ≤ nch && (v += nvals[tree[i]])
        end
    end
    l+nmd , v
end


function day8_1(f="input.txt")
    data = parse.(Int, split(readline(f)," "))
    return mdsum(data)[2]
end

function day8_2(f="input.txt")
    data = parse.(Int, split(readline(f)," "))
    return nodevalue(data)[2]
end
