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

![](../assets/JavisNB_pluto_liveview_shown.gif)

## Jupyter Examples

![](../assets/JavisNB_jupyter_shown.gif)

![](../assets/JavisNB_jupyter_liveview_shown.gif)