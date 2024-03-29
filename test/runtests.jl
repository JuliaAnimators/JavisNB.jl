using Javis, JavisNB, Animations, Images
using ReferenceTests, Test
import Interact: @map, Widget, @layout!, textbox, slider

function ground(args...)
    Javis.background("white")
    sethue("black")
end

struct test_struct
    inited
end

@testset "Global Tests" begin
    @testset "Pluto Viewer" begin
        v = JavisNB.PlutoViewer("foo.png")
        astar(args...; do_action = :stroke) = star(O, 50, 5, 0.5, 0, do_action)
        acirc(args...; do_action = :stroke) = circle(Point(100, 100), 50, do_action)

        vid = Video(500, 500)
        back = Background(1:100, ground)
        star_obj = Object(1:100, astar)
        act!(star_obj, Action(morph_to(acirc; do_action = :fill)))

        l1 = @JLayer 20:60 100 100 Point(0, 0) begin
            obj = Object((args...) -> circle(O, 25, :fill))
            act!(obj, Action(1:20, appear(:fade)))
        end

        objects = vid.objects
        all_objects = [vid.objects..., Javis.flatten(vid.layers)...]
        frames = Javis.preprocess_frames!(all_objects)

        @test v.filename === "foo.png"
        img = JavisNB._pluto_viewer(vid, length(frames), objects)
        for i in 1:length(img)
            @test img[i] == Javis.get_javis_frame(vid, objects, i, layers = [l1])
        end
    end

    @testset "Jupyter Viewer" begin
        astar(args...; do_action = :stroke) = star(O, 50, 5, 0.5, 0, do_action)
        acirc(args...; do_action = :stroke) = circle(Point(100, 100), 50, do_action)

        vid = Video(500, 500)
        back = Background(1:100, ground)
        star_obj = Object(1:100, astar)
        act!(star_obj, Action(morph_to(acirc; do_action = :fill)))

        l1 = @JLayer 20:60 100 100 Point(0, 0) begin
            obj = Object((args...) -> circle(O, 25, :fill))
            act!(obj, Action(1:20, appear(:fade)))
        end

        objects = vid.objects
        all_objects = [vid.objects..., Javis.flatten(vid.layers)...]
        frames = Javis.preprocess_frames!(all_objects)

        img = JavisNB._jupyter_viewer(vid, length(frames), objects, 30)
        @test img.output.val == Javis.get_javis_frame(vid, objects, 1, layers = [l1])

        txt = textbox(1:length(frames), typ = "Frame", value = 2)
        frm = slider(1:length(frames), label = "Frame", value = txt[] + 1)
        @test Javis.get_javis_frame(vid, objects, 2, layers = [l1]) ==
              Javis.get_javis_frame(vid, objects, txt[], layers = [l1])
        @test Javis.get_javis_frame(vid, objects, 3, layers = [l1]) ==
              Javis.get_javis_frame(vid, objects, frm[], layers = [l1])

        for i in 4:length(frames)
            output = Javis.get_javis_frame(vid, objects, i, layers = [l1])
            wdg = Widget(["frm" => frm, "txt" => txt], output = output)
            img = @layout! wdg vbox(hbox(:frm, :txt), output)
            @test img.output.val == output
        end
    end

    @testset "Layers Feature" begin
        function ground(args...)
            background("white")
            sethue("black")
        end

        function object_layer(p = O, color = "black")
            @JShape begin
                sethue(color)
                circle(p, 7, :fill)
                return p
            end color = color
        end

        function path!(points, pos, color)
            sethue(color)
            push!(points, pos) # add pos to points
            circle.(points, 2, :fill) # draws a circle for each point using broadcasting
        end

        function connector(p1, p2, color)
            sethue(color)
            line(p1, p2, :stroke)
        end

        video = Video(600, 600)
        Background(1:80, ground)

        path_of_red = Point[]
        path_of_blue = Point[]

        function ground1(args...)
            background("black")
            sethue("white")
        end

        function ground2(args...)
            background("orange")
            sethue("blue")
        end

        l1 = @JLayer 20:60 600 600 Point(0, 0) begin
            Background(5:41, ground1)
            red_ball = Object(5:41, object_layer(O, "red"), Point(50, 0))
            act!(red_ball, Action(anim_rotate_around(2π, O)))
            blue_ball = Object(5:41, object_layer(O, "blue"), Point(100, 40))
            act!(blue_ball, Action(anim_rotate_around(2π, 0.0, red_ball)))

            # the frame range for actions have 2 level nesting(check for that)
            act!(blue_ball, Action(5:30, appear(:fade)))
            connect = Object(
                5:41,
                (args...) -> connector(pos(red_ball), pos(blue_ball), "black"),
            )
            path_ofRed =
                Object(5:41, (args...) -> path!(path_of_red, pos(red_ball), "red"))
            path_ofBlue =
                Object(5:41, (args...) -> path!(path_of_blue, pos(blue_ball), "blue"))
        end

        l2 = @JLayer 20:60 begin
            Background(5:41, ground1)
            ball1 = Object(5:41, object_layer(O, "red"), Point(50, 0))
            act!(ball1, Action(anim_rotate_around(2π, O)))
            ball2 = Object(5:41, object_layer(O, "blue"), Point(100, 40))
            act!(ball2, Action(anim_rotate_around(2π, 0.0, ball1)))
            act!(ball2, Action(5:30, appear(:fade)))
            conn = Object(5:41, (args...) -> connector(pos(ball1), pos(ball2), "black"))
            path_ball1 =
                Object(5:41, (args...) -> path!(path_of_red, pos(ball1), "red"))
            path_ball2 =
                Object(5:41, (args...) -> path!(path_of_blue, pos(ball2), "blue"))
        end

        l3 = @JLayer 20:60 600 600 begin
            Background(5:41, ground1)
            rball = Object(5:41, object_layer(O, "red"), Point(50, 0))
            act!(rball, Action(anim_rotate_around(2π, O)))
            bball = Object(5:41, object_layer(O, "blue"), Point(100, 40))
            act!(bball, Action(anim_rotate_around(2π, 0.0, rball)))
            act!(bball, Action(5:30, appear(:fade)))
            con = Object(5:41, (args...) -> connector(pos(rball), pos(bball), "black"))
            path_rball =
                Object(5:41, (args...) -> path!(path_of_red, pos(rball), "red"))
            path_bball =
                Object(5:41, (args...) -> path!(path_of_blue, pos(bball), "blue"))
        end

        # dont forget to update the reference images once anim_rotate_around is fixed
        layer_actions = [
            Action(1:4, appear(:fade)),
            Action(5:25, anim_translate(l1.position, Point(300, 300))),
            Action(5:25, anim_rotate(2π)),
            Action(5:25, disappear(:fade)),
            Action(5:25, anim_scale(0)),
        ]

        act!([l1, l2, l3], layer_actions)

        ball1 = Object(5:41, object_layer(O, "red"), Point(50, 0))
        act!(ball1, Action(anim_rotate_around(2π, O)))
        ball2 = Object(5:41, object_layer(O, "blue"), Point(100, 40))
        act!(ball2, Action(anim_rotate_around(2π, 0.0, ball1)))
        act!(ball2, Action(10:30, disappear(:fade)))
        conn = Object(5:41, (args...) -> connector(pos(ball1), pos(ball2), "black"))
        por = Object(5:41, (args...) -> path!(path_of_red, pos(ball1), "red"))
        pob = Object(5:41, (args...) -> path!(path_of_blue, pos(ball2), "blue"))
        layer_objects = [ball1, ball2, conn, por, pob]

        @test l1.frames.frames == l2.frames.frames == l3.frames.frames
        @test l1.width == l2.width == l3.width == 600
        @test l1.height == l2.height == l3.height == 600
        @test l1.position == l2.position == l3.position == Point(0, 0)
        @test length(l1.layer_objects) ==
              length(l2.layer_objects) ==
              length(l3.layer_objects) ==
              length(layer_objects) + 2
        @test length(l1.actions) ==
              length(l2.actions) ==
              length(l3.actions) ==
              length(layer_actions)
        @test l1.current_setting.opacity ==
              l2.current_setting.opacity ==
              l3.current_setting.opacity ==
              1.0
        @test l1.current_setting.scale ==
              l2.current_setting.scale ==
              l3.current_setting.scale ==
              Javis.Scale(1.0, 1.0)
        @test l1.current_setting.rotation_angle ==
              l2.current_setting.rotation_angle ==
              l3.current_setting.rotation_angle ==
              0.0
        @test l1.image_matrix == l2.image_matrix == l3.image_matrix == nothing

        # remove duplicate layers after above testing
        video.layers = [l1]
        @test get_position(l1) == Point(0, 0)

        astar(args...; do_action = :stroke) = star(O, 50, 5, 0.5, 0, do_action)
        acirc(args...; do_action = :stroke) = circle(Point(100, 100), 50, do_action)
        star_obj = Object(1:30, astar)
        act!(star_obj, Action(Javis.linear(), morph_to(acirc)))
        circle_obj = Object(31:60, acirc)
        act!(circle_obj, Action(Javis.linear(), morph_to(astar)))

        opacity_anim = Animation(
            [0, 0.5, 1], # must go from 0 to 1
            [0.0, 0.3, 0.7],
            [sineio(), sineio()],
        )

        l4 = @JLayer 5:20 200 200 Point(-50, 50) :transparent begin
            Background(1:14, ground2)
            rball = Object(1:14, object_layer(O, "black"), Point(0, 0))
            act!(rball, Action(anim_translate(Point(20, -20))))
        end

        act!(l4, Action(1:5, opacity_anim, setopacity()))
        act!(l4, Action(10:15, anim_rotate_around(2pi, O)))



        #test show_layer_frame
        Javis.show_layer_frame(71:79, 5:12, l1)
        Javis.show_layer_frame(71:79, 10, l4)

        embed(video; tempdirectory = "images", pathname = "layer_test.gif")

        for i in
            [3, 5, 8, 10, 18, 19, 20, 24, 33, 41, 43, 45, 49, 51, 59, 65, 71, 76, 77, 79]
            @test_reference "refs/layer$i.png" load("images/$(lpad(i, 10, "0")).png")
            @test isfile("layer_test.gif")
        end
        rm("layer_test.gif")
    end


    # TODO: add these tests once the branch in javis is merged 
    # @testset "embed" begin
    #     astar(args...; do_action = :stroke) = star(O, 50, 5, 0.5, 0, do_action)
    #     acirc(args...; do_action = :stroke) = circle(Point(100, 100), 50, do_action)

    #     vid = Video(500, 500)
    #     back = Background(1:100, ground)
    #     star_obj = Object(1:100, astar)
    #     act!(star_obj, Action(morph_to(acirc; do_action = :fill)))

    #     l1 = @JLayer 20:60 100 100 Point(0, 0) begin
    #         obj = Object((args...) -> circle(O, 25, :fill))
    #         act!(obj, Action(1:20, appear(:fade)))
    #     end

    #     objects = vid.objects
    #     all_objects = [vid.objects..., Javis.flatten(vid.layers)...]
    #     frames = Javis.preprocess_frames!(all_objects)

    #     IJulia = test_struct(true)
    #     img = embed(vid, liveview=true, pathname="images/embed_rendered.gif")
    #     @test img.output.val == Javis.get_javis_frame(vid, objects, 1, layers = [l1])

    #     v = JavisNB.PlutoViewer("foo.png")
    #     astar(args...; do_action = :stroke) = star(O, 50, 5, 0.5, 0, do_action)
    #     acirc(args...; do_action = :stroke) = circle(Point(100, 100), 50, do_action)

    #     vid = Video(500, 500)
    #     back = Background(1:100, ground)
    #     star_obj = Object(1:100, astar)
    #     act!(star_obj, Action(morph_to(acirc; do_action = :fill)))

    #     l1 = @JLayer 20:60 100 100 Point(0, 0) begin
    #         obj = Object((args...) -> circle(O, 25, :fill))
    #         act!(obj, Action(1:20, appear(:fade)))
    #     end

    #     objects = vid.objects
    #     all_objects = [vid.objects..., Javis.flatten(vid.layers)...]
    #     frames = Javis.preprocess_frames!(all_objects)

    #     # tricks Javis into thinking it is working within Pluto
    #     PlutoRunner = test_struct(true)

    #     img = embed(vid, pathname="images/test_pluto_viewer.gif")
    #     @test isa(img, JavisNB.PlutoViewer)
    #     @test img.filename === "images/test_pluto_viewer.gif"
    # end

    for i in readdir("images/", join = true)
        (endswith(i, ".png") || endswith(i, ".gif")) && rm(i)
    end
end
