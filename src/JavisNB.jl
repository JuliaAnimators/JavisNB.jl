module JavisNB

using Javis

import Javis: AbstractObject, Video, StreamConfig

import Interact
import Interact: @map, @layout!, Widget, Widgets, hbox, vbox

export embed

#################
#### Pluto Viewer
#################

"""
    _pluto_viewer(video::Video, frames::Int, actions::Vector)

Creates an interactive viewer in a Pluto Notebook by storing all the frames in-memory.

# Returns

`arr`: List of Javis frames
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
when `liveview = false`.
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


##########
#### embed
##########

"""
    embed(pathname::String)

Shows a gif within a notebook by calling the path to the gif.

# Arguments
    
- `pathname::String`: the path to a gif to render in the notebook
"""
function embed(pathname::String)

    if (isdefined(Main, :IJulia) && Main.IJulia.inited) || endswith(@__FILE__, ".ipynb")
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


"""
    embed(
        video::Video;
        framerate=30,
        pathname="javis_GIBBERISH.gif",
        liveview=false,
        streamconfig::Union{StreamConfig, Nothing} = nothing,
        tempdirectory="",
        ffmpeg_loglevel="panic",
        rescale_factor=1.0,
        postprocess_frame=identity,
        postprocess_frames_flow=default_postprocess
    )

The core function of `JavisNB`.
It allows one to show the output of `Javis.render` 
from [Javis](https://juliaanimators.github.io/Javis.jl/stable/) directly within a notebook.
Notebooks supported are: 

- IJulia
- Pluto

To use it just replace `render` with `embed`, an example within `Pluto`:

```julia
# In one cell 
using Javis, JavisNB

# In a new one
begin
    function ground(args...)
        background("white")
        sethue("black")
    end
    vid = Video(500, 500)
    Background(1:50, ground)
    o = Object(JCircle(O, 20, action=:fill))
    act!(o, Action(1:25, anim_translate(Point(20, 0))))
    act!(o, Action(26:50, anim_translate(Point(-20, 0))))

    # In pure Javis here we would have
    # render(args...;kwargs...)
    # Instead, within a notebook one uses
    # embed(args...;kwargs...)
    # For example
    embed(vid, pathname="rendered_with_embed.gif")
end
```
"""
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

    out = render(
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
    )
    return if !liveview
        embed(out)
    else
        embed(out...)
    end
end

end
