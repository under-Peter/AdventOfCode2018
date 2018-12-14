plevel((x,y), gsn) = mod(div(((x+10)*y + gsn)*(x+10),100),10) - 5
function grid(gsn)
    grid = zeros(Int,300,300)
    for I in CartesianIndices(grid)
        grid[I] = plevel(I.I, gsn)
    end
    return grid
end

function ap_power(gsn; ns = [3])
    accgrd = accumulate(+, accumulate(+, grid(gsn), dims=1), dims=2)
    pval((x,y),n) = accgrd[x+n,y+n] + accgrd[x,y] - accgrd[x,y+n] - accgrd[x+n,y]
    maxpars = (1, CartesianIndex(1,1), 1)
    for n in ns
        for I in CartesianIndices((1:300-n, 1:300-n))
            pv = pval(I.I,n)
            pv > first(maxpars) && (maxpars = (pv,I,n))
        end
    end
    return maxpars
end

day11_1() = ap_power(1788, ns=3)[2].I .+ 1
function day11_2()
    (pv, cinds, n) = ap_power(1788, ns=1:300)
    return ((cinds.I .+ 1)..., n)
end

day11_1()
day11_2()
