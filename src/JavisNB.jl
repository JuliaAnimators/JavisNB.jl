module JavisNB

using Javis

import Javis: AbstractObject, Video

import Interact
import Interact: @map, @layout!

export embed

###################
###### Pluto Viewer
###################

"""
    _pluto_viewer(video::Video, frames::Int, actions::Vector)
Creates an interactive viewer in a Pluto Notebook by storing all the frames in-memory
```
# In separate Pluto notebook cells
using PlutoUI

anim = render(
    video;
    pathname = "loading.gif",liveview=true
);

@bind x Slider(1:1:frames)

anim[x]
```
"""
function _pluto_viewer(video::Video, frames::Int, objects::Vector)
    arr = collect(
        Javis.get_javis_frame(video, objects, frame; layers = video.layers) for frame in 1:frames
    )
    return arr
end

"""
    PlutoViewer

Wrapper to assist viewing rendered gifs as cell outputs of Pluto notebooks
when `liveview = false` 
"""
struct PlutoViewer
    filename::String
end

function Base.show(io::IO, ::MIME"image/png", v::PlutoViewer)
    write(io, read(v.filename))
end

###################
#### Jupyter Viewer
################### 


"""
    _jupyter_viewer(video::Video, frames::Int, actions::Vector)
Creates an interactive viewer in a Jupyter Notebook.
"""
function _jupyter_viewer(
    video::Video,
    frames::Int,
    objects::Vector{AbstractObject},
    framerate::Int,
)
    t = Interact.textbox(1:frames, value = 1, typ = Int)
    f = Interact.slider(1:frames, label = "Frame", value = t)
    obs = Interact.Observables.throttle(1 / framerate, f)
    output = @map get_javis_frame(video, objects, &obs; layers = video.layers)
    wdg = Widget(["f" => f, "t" => t], output = output)
    @layout! wdg vbox(hbox(:f, :t), output)
end


"""
    embed(pathname)

This is the core function of `JavisNB` it allows to show the output of `render` 
from [`Javis`](https://juliaanimators.github.io/Javis.jl/stable/) directly within 
a notebook (IJulia or Pluto).

To use it just wrap it around the `render``, am example within `Pluto`:

```julia
using Javis, JavisNB

myVideo - Vide(...)

# All the code here...

embed(render(myVideo)...)
```
"""
function embed(pathname::String)
    
    if isdefined(Main, :IJulia) && Main.IJulia.inited
        display(MIME("text/html"), """<img src="$(pathname)">""")
    elseif isdefined(Main, :PlutoRunner)
        return PlutoViewer(pathname)
    end

    return pathname
end

function embed(vid::Video, frames::Int, objects::Vector{AbstractObject}, framerate::Int)
    return _jupyter_viewer(vid, frames, objects, framerate)
end

function embed(vid::Video, frames::Int, objects::Vector{AbstractObject})
    return _pluto_viewer(vid, frames, objects)
end

end