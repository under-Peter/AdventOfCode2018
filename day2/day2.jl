function countchars(s)
    cdict = Dict{Char,Int}()
    charcount = zeros(Int,26)
    for c in s
        charcount[c-'a'+1] += 1
    end
    return charcount
end

function day2_1(f="input.txt")
    ids = readlines(f)
    cchs = countchars.(ids)
    return count(in.(2, cchs)) * count(in.(3, cchs))
end

function day2_2(f="input.txt")
    ids = readlines(f)
    cchs = countchars.(ids)
    m1, m2 = ((s1,s2) for (s1,s2) in Iterators.product(ids,ids) if count(map(==,s1,s2)) == 25)
    return collect(m1[1])[map(==, m1[1], m1[2])] |> join
end
