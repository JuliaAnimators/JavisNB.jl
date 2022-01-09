# JavisNB

## How to use JavisNB

`JavisNB` is a small package to use [Javis.jl](https://juliaanimators.github.io/Javis.jl/stable/) within notebooks.

It works in a very straightforward way, first write all the code for an animation 
just like you would with `Javis` and then replace `Javis.render` with `JavisNB.embed`, 
this way on top of sending the output to a file, the gif will be shown in the notebook.

The `liveview` argument that in `Javis.render` would activate a liveviewer is available 
in `JavisNB.embed` as well but it works differently. In `Pluto` it returns
an array of the frames composing a gif, in `Jupyter` it starts an interactive view of the
animation and lets you scroll through the frame.

## Pluto Examples

![](../assets/JavisNB_pluto_shown.gif)

Cells' code to copy and paste it:

```julia
# Top cell
using JavisNB, Javis

# Bottom cell
begin
    function ground(args...)
        background("blue")
        sethue("black")
    end
    vid = Video(500, 150)
    Background(1:50, ground)
    o = Object(JCircle(Point(-100, 0), 20, action = :fill, color = "orange"))
    act!(o, Action(1:25, anim_translate(Point(200, 0))))
    act!(o, Action(26:50, anim_translate(Point(-200, 0))))
    a = embed(vid, pathname = "test.gif")
end
```

![](../assets/JavisNB_pluto_liveview_shown.gif)

Cells' code to copy and paste it:

```julia
# Cell 1
using JavisNB, Javis, PlutoUI

# Cell 2
begin
    function ground(args...)
        background("blue")
        sethue("black")
    end
    vid = Video(500, 150)
    Background(1:50, ground)
    o = Object(JCircle(Point(-100, 0), 20, action = :fill, color = "orange"))
    act!(o, Action(1:25, anim_translate(Point(200, 0))))
    act!(o, Action(26:50, anim_translate(Point(-200, 0))))
    a = embed(vid, pathname = "test.gif", liveview = true)
end

# Cell 3
@bind idx Slider(1:length(a), show_value=true)

# Cell 4
a[idx]
```

## Jupyter Examples

![](../assets/JavisNB_jupyter_shown.gif)

Cells' code to copy and paste it:

```julia
# Top cell
using JavisNB, Javis

# Bottom cell
begin
    function ground(args...)
        background("blue")
        sethue("black")
    end
    vid = Video(500, 150)
    Background(1:50, ground)
    o = Object(JCircle(Point(-100, 0), 20, action = :fill, color = "orange"))
    act!(o, Action(1:25, anim_translate(Point(200, 0))))
    act!(o, Action(26:50, anim_translate(Point(-200, 0))))
    a = embed(vid, pathname = "test.gif")
end
```

![](../assets/JavisNB_jupyter_liveview_shown.gif)

Cells' code to copy and paste it:

```julia
# Top cell
using JavisNB, Javis

# Bottom cell
begin
    function ground(args...)
        background("blue")
        sethue("black")
    end
    vid = Video(500, 150)
    Background(1:50, ground)
    o = Object(JCircle(Point(-100, 0), 20, action = :fill, color = "orange"))
    act!(o, Action(1:25, anim_translate(Point(200, 0))))
    act!(o, Action(26:50, anim_translate(Point(-200, 0))))
    a = embed(vid, pathname = "test.gif", liveview=true)
end
```