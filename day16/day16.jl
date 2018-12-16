struct Sample
    rpre::NTuple{4,Int}
    rpost::NTuple{4,Int}
    inst::NTuple{4,Int}
end

function regfun(f, inst, r, ::Val{m}) where m
    a, b, c = inst
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
function getsamples(f="input.txt")
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

function opcodeids(samples)
    itable = falses(16,16)
    for sample in samples
        rpre = sample.rpre
        rpost = sample.rpost
        i = sample.inst[1] + 1
        inst = (sample.inst[2], sample.inst[3], sample.inst[4])
        rpost == addr(inst,  rpre) && (itable[i, 1] = true)
        rpost == addi(inst,  rpre) && (itable[i, 2] = true)
        rpost == mulr(inst,  rpre) && (itable[i, 3] = true)
        rpost == muli(inst,  rpre) && (itable[i, 4] = true)
        rpost == banr(inst,  rpre) && (itable[i, 5] = true)
        rpost == bani(inst,  rpre) && (itable[i, 6] = true)
        rpost == borr(inst,  rpre) && (itable[i, 7] = true)
        rpost == bori(inst,  rpre) && (itable[i, 8] = true)
        rpost == setr(inst,  rpre) && (itable[i, 9] = true)
        rpost == seti(inst,  rpre) && (itable[i,10] = true)
        rpost == gtir(inst,  rpre) && (itable[i,11] = true)
        rpost == gtri(inst,  rpre) && (itable[i,12] = true)
        rpost == gtrr(inst,  rpre) && (itable[i,13] = true)
        rpost == equir(inst, rpre) && (itable[i,14] = true)
        rpost == equri(inst, rpre) && (itable[i,15] = true)
        rpost == equrr(inst, rpre) && (itable[i,16] = true)
    end
    ivec = zeros(Int8,16)
    v = zeros(Int8,16)
    assigned = 0
    while assigned != 16
        for i in 1:16
            v[i] = 0
            for j in 1:16
                v[i] += itable[i,j]
            end
        end
        i = findfirst(==(1), v)
        j = findfirst(==(true), itable[i,:])
        ivec[i] = j
        itable[:, j] .= false
        itable[i,:]  .= true
        assigned += 1
    end
    return ivec
end

function getcode(f="input.txt")
    lines = readlines(f)[3107:end]
    code = Vector{NTuple{4,Int}}(undef, length(lines))
    for (i,line) in enumerate(lines)
        code[i] = tuple(parseline(line)...)
    end
    return code
end

function runcode(codes, ivec)
    reg = (1,0,0,0)
    for code in codes
        i = code[1]+1
        j = ivec[i]
        inst = (code[2], code[3], code[4])
        j ==  1 && (reg = addr(inst,  reg))
        j ==  2 && (reg = addi(inst,  reg))
        j ==  3 && (reg = mulr(inst,  reg))
        j ==  4 && (reg = muli(inst,  reg))
        j ==  5 && (reg = banr(inst,  reg))
        j ==  6 && (reg = bani(inst,  reg))
        j ==  7 && (reg = borr(inst,  reg))
        j ==  8 && (reg = bori(inst,  reg))
        j ==  9 && (reg = setr(inst,  reg))
        j == 10 && (reg = seti(inst,  reg))
        j == 11 && (reg = gtir(inst,  reg))
        j == 12 && (reg = gtri(inst,  reg))
        j == 13 && (reg = gtrr(inst,  reg))
        j == 14 && (reg = equir(inst, reg))
        j == 15 && (reg = equri(inst, reg))
        j == 16 && (reg = equrr(inst, reg))
    end
    return reg
end

function day16_1(f="input.txt")
    samples = getsamples(f)
    c = 0
    for sample in samples
        rpre = sample.rpre
        rpost = sample.rpost
        inst = (sample.inst[2], sample.inst[3], sample.inst[4])
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


function day16_2(f="input.txt")
    samples = getsamples(f)
    code = getcode(f)
    ivec = opcodeids(samples)
    reg = runcode(code, ivec)
    return reg[1]
end
