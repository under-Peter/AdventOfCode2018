struct Sample
    rpre::NTuple{4,Int}
    rpost::NTuple{4,Int}
    inst::NTuple{4,Int}
end

function regfun(f, inst, r, m)
    a, b, c = inst
    r1, r2, r3, r4 = r
    if m == :rr
        rc = f(r[a+1], r[b+1])
    elseif m == :ri
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
for (name, op, m) in [
        (:addr, +, :rr), (:addi, +, :ri),
        (:mulr, *, :rr), (:muli, *, :ri),
        (:banr, &, :rr), (:bani, &, :ri),
        (:borr, |, :rr), (:bori, |, :ri),
        (:gtir, toint∘>, :ir), (:gtri, toint∘>, :ri), (:gtrr, toint∘>, :rr),
        (:equir, toint∘==, :ir), (:equri, toint∘==, :ri), (:equrr, toint∘==, :rr),
        (:setr, (x,y) -> x, :rr), (:seti, (x,y) -> x, :ir)]
    @eval $name(inst,reg) = regfun($op, inst, reg, $(Meta.quot(m)))
end
const ops = (addr, addi, mulr, muli, banr, bani, borr, bori, setr, seti, gtir, gtri, gtrr, equir, equri, equrr )

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
        rpre, rpost = sample.rpre, sample.rpost
        i    = sample.inst[1] + 1
        inst = sample.inst[2:4]
        Base.Cartesian.@nexprs 16 j -> (rpost == ops[j](inst, rpre) && (itable[i,j] = true))
    end
    ivec, v = zeros(Int8,16), zeros(Int8,16)
    assigned = 0
    while assigned != 16
        sum!(v, itable)
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
        j = ivec[code[1]+1]
        inst = code[2:4]
        Base.Cartesian.@nexprs 16 i -> (j == i && (reg  = ops[i](inst, reg)))
    end
    return reg
end

day16_1(f::String="input.txt") = day16_1(getsamples(f))
function day16_1(samples::Vector{Sample})
    c = 0
    for sample in samples
        rpre, rpost = sample.rpre, sample.rpost
        inst = sample.inst[2:4]
        nm = 0
        Base.Cartesian.@nexprs 16 i -> nm += (rpost == ops[i](inst, rpre))
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
