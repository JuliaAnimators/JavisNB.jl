push!(LOAD_PATH, "../")

using Documenter, JavisNB

makedocs(sitename = "JavisNB.jl")

makedocs(;
    modules = [JavisNB],
    authors = "Giovanni Puccetti <g.puccetti92@gmail.com>, Jacob Zelko <jacobszelko@gmail.com> and contributors",
    repo = "https://github.com/JuliaAnimators/JavisNB.jl/blob/{commit}{path}#L{line}",
    sitename = "JavisNB.jl",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        canonical = "https://JuliaAnimators.github.io/JavisNB.jl",
        assets = String[],
    ),
    pages = ["Home" => "index.md", "References" => "references.md"],
)

deploydocs(; repo = "github.com/JuliaAnimators/JavisNB.jl", push_preview = true)
