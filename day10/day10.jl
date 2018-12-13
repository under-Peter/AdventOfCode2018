using Plots
data = readlines("exampleinput.txt")
data = readlines("input.txt")
parseline(line) = parse.(Int,match(r"position=<\s*(\-?\d+),\s*(\-?\d+)>\s*velocity=<\s*(\-?\d+),\s*(\-?\d+)>", line).captures)
v = permutedims(hcat(parseline.(data)...))

function canvassize(v::Matrix{Int})
    xmin, xmax = extrema(v[1,:])
    ymin, ymax = extrema(v[2,:])
    return (xmax - xmin) * (ymax - ymin)
end

function advance!(v::Matrix{Int},t::Int=1)
    @. v[:,1] += t * v[:,3]
    @. v[:,2] += t * v[:,4]
    return v
end
advance(v, t) = advance!(copy(v), t)
draw(w::Matrix{Int}) = scatter(w[:,1], -w[:,2],
    leg=nothing,
    axis=nothing,
    xlims = (140,220),
    ylims = (-150, -110))

i = argmin([canvassize(advance(v,t)) for t in 1:100_000])
an = @gif for k in -10:10
    draw(advance(v,i+k))
end
gif(an,fps=2)
draw(advance(v,i+9)) #"JL PZF JRH"
i+9

advance(v,i+9) |> canvassize
