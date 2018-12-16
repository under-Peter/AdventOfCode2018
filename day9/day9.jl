mutable struct Circle
    arr::Matrix{Int}
    curr::Int
    Circle(n) = (a = zeros(Int,n+1,2);
                a[1,1] = a[1,2] = 1;
                new(a,1))
end

@inline counterclockwise!(c::Circle) = (c.curr = c.arr[c.curr,1]; c)
@inline clockwise!(c::Circle) = (c.curr = c.arr[c.curr,2]; c)
function myinsert!(c::Circle, n)
    p = c.arr[c.curr,1]
    c.arr[n,1], c.arr[p,2] = p, n
    c.arr[n,2], c.arr[c.curr,1] = c.curr, n
    c.curr = n
    return
end

function myremove!(c::Circle)
    p, n = c.arr[c.curr,1], c.arr[c.curr,2]
    c.arr[p,2], c.arr[n,1] = n, p
    c.curr = n
    return
end

function highscore(nplayers, nm)
    circ = Circle(nm)
    curr, player = 1, 1
    scores = zeros(Int64,nplayers)
    for i in 2:nm+1
        if iszero(mod(i-1,23))
            for i in 1:7
                counterclockwise!(circ)
            end
            scores[player] += i  + circ.curr - 2
            myremove!(circ)
        else
            clockwise!(circ)
            clockwise!(circ)
            myinsert!(circ,i)
        end
        player = ifelse(player == nplayers, 1, player+1)
    end
    return maximum(scores)
end

day9_1() = highscore(448, 71_628)
day9_2() = highscore(448, 71_628*100)
