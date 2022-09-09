include("./Diff.jl")
include("./ExecSummary.jl")

@enum DesiredStat ALL CEN COM BLO DEL PRE
function pretty_print_centrality_results(results::Dict{String,Dict})
    # CENTRALITY -----------------------------------------------------------------------
    print("Centrality: ")
    # highlight the centrality change: if its negative, that's good, so green. Else red
    results["contribution to curriculum differences"]["centrality"] <= 0 ?
    print(GREEN_BG, results["contribution to curriculum differences"]["centrality"]) :
    print(RED_BG, results["contribution to curriculum differences"]["centrality"])
    print(BLACK_BG, "\n")

    print(BLACK_BG, "Curriculum 1 score: $(results["centrality"]["course 1 score"])\tCurriculum 2 score: $(results["centrality"]["course 2 score"])\n")

    if ("paths not in c2" in keys(results["centrality"]))
        print("Paths not in Curriculum 2:\n")
        for path in results["centrality"]["paths not in c2"]
            pretty_print_course_names(path)
        end

        print("Courses in \"not in Curriculum 2 Paths\": (WORKING TITLE-ONLY INCLUDING THE ONES WITH CHANGES HERE)\n")
        for (key, value) in results["centrality"]["courses not in c2 paths"]
            if (length(value["gained prereqs"]) != 0 || length(value["lost prereqs"]) != 0)
                print("$key: ")
                if (length(value["gained prereqs"]) != 0)
                    print("\tgained:")
                    for gain in value["gained prereqs"]
                        print(" $gain")
                    end
                else
                    print("\tdidn't gain any prereqs")
                end
                print("\tand")
                if (length(value["lost prereqs"]) != 0)
                    print("\tlost:")
                    for loss in value["lost prereqs"]
                        print(" $loss")
                    end
                else
                    print("\tdidn't lose any prereqs")
                end
                print("\n")
            end
        end
    end

    if ("paths not in c1" in keys(results["centrality"]))
        print("Paths not in Curriculum 1:\n")
        for path in results["centrality"]["paths not in c1"]
            pretty_print_course_names(path)
        end

        print("Courses in \"not in Curriculum 1 Paths\": (WORKING TITLE-ONLY INCLUDING THE ONES WITH CHANGES HERE)\n")
        for (key, value) in results["centrality"]["courses not in c1 paths"]
            if (length(value["gained prereqs"]) != 0 || length(value["lost prereqs"]) != 0)
                print("$key: ")
                if (length(value["gained prereqs"]) != 0)
                    print("\tgained:")
                    for gain in value["gained prereqs"]
                        print(" $gain")
                    end
                else
                    print("\tdidn't gain any prereqs")
                end
                print("\tand")
                if (length(value["lost prereqs"]) != 0)
                    print("\tlost:")
                    for loss in value["lost prereqs"]
                        print(" $loss")
                    end
                else
                    print("\tdidn't lose any prereqs")
                end
                print("\n")
            end
        end
    end
end

function pretty_print_complexity_results(results::Dict{String,Dict})
    print("Complexity: ")
    results["contribution to curriculum differences"]["complexity"] <= 0 ?
    print(GREEN_BG, results["contribution to curriculum differences"]["complexity"]) :
    print(RED_BG, results["contribution to curriculum differences"]["complexity"])

    print(BLACK_BG, "\n")

    print(BLACK_BG, "Score in Curriculum 1: $(results["complexity"]["course 1 score"]) \t Score in Curriculum 2: $(results["complexity"]["course 2 score"])\n")

    pretty_print_blocking_factor_results(results)
    pretty_print_delay_factor_results(results)
end

