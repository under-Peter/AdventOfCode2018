struct Sample
    rpre::NTuple{4,Int}
    rpost::NTuple{4,Int}
    inst::NTuple{4,Int}
end

function regfun(f, inst, r, ::Val{m}) where m
    i, a, b, c = inst
    r1, r2, r3, r4 = r[1], r[2], r[3], r[4]
    if m == :r
        rc = f(r[a+1], r[b+1])
    elseif m == :i
        rc = f(r[a+1], b)
    elseif m == :ir
        rc = f(a, r[b+1])
    end
    c == 0 && return (rc, r2, r3, r4)
    c == 1 && return (r1, rc, r3, r4)
    c == 2 && return (r1, r2, rc, r4)
    c == 3 && return (r1, r2, r3, rc)
end

toint(x::Bool) = ifelse(x, 1, 0)
addr(inst, reg)  = regfun(+, inst, reg, Val(:r))
addi(inst, reg)  = regfun(+, inst, reg, Val(:i))
mulr(inst, reg)  = regfun(*, inst, reg, Val(:r))
muli(inst, reg)  = regfun(*, inst, reg, Val(:i))
banr(inst, reg)  = regfun(&, inst, reg, Val(:r))
bani(inst, reg)  = regfun(&, inst, reg, Val(:i))
borr(inst, reg)  = regfun(|, inst, reg, Val(:r))
bori(inst, reg)  = regfun(|, inst, reg, Val(:i))
gtir(inst, reg)  = regfun(toint∘>, inst, reg, Val(:ir))
gtri(inst, reg)  = regfun(toint∘>, inst, reg, Val(:i))
gtrr(inst, reg)  = regfun(toint∘>, inst, reg, Val(:r))
equir(inst, reg) = regfun(toint∘==, inst, reg, Val(:ir))
equri(inst, reg) = regfun(toint∘==, inst, reg, Val(:i))
equrr(inst, reg) = regfun(toint∘==, inst, reg, Val(:r))
setr(inst, reg)  = regfun((x,y) -> x, inst, reg, Val(:r))
seti(inst, reg)  = regfun((x,y) -> x, inst, reg, Val(:ir))

parseline(line) = map(x -> parse(Int, x.match), eachmatch(r"\d+", line))
function parsefile(f="input.txt")
    samples = Vector{Sample}(undef, 776)
    lines = readlines(f)[1:3103]
    for (j,i) in enumerate(1:4:length(lines))
        rpre  = tuple(parseline(lines[i])...)
        inst  = tuple(parseline(lines[i+1])...)
        rpost = tuple(parseline(lines[i+2])...)
        samples[j] = Sample(rpre, rpost, inst)
    end
    return samples
end

function day16_1(f="input.txt")
    samples = parsefile(f)
    c = 0
    for sample in samples
        rpre = sample.rpre
        rpost = sample.rpost
        inst = sample.inst
        nm = 0
        rpost == addr(inst,  rpre) && (nm += 1)
        rpost == addi(inst,  rpre) && (nm += 1)
        rpost == mulr(inst,  rpre) && (nm += 1)
        rpost == muli(inst,  rpre) && (nm += 1)
        rpost == banr(inst,  rpre) && (nm += 1)
        rpost == bani(inst,  rpre) && (nm += 1)
        rpost == borr(inst,  rpre) && (nm += 1)
        rpost == bori(inst,  rpre) && (nm += 1)
        rpost == setr(inst,  rpre) && (nm += 1)
        rpost == seti(inst,  rpre) && (nm += 1)
        rpost == gtir(inst,  rpre) && (nm += 1)
        rpost == gtri(inst,  rpre) && (nm += 1)
        rpost == gtrr(inst,  rpre) && (nm += 1)
        rpost == equir(inst, rpre) && (nm += 1)
        rpost == equri(inst, rpre) && (nm += 1)
        rpost == equrr(inst, rpre) && (nm += 1)
        nm >= 3 && (c += 1)
    end
    return c
end

@time day16_1() == 588
