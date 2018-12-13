data = parse.(Int,split(readline("example.txt")," "))
data = parse.(Int,split(readline("input.txt")," "))

function tree(data)
    metadata = Dict{String,Vector{Int}}()
    tree = subtree!(copy(data), "root", metadata)
    return (tree, metadata)
end

function subtree!(data, nodename, metadata)
    nch = popfirst!(data)
    nmd = popfirst!(data)
    if iszero(nch)
        metadata[nodename] = data[1:nmd]
        deleteat!(data,1:nmd)
        return Dict{String,Vector{String}}()
    end
    tree = Dict{String,Vector{String}}(nodename => [])
    for ch in 1:nch
        nn = string(gensym())
        push!(tree[nodename], nn)
        tree = merge(tree,subtree!(data, nn, metadata))
    end
    metadata[nodename] = data[1:nmd]
    deleteat!(data,1:nmd)
    return tree
end

function metadatasum(data)
    td, md = tree(data)
    return sum(sum(v) for v in values(md))
end

#p 1
metadatasum(data)

function nodevalue(node, tree, metadata)
    if haskey(tree, node)
        chs = tree[node]
        indxs = filter(i -> i <= length(chs), metadata[node])
        return sum([nodevalue(n,tree,metadata) for n in tree[node][indxs]])
    else
        return sum(metadata[node])
    end
end


function rootvalue(data)
    td, md = tree(data)
    nodevalue("root", td, md)
end

#p2
rootvalue(data)
