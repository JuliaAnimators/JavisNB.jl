### A Pluto.jl notebook ###
# v0.17.4

using Markdown
using InteractiveUtils

# ╔═╡ e7cac400-6751-11ec-3910-af3121135a31
begin
	using Pkg
	Pkg.activate(".")
	using Revise, JavisNB, Javis, PlutoTest
end

# ╔═╡ e7cac400-6751-11ec-3498-bd690b38b180
let
	function ground(c1, c2)
		(args...) -> begin
			background("white")
			sethue("black")
		end
	end
	
	myvideo = Video(500, 500)
	Background(1:100, ground("white", "black"))
	ob = Object(JCircle(O, 30, color="black", action=:fill))
	act!(ob, Action(1:50, anim_translate(Point(100, 0))))
	act!(ob, Action(50:100, anim_translate(Point(-100, 0))))
	v = render(myvideo, pathname="files/test_pluto_viewer.gif")
end

# ╔═╡ 50f9030b-ac9e-4d56-99f1-fb6fe721f1ac
embed("files/test_pluto_viewer.gif")

# ╔═╡ Cell order:
# ╠═e7cac400-6751-11ec-3910-af3121135a31
# ╠═e7cac400-6751-11ec-3498-bd690b38b180
# ╠═50f9030b-ac9e-4d56-99f1-fb6fe721f1ac
