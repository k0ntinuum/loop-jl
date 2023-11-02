using Random
using Printf
#alph = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
#alph = "O|@"


function randomkey(n) Random.randperm(n) end

function inverse(f)
    g = Int64[]
    for i in eachindex(f) push!(g,findfirst(isequal(i),f)) end
    g
end

function composition(f,g)
    h = Int64[]
    for i in eachindex(f) push!(h,f[g[i]]) end
    h
end


function spin(q,r)
    f = copy(q)
    for i in 1:r 
    	for j in 1:n
            g = circshift(f,f[j]) 
            f = composition(g,f)
    	end 
    end
    f
end


function str(v)
	join(map(i -> alph[i:i], v))
end

function encode(p,q)
    f = copy(q)
    c = Int64[]
    for i in eachindex(p)
        push!(c,f[p[i]])
        g = circshift(f,p[i])
        f = composition(g,f)
    end
    c
end


function demoencode(p,q,F)
    f = copy(q)
    c = Int64[]
    for i in eachindex(p)
        push!(c,f[p[i]])
        g = circshift(f,p[i])
        f = composition(g,f)
        push!(F,f)
    end
    c
end

function decode(c,q)
    f = copy(q)
    p = Int64[]
    for i in eachindex(c)
        h = inverse(f)
        push!(p, h[c[i]])
        g = circshift(f,p[end])
        f = composition(g,f)
    end
    p
end

function encrypt(p, k, r)
    for i in 1:r
        K = spin(k,i)
        p = encode(p,K)
        p = reverse(p)
    end
    p
end

function decrypt(p, k, r)
    for i in 1:r
        K = spin(k,r + 1 - i)
        p = reverse(p)
        p = decode(p,K)
    end
    p
end

function demoencrypt(p, q, r, F)
    for i in 1:r
        k = spin(q,i)
        p = demoencode(p,k,F)
        p = reverse(p)
    end
    p
end

function demodecrypt(c, q, r,alph)
    @printf "            "
    printvec(c,alph)
    for i in 1:r
        k = spin(q,r + 1 - i)
        c = reverse(c)
        c = decode(c,k)
        #@printf "round %3d   " i
        printvec(c,alph)
    end
    c
end

function vecfromstring(s,alph)
    n = length(s)
    v = zeros(Int64,n)
    for i in 1:n
        v[i] = findfirst(isequal(s[i]),alph)
    end
    v
end

function nth_word(n :: Int64)
    s = string(n, base = length(alph))
    a =  Int64[]
    for i in eachindex(s)
        push!(a,parse(Int64, s[i:i], base = length(alph)) + 1)
    end
    a
end

#function rgb(r,g,b) Base.print("\u1b[38;2;$(r);$(g);$(b)m") end

function rgb(r,g,b) "\e[38;2;$(r);$(g);$(b)m" end


function demo()
    f = randomkey(n)
    print(rgb(255,255,255),"f = ", str(f),"\n")
    print(rgb(155,155,155),"r = ",r,"\n\n")
    for i in 1:20
    	F = Set()
        p = Random.randperm(n)
        c = demoencrypt(p,f,r,F)
        d = decrypt(c,f,r)
        if p != d @printf "ERROR\n\n" end
        print(rgb(255,255,255),"f( ", rgb(255,0,0), str(p),rgb(255,255,255)," ) = ")
        print(rgb(255,255,0), str(c),rgb(255,255,255),@sprintf("  %d/%d\n", length(F), r*length(p)))
    end

end


alph = "abcdefghijklmnopqrstuvwxyz"
n = length(alph)
r = 50