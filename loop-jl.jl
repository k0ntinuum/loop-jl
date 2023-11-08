using Random
using Printf



#
#nth_word(n) =  vec_from_str(string(n, base = length(alph)))
#
#nth_vec(n) = map(i -> parse(Int64, i, base = length(alph)), collect(string(n, base = length(alph))))
#

function inverse(f)
    map(i -> findfirst(isequal(i),f),collect(1:length(f)))
end


function rgb(r,g,b)
    "\e[38;2;$(r);$(g);$(b)m"
end

function red()
    rgb(255,0,0)
end

function yellow()
    rgb(255,255,0)
end

function white()
    rgb(255,255,255)
end

function gray(h)
    rgb(h,h,h)
end


function str_from_vec(v,c)
    #alph = "O|"
    alph = "abcdefghijklmnopqrstuvwxyz"
    join(map(i -> alph[i:i]*c, v))
end

function printkey(k)
    n = size(k)[begin]
	for i in 1:n print(str_from_vec( k[i,:]," " ),"\n") end
	print("\n")
end



function vec_from_str(s)
    map(i -> findfirst(isequal(i),alph),collect(s))
end

function comp(f,g) 
    map(i -> f[g[i]], collect(1:length(f)))
end

function roll(f,i)
    comp(circshift(f,i),f)
end


function key(n)
    Random.randperm(n)
end

function rolls(f)
    n = size(f)[begin] 
	for i in 1:n f = roll(f,i)	 end 
	f  
end

function spin(f,j)
	for i in 1:j f = rolls(f) end 
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
        h = inverse(f)
        push!(p, h[c[i]])
        g = circshift(f,p[end])
        f = comp(g,f)
    end
    p
end

function encrypt(p, q)
    n = size(q)[begin]
    for i in 1:n
        f = spin(q,i)
        p = encode(p,f)
        p = reverse(p)
    end
    p
end

function decrypt(p, q)
    n = size(q)[begin]
    for i in 1:n
        f = spin(q,n + 1 - i)
        p = reverse(p)
        p = decode(p,f)
    end
    p
end

function encrypt(p, q, F)
    n = size(q)[begin]
    for i in 1:n
        f = spin(q,i)
        p = encode(p,f,F)
        p = reverse(p)
    end
    p
end




function demo()
    
    n = 26
    f = key(n)
    print(white(),"f = ", str_from_vec(f,""), "\n\n")
    for i in 1:26
    	F = Set()
        p = Random.randperm(n)
        c = encrypt(p,f,F)
        d = decrypt(c,f)
        if p != d @printf "ERROR\n\n" end
        print(white(),"f( ", red(), str_from_vec(p,""),white()," ) = ")
        print(yellow(), str_from_vec(c,""),white(),@sprintf("  %d/%d\n", length(F), n*length(p)))
    end

end


