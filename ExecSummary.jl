include("./Diff.jl")

function executive_summary_course(results::Dict{String,Dict}, course_name::AbstractString)
    println("----------------")
    println("$course_name:")
    if (results["contribution to curriculum differences"]["centrality"] != 0.0)
        if (length(results["centrality"]["paths not in c2"]) != 0)
            # find the total sum of paths not in c2
            lost_paths = sum(length(path) for path in results["centrality"]["paths not in c2"])
            print(GREEN_BG, "Lost $(lost_paths) centrality ")
            print(BLACK_BG, "due to:\n")
            for (key, course) in results["centrality"]["courses not in c2 paths"]
                if (length(course["gained prereqs"]) != 0 || length(course["lost prereqs"]) != 0)
                    print("\t$key:")
                    if (length(course["lost prereqs"]) != 0)
                        print("\t losing")
                        for loss in course["lost prereqs"]
                            print(" $loss")
                        end
                    end
                    if (length(course["gained prereqs"]) != 0)
                        print("\t gaining")
                        for gain in course["gained prereqs"]
                            print(" $gain")
                        end
                    end
                    println("")
                end
            end
        end
        if (length(results["centrality"]["paths not in c1"]) != 0)
            # find the total sum of paths not in c1
            gained_paths = sum(length(path) for path in results["centrality"]["paths not in c1"])
            print(RED_BG, "Gained $(gained_paths) centrality ")
            print(BLACK_BG, "due to:\n")
            for (key, course) in results["centrality"]["courses not in c1 paths"]
                if (length(course["gained prereqs"]) != 0 || length(course["lost prereqs"]) != 0)
                    print("\t$key:")
                    if (length(course["lost prereqs"]) != 0)
                        print("\t losing")
                        for loss in course["lost prereqs"]
                            print(" $loss")
                        end
                    end
                    if (length(course["gained prereqs"]) != 0)
                        print("\t gaining")
                        for gain in course["gained prereqs"]
                            print(" $gain")
                        end
                    end
                    println("")
                end
            end
        end
    end
    if (results["contribution to curriculum differences"]["blocking factor"] != 0.0)
        if (results["blocking factor"]["length not in c2 ufield"] != 0)
            print(GREEN_BG, "Lost $(results["blocking factor"]["length not in c2 ufield"]) courses in blocking factor ")
            print(BLACK_BG, "due to:\n")
            for (key, course) in results["blocking factor"]["not in c2 ufield"]
                if (length(course["gained prereqs"]) != 0 || length(course["lost prereqs"]) != 0 || length(course["in_both"]) != 0)
                    print("\t$key")
                    if (length(course["lost prereqs"]) != 0)
                        print("\t losing")
                        for loss in course["lost prereqs"]
                            print(" $loss")
                        end
                    end
                    if (length(course["gained prereqs"]) != 0)
                        print("\t gaining")
                        for gain in course["gained prereqs"]
                            print(" $gain")
                        end
                    end
                    if (length(course["in_both"]) != 0)
                        print("\tdepending on")
                        for overlap in course["in_both"]
                            print(" $overlap")
                        end
                    end
                    println("")
                end

            end
        end
        if (results["blocking factor"]["length not in c1 ufield"] != 0)
            print(RED_BG, "Gained $(results["blocking factor"]["length not in c1 ufield"]) courses in blocking factor ")
            print(BLACK_BG, "due to:\n")
            for (key, course) in results["blocking factor"]["not in c1 ufield"]
                if (length(course["gained prereqs"]) != 0 || length(course["lost prereqs"]) != 0 || length(course["in_both"]) != 0)
                    print("\t$key")
                    if (length(course["lost prereqs"]) != 0)
                        print("\t losing")
                        for loss in course["lost prereqs"]
                            print(" $loss")
                        end
                    end
                    if (length(course["gained prereqs"]) != 0)
                        print("\t gaining")
                        for gain in course["gained prereqs"]
                            print(" $gain")
                        end
                    end
                    if (length(course["in_both"]) != 0)
                        print("\tdepending on")
                        for overlap in course["in_both"]
                            print(" $overlap")
                        end
                    end
                    println("")
                end
            end
        end
    end
    if (results["contribution to curriculum differences"]["delay factor"] != 0.0)
        print("Delay Factor: ")
        if (results["contribution to curriculum differences"]["delay factor"] > 0)
            print(RED_BG, "Gained $(abs(results["contribution to curriculum differences"]["delay factor"]))")
        else
            print(GREEN_BG, "Lost $(abs(results["contribution to curriculum differences"]["delay factor"]))")
        end
        print(BLACK_BG, "\nWent from: ") # important, stops red/green from overflowing for some reason
        pretty_print_course_names(results["delay factor"]["df path course 1"])
        print("Length: $(results["delay factor"]["course 1 score"])\n")
        print("To: ")
        pretty_print_course_names(results["delay factor"]["df path course 2"])
        print("Length: $(results["delay factor"]["course 2 score"])\n")
        print("Due to:\n")
        for (key, course) in results["delay factor"]["courses involved"]
            if (length(course["gained prereqs"]) != 0 || length(course["lost prereqs"]) != 0)
                print("\t$key")
                if (length(course["lost prereqs"]) != 0)
                    print("\t losing")
                    for loss in course["lost prereqs"]
                        print(" $loss")
                    end
                end
                if (length(course["gained prereqs"]) != 0)
                    print("\t gaining")
                    for gain in course["gained prereqs"]
                        print(" $gain")
                    end
                end
                println("")
            end
        end
    end
