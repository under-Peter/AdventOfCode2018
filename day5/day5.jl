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

function day5_1(f="input.txt")
    st = readline(f)
    length(polymer(st))
end

#1 length of polymer
@time day5_1()

#2 length of polymer removing
rmchars(st, char) = filter(x -> lowercase(x) != char, st)

function day5_2(f="input.txt")
    st = collect(readline(f))
    minimum((length(polymer!(rmchars(st,ch)))) for ch in 'a':'z')
end

@time day5_2()