function pretty_print_blocking_factor_results(results::Dict{String,Dict})
    # Print the blocking factor results
    print("Blocking Factor: ")
    results["contribution to curriculum differences"]["blocking factor"] <= 0 ?
    print(GREEN_BG, results["contribution to curriculum differences"]["blocking factor"]) :
    print(RED_BG, results["contribution to curriculum differences"]["blocking factor"])
    print(BLACK_BG, "\n")

    print(BLACK_BG, "Score in Curriculum 1: $(results["blocking factor"]["course 1 score"])")
    print(BLACK_BG, "\t")
    print(BLACK_BG, "Score in Curriculum 2: $(results["blocking factor"]["course 2 score"])")
    print(BLACK_BG, "\n")

    if ("not in c2 ufield" in keys(results["blocking factor"]))
        if (length(results["blocking factor"]["not in c2 ufield"]) != 0)
            print("Courses not in this course's unblocked field in curriculum 2:\n")
            for (key, value) in results["blocking factor"]["not in c2 ufield"]
                print("$(key):\n")
                if (length(value["gained prereqs"]) != 0)
                    print("\tgained:")
                    for gain in value["gained prereqs"]
                        print(" $gain")
                    end
                else
                    print("\tno gained prereqs")
                end
                print("\n")
                if (length(value["lost prereqs"]) != 0)
                    print("\tlost:")
                    for loss in value["lost prereqs"]
                        print(" $loss")
                    end
                else
                    print("\tno lost prereqs")
                end
                print("\n")
                if (length(value["in_both"]) != 0)
                    print("\talso has as prereq:")
                    for overlap in value["in_both"]
                        print(" $(overlap)")
                    end
                else
                    print("\tno dependency on another course in this list")
                end
                print("\n")
            end
        else
            println("All courses in the Curriculum 1 unblocked field are in the Curriculum 2 unblocked field")
        end
    end

    if ("not in c1 ufield" in keys(results["blocking factor"]))
        if (length(results["blocking factor"]["not in c1 ufield"]) != 0)
            print("Courses not in this course's unblocked field in curriculum 1:\n")
            for (key, value) in results["blocking factor"]["not in c1 ufield"]
                print("$(key):\n")
                if (length(value["gained prereqs"]) != 0)
                    print("\tgained:")
                    for gain in value["gained prereqs"]
                        print(" $gain")
                    end
                else
                    print("\tno gained prereqs")
                end
                print("\n")
                if (length(value["lost prereqs"]) != 0)
                    print("\tlost:")
                    for loss in value["lost prereqs"]
                        print(" $loss")
                    end
                else
                    print("\tno lost prereqs")
                end
                print("\n")
                if (length(value["in_both"]) != 0)
                    print("\talso has as prereq:")
                    for overlap in value["in_both"]
                        print(" $(overlap)")
                    end
                else
                    print("\tno dependency on another course in this list")
                end
                print("\n")
            end
        else
            println("All courses in the Curriculum 2 unblocked field are in the Curriculum 1 unblocked field")
        end
    end
end

function pretty_print_delay_factor_results(results::Dict{String,Dict})
    # Delay factor 
    print("Delay Factor: ")
    results["contribution to curriculum differences"]["delay factor"] <= 0 ?
    print(GREEN_BG, results["contribution to curriculum differences"]["delay factor"]) :
    print(RED_BG, results["contribution to curriculum differences"]["delay factor"])
    print(BLACK_BG, "\n")

    print(BLACK_BG, "Score in Curriculum 1: $(results["delay factor"]["course 1 score"])\t Score in Curriculum 2: $(results["delay factor"]["course 2 score"])\n")

    if ("df path course 1" in keys(results["delay factor"])) # if there's one there both
        print("Delay Factor Path in Curriculum 1:\n")
        pretty_print_course_names(results["delay factor"]["df path course 1"])

        print("Delay Factor Path in Curriculum 2:\n")
        pretty_print_course_names(results["delay factor"]["df path course 2"])

        println("Courses involved that changed:")
        for (key, value) in results["delay factor"]["courses involved"]
            if (length(value["gained prereqs"]) != 0 || length(value["lost prereqs"]) != 0)
                print("$key:\n")
                if (length(value["gained prereqs"]) != 0)
                    print("\tgained:")
                    for gain in value["gained prereqs"]
                        print(" $gain")
                    end
                else
                    print("\tno gained prereqs")
                end
                print("\n")
                if (length(value["lost prereqs"]) != 0)
                    print("\tlost:")
                    for loss in value["lost prereqs"]
                        print(" $loss")
                    end
                else
                    print("\tno lost prereqs")
                end
                print("\n")
            end
        end
    end
end

function pretty_print_prereq_changes(results::Dict{String,Dict})
    if (length(results["prereqs"]["gained prereqs"]) != 0)
        println("Gained prereqs:")
        for course in results["prereqs"]["gained prereqs"]
            print(" $course")
        end
        println("")
    end

    if (length(results["prereqs"]["lost prereqs"]) != 0)
        println("Lost prereqs:")
        for course in results["prereqs"]["lost prereqs"]
            print(" $course")
        end
        println("")
    end

end

function pretty_print_course_results(results::Dict{String,Dict}, course_name::AbstractString, desired_stat::DesiredStat)
    # this should pretty print results

    # separator
    println("-------------")
    println(course_name)

    if (desired_stat == ALL || desired_stat == CEN)
        pretty_print_centrality_results(results)
    end
    if (desired_stat == ALL || desired_stat == COM)
        pretty_print_complexity_results(results)
    end
    if (desired_stat == BLO)
        pretty_print_blocking_factor_results(results)
    end
    if (desired_stat == DEL)
        pretty_print_delay_factor_results(results)
    end
    if (desired_stat == ALL || desired_stat == PRE)
        println("Prereq Changes:")
        pretty_print_prereq_changes(results)
    end
end

function pretty_print_curriculum_results(curriculum_results::Dict{Any,Any}, desired_stat::DesiredStat)
    for (key, value) in curriculum_results["matched courses"]
        pretty_print_course_results(value, key, desired_stat)
    end
    if (length(curriculum_results["unmatched courses"]) != 0)
        println("*******")
        println("Unmatched courses:")
        for (key, value) in curriculum_results["unmatched courses"]
            executive_summary_unmatched_course(value, key)
        end
    end
end