end

function executive_summary_unmatched_course(results::Dict{}, course_name::AbstractString)
    println("----------------")
    println("$course_name:")
    if (results["contribution to curriculum differences"]["centrality"] != 0.0)
        # if it's a C1-only course, it lost everything
        results["c1"] ? print(GREEN_BG("Lost $(results["centrality"]) centrality. ", BLACK_BG("Course doesn't exist in curriculum 2"))) :
        print(RED_BG("Gained $(results["centrality"]) centrality. ", BLACK_BG("Course doesn't exist in curriculum 1")))

        print(BLACK_BG, "\n")
    end
    if (results["contribution to curriculum differences"]["blocking factor"] != 0.0)
        # if it's a C1-only course, it lost everything
        results["c1"] ? print(GREEN_BG("Lost $(results["blocking factor"]) blocking factor. ", BLACK_BG("Course doesn't exist in curriculum 2"))) :
        print(RED_BG("Gained $(results["blocking factor"]) blocking factor. ", BLACK_BG("Course doesn't exist in curriculum 1")))

        print(BLACK_BG, "\n")
    end
    if (results["contribution to curriculum differences"]["delay factor"] != 0.0)
        # if it's a C1-only course, it lost everything
        results["c1"] ? print(GREEN_BG("Lost $(results["delay factor"]) delay factor. ", BLACK_BG("Course doesn't exist in curriculum 2"))) :
        print(RED_BG("Gained $(results["delay factor"]) delay factor. ", BLACK_BG("Course doesn't exist in curriculum 1")))

        print(BLACK_BG, "\n")
    end

end

function executive_summary_curriculum(curriculum_results::Dict{Any,Any})
    for (key, value) in curriculum_results["matched courses"]
        if (value["contribution to curriculum differences"]["centrality"] != 0.0 || value["contribution to curriculum differences"]["blocking factor"] != 0.0 || value["contribution to curriculum differences"]["delay factor"] != 0.0)
            executive_summary_course(value, key)
        end
    end
    if (length(curriculum_results["unmatched courses"]) != 0)
        println("******************")
        println("Unmatched Courses")
        for (key, value) in curriculum_results["unmatched courses"]
            if (value["contribution to curriculum differences"]["centrality"] != 0.0 || value["contribution to curriculum differences"]["blocking factor"] != 0.0 || value["contribution to curriculum differences"]["delay factor"] != 0.0)
                executive_summary_unmatched_course(value, key)
            end
        end
    end
end