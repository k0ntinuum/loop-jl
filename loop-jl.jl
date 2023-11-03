using Random
using Printf


key(n) =  Random.randperm(n)

str_from_vec(v)  = join(map(i -> alph[i:i], v))

vec_from_str(s) = map(i -> findfirst(isequal(i),alph),collect(s))

nth_word(n) =  vec_from_str(string(n, base = length(alph)))

nth_vec(n) = map(i -> parse(Int64, i, base = length(alph)), collect(string(n, base = length(alph))))

inv(f) = map(i -> findfirst(isequal(i),f),collect(1:length(f)))

comp(f,g) = map(i -> f[g[i]], collect(1:length(f)))

rgb(r,g,b) =  "\e[38;2;$(r);$(g);$(b)m"

red() = rgb(255,0,0);yellow() = rgb(255,255,0);white() = rgb(255,255,255);gray(h) = rgb(h,h,h)

roll(f,i) = comp(circshift(f,i),f)

function rolls(f) 
	for i in 1:n f = roll(f,i)	 end 
	f  
end

function spin(f,r) 
	for i in 1:r f = rolls(f) end 
	f 
end


function encode(p,q)
    f = copy(q)
    c = Int64[]
    for i in eachindex(p)
        push!(c,f[p[i]])
        g = circshift(f,p[i])
        f = comp(g,f)
    end
    c
end


function encode(p,q,F)
    f = copy(q)
    c = Int64[]
    for i in eachindex(p)
        push!(c,f[p[i]])
        g = circshift(f,p[i])
        f = comp(g,f)
        push!(F,f)
    end
    c
end


function decode(c,q)
    f = copy(q)
    p = Int64[]
    for i in eachindex(c)
        h = inv(f)
        push!(p, h[c[i]])
        g = circshift(f,p[end])
        f = comp(g,f)
    end
    p
end

function encrypt(p, q, r)
    for i in 1:r
        f = spin(q,i)
        p = encode(p,f)
        p = reverse(p)
    end
    p
end

function decrypt(p, k, r)
    for i in 1:r
        f = spin(k,r + 1 - i)
        p = reverse(p)
        p = decode(p,f)
    end
    p
end

function encrypt(p, q, r, F)
    for i in 1:r
        f = spin(q,i)
        p = encode(p,f,F)
        p = reverse(p)
    end
    p
end




function demo()
    print(white(),"f = ", str(f))
    print(gray(155),"          r = ",r,"\n\n")
    for i in 1:20
    	F = Set()
        p = Random.randperm(n)
        c = encrypt(p,f,r,F)
        d = decrypt(c,f,r)
        if p != d @printf "ERROR\n\n" end
        print(white(),"f( ", red(), str(p),white()," ) = ")
        print(yellow(), str(c),white(),@sprintf("  %d/%d\n", length(F), r*length(p)))
    end

end


alph = "abcdefghijklmnopqrstuvwxyz"
n = length(alph)
r = 10
f = key(n)