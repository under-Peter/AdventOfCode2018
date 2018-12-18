@enum AcreState begin
    openground
    trees
    lumberyard
end

function readmap(f="input.txt")
    lines = readlines(f)
    h, w = length(lines), maximum(length.(lines))
    land = Matrix{AcreState}(undef, h+2, w+2)
    land[1,:]   .= Ref(openground)
    land[h+2,:] .= Ref(openground)
    land[:,1]   .= Ref(openground)
    land[:,w+2] .= Ref(openground)
    for (y,line) in enumerate(lines)
        y += 1
        for (x,c) in enumerate(line)
            x += 1
            c == '.' && (land[x,y] = openground)
            c == '|' && (land[x,y] = trees)
            c == '#' && (land[x,y] = lumberyard)
        end
    end
    land
end

function countadj(land, I, what)
    c = 0
    for i in CartesianIndices((-1:1,-1:1))
        i == CartesianIndex(0,0) && continue
        c += (land[I + i] == what)
    end
    return c
end

function timestep(oland::Matrix, nland::Matrix)
    h, w = size(oland)
    for I in CartesianIndices((2:(h-1),2:(w-1)))
        state = oland[I]
        nland[I] = state
        if state == openground
            nt = countadj(oland, I, trees)
            nt >= 3 && (nland[I] = trees)
        elseif state == trees
            nl = countadj(oland, I, lumberyard)
            nl >= 3 && (nland[I] = lumberyard)
        elseif state == lumberyard
            nt = countadj(oland, I, trees)
            nl = countadj(oland, I, lumberyard)
            (nl >= 1 && nt >= 1) || (nland[I] = openground)
        end
    end
    return nland, oland
end

function printland(land::Matrix)
    h, w = size(land)
    for j in 1:h
        for i in 1:w
            s = land[i,j]
            s == openground && print('.')
            s == trees  && print('|')
            s == lumberyard && print('#')
        end
        println()
    end
    println("="^10)
end

function day18_1(f="input.txt", t=10; verbose=false)
    oland = readmap(f)
    nland = fill(openground, size(oland)...)
    verbose && println("initial state:")
    verbose && printland(oland)
    for i in 1:t
        nland, oland = timestep(oland, nland)
        nland, oland = oland, nland
        verbose && println("after ", i, " minute:")
        verbose && printland(oland)
        verbose && sleep(0.2)
    end
    cl = count(==(lumberyard), oland)
    cw = count(==(trees), oland)
    return cl * cw
end
