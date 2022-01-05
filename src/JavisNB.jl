module JavisNB

using Javis

import Javis: AbstractObject, Video, StreamConfig

import Interact
import Interact: @map, @layout!, Widget

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
        Javis.get_javis_frame(video, objects, frame; layers = video.layers) for
        frame in 1:frames
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
    output = @map Javis.get_javis_frame(video, objects, &obs; layers = video.layers)
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

embed(::Nothing) = nothing

function embed(
    video::Video;
    framerate = 30,
    pathname = "javis_$(randstring(7)).gif",
    liveview = false,
    streamconfig::Union{StreamConfig,Nothing} = nothing,
    tempdirectory = "",
    ffmpeg_loglevel = "panic",
    rescale_factor = 1.0,
    postprocess_frames_flow = identity,
    postprocess_frame = Javis.default_postprocess,
)

    return embed(
        render(
            video,
            framerate = framerate,
            pathname = pathname,
            liveview = liveview,
            streamconfig = streamconfig,
            tempdirectory = tempdirectory,
            ffmpeg_loglevel = ffmpeg_loglevel,
            rescale_factor = rescale_factor,
            postprocess_frames_flow = postprocess_frames_flow,
            postprocess_frame = postprocess_frame,
        ),
    )
end

end
