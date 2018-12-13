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
    pval(x,y,n) = accgrd[x+n,y+n] + accgrd[x,y] - accgrd[x,y+n] - accgrd[x+n,y]
    maxpars = (1,1,1,1)
    for n in ns
        for y in 1:300-n, x in 1:300-n
            pv = pval(x,y,n)
            pv > first(maxpars) && (maxpars = (pv,x+1,y+1,n))
        end
    end
    return maxpars
end

using BenchmarkTools
@btime ap_power(1788,ns=1:300)
@time (ap_power(1788,ns=1:300), ap_power(1788,ns=3))
