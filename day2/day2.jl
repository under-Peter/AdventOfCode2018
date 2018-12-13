ids = readlines("input.txt")

function countchars(s)
    cdict = Dict{Char,Int}()
    charcount = zeros(Int,26)
    for c in s
        charcount[c-'a'+1] += 1
    end
    return charcount
end

#1 find number of ids with 2 equal and 3 equal characters and multiply
function day2_1()
    ids = readlines("input.txt")
    cchs = countchars.(ids)
    return count(in.(2, cchs)) * count(in.(3, cchs))
end

@time day2_1() == 5478

function day2_2()
    ids = readlines("input.txt")
    cchs = countchars.(ids)
    m1, m2 = ((s1,s2) for (s1,s2) in Iterators.product(ids,ids) if count(map(==,s1,s2)) == 25)
    return collect(m1[1])[map(==, m1[1], m1[2])] |> join
end

@time day2_2() == "qyzphxoiseldjrntfygvdmanu"
