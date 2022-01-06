### A Pluto.jl notebook ###
# v0.17.4

using Markdown
using InteractiveUtils

# ╔═╡ e7cac400-6751-11ec-3910-af3121135a31
begin
    using Pkg
    Pkg.activate("..")
    using Revise, JavisNB, Javis
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
    ob = Object(JCircle(O, 30, color = "black", action = :fill))
    act!(ob, Action(1:50, anim_translate(Point(100, 0))))
    act!(ob, Action(51:100, anim_translate(Point(-100, 0))))
    v = render(myvideo, pathname = "images/test_pluto_viewer_render.gif")
end

# ╔═╡ 9dc6164c-7896-4114-acad-2229a3b93b7a
embed("temp_files/test_pluto_viewer_render.gif")

# ╔═╡ 50f9030b-ac9e-4d56-99f1-fb6fe721f1ac
let
    function ground(c1, c2)
        (args...) -> begin
            background("white")
            sethue("black")
        end
    end

    myvideo = Video(500, 500)
    Background(1:100, ground("white", "black"))
    ob = Object(JCircle(O, 30, color = "black", action = :fill))
    act!(ob, Action(1:50, anim_translate(Point(100, 0))))
    act!(ob, Action(51:100, anim_translate(Point(-100, 0))))
    embed(myvideo, tempdirectory = "images", pathname = "")
end

# ╔═╡ 109494be-9b41-4c8b-9f6c-26ffc361fa12


# ╔═╡ Cell order:
# ╠═e7cac400-6751-11ec-3910-af3121135a31
# ╠═e7cac400-6751-11ec-3498-bd690b38b180
# ╠═9dc6164c-7896-4114-acad-2229a3b93b7a
# ╠═50f9030b-ac9e-4d56-99f1-fb6fe721f1ac
# ╠═109494be-9b41-4c8b-9f6c-26ffc361fa12
