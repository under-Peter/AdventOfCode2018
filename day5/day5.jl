st = readline("exampleinput.txt")
st = readline("input.txt")



function polymer!(data)
    i = 1
    while i != length(data)
        if abs(Int(data[i])-Int(data[i+1])) == 32
            deleteat!(data,i:i+1)
            i = max(i - 1, 1)
        else
            i = i + 1
        end
    end
    return data
end
polymer(x) = polymer!(copy(collect(x)))


f(p, c) = ifelse(abs(p[end] - c) == 32, p[1:end-1], p*c)
g(p, c) = ifelse(abs(p[end] - c) == 32, p[1:end-1], push!(p,c))
polymer2(st) = reduce(f, st, init = " ")[2:end]
polymer3(st) = reduce(g, collect(st), init = [' '])[2:end]

#1 length of polymer
@time length(polymer(st))
@time length(polymer2(st))
@time length(polymer3(st))


#2 length of polymer removing
function rmchars(st, char)
    char = lowercase(char)
    st = filter(x -> lowercase(x) != char, st)
end

function shortest(st)
    minimum((length(polymer!(rmchars(st,ch)))) for ch in 'a':'z')
end

@btime shortest(st)
