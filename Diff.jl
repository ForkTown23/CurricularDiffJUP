using CurricularAnalytics

# helper functions
function prereq_print(prereqs::Set{AbstractString})
    string = " "
    for prereq in prereqs
        string = string * prereq
        string = string * " "
    end
    string
end

function get_course_prereqs(curriculum::Curriculum, course::Course)
    # get all the prereqs
    course_prereqs = Vector{Course}()
    for (key, value) in course.requisites
        # get the course name
        course = curriculum.courses[key]
        push!(course_prereqs, course)
    end
    course_prereqs
end

function course_from_name(curriculum::Curriculum, course_name::AbstractString)
    for c in curriculum.courses
        if c.name == course_name
            return c
        end
    end
end

function pretty_print_course_names(courses::Vector{AbstractString})
    for course in courses
        print("$(course)➡️")
    end
    println(" ")
end

function courses_to_course_names(courses::Vector{Course})
    course_names = AbstractString[]
    for course in courses
        push!(course_names, course.name)
    end
    course_names
end

function courses_that_depend_on_me(course_me::Course, curriculum::Curriculum)
    # me is the course
    courses_that_depend_on_me = Course[]
    # look through all courses in curriculum. if one of them lists me as a prereq, add them to the list
    for course in curriculum.courses
        # look through the courses prerequisite
        for (key, value) in course.requisites
            # the key is what matters, it is the id of the course in the curriculum
            if (value == pre && key == course_me.id) # let's skip co-reqs for now... interesting to see if this matters later

                push!(courses_that_depend_on_me, course)
            end
        end
    end

    courses_that_depend_on_me
end

function blocking_factor_investigator(course_me::Course, curriculum::Curriculum)
    # this should:
    # check all courses to make a list of courses that consider this one a prereq
    # then for each of those find which courses deem that course a prereq
    # repeat until the list of courses that consider a given course a prereq is empty.
    unblocked_field = courses_that_depend_on_me(course_me, curriculum)
    if (length(unblocked_field) != 0)
        # if theres courses that depend on my current course, find the immediately unblocked field of each of those courses
        # and add it to courses_that_depend_on_me
        for course_A in unblocked_field
            courses_that_depend_on_course_A = courses_that_depend_on_me(course_A, curriculum)
            if (length(courses_that_depend_on_course_A) != 0)
                for course in courses_that_depend_on_course_A
                    if (!(course in unblocked_field)) # avoid duplicates
                        push!(unblocked_field, course)
                    end
                end
            end
        end
    end
    unblocked_field
end

function delay_factor_investigator(course_me::Course, curriculum::Curriculum)
    # this is harder because we need to find the longest path
    # for each course in my unblocked field, calculate the longest path from a sink up to them that includes me
    my_unblocked_field = blocking_factor_investigator(course_me, curriculum)
    delay_factor_path = Course[]
    # if my unblocked field is empty, find the longest path to me
    if (length(my_unblocked_field) == 0)
        # call longest path to me with no filter
        delay_factor_path = longest_path_to_me(course_me, curriculum, course_me, false)
    else
        # select only the sink nodes of my unblocked field. this is bad for time complexity, though
        sinks_in_my_u_field = filter((x) -> length(courses_that_depend_on_me(x, curriculum)) == 0, my_unblocked_field)

        # for each of the sinks, calculate longest path to them, that passes through me
        longest_path_through_me = []
        longest_length_through_me = 0
        for sink in sinks_in_my_u_field
            # NOTE: this will unfortunately produce the longest path stemming from me, not the whole path. *shrug for now*
            path = longest_path_to_me(sink, curriculum, course_me, true)
            if (length(path) > longest_length_through_me)
                longest_length_through_me = length(path)
                longest_path_through_me = path
            end
        end

        # now that you have the longest path stemming from me,
        # find the longest path to me and put em together. They will unfortunately include me twice, so make sure to remove me from one of them
        longest_up_to_me = longest_path_to_me(course_me, curriculum, course_me, false)
        pop!(longest_up_to_me)
        for course in longest_up_to_me
            push!(delay_factor_path, course)
        end
        for course in longest_path_through_me
            push!(delay_factor_path, course)
        end
    end

    delay_factor_path
end

function centrality_investigator(course_me::Course, curriculum::Curriculum)
    # this will return the paths that make up the centrality of a course
    g = curriculum.graph
    course = course_me.vertex_id[curriculum.id]
    centrality_paths = []
    for path in all_paths(g)
        # stole the conditions from the CurricularAnalytics.jl repo
        if (in(course, path) && length(path) > 2 && path[1] != course && path[end] != course)
            # convert this path to courses
            course_path = Vector{Course}()
            for id in path
                push!(course_path, curriculum.courses[id])
            end

            # then add this path to the collection of paths
            push!(centrality_paths, course_path)
        end
    end
    centrality_paths
end

function longest_path_to_me(course_me::Course, curriculum::Curriculum, filter_course::Course, filter::Bool=false)
    # for each prereq of mine find the longest path up to that course
    longest_path_to_course_me = Course[]
    longest_paths_to_me = []
    for (key, value) in course_me.requisites
        #if (value == pre) # reconsider if coreqs count here *shrug*
        longest_path_to_prereq = longest_path_to_me(curriculum.courses[key], curriculum, filter_course, filter)
        push!(longest_paths_to_me, longest_path_to_prereq)
        #end
    end
    # compare the lengths, filter by the ones that contain the filter course if needed
    if (filter)
        # choose the longest path length that contains filter course
        length_of_longest_path = 0
        for array in longest_paths_to_me
            if (length(array) > length_of_longest_path && filter_course in array)
                longest_path_to_course_me = array
                length_of_longest_path = length(array)
            end
        end
    else
        # choose the longest path
        length_of_longest_path = 0
        for array in longest_paths_to_me
            if (length(array) > length_of_longest_path)
                longest_path_to_course_me = array
                length_of_longest_path = length(array)
            end
        end
    end

    # add myself to the chosen longest path and return that
    push!(longest_path_to_course_me, course_me)
    longest_path_to_course_me
end

# main functions
function course_diff(course1::Course, course2::Course, curriculum1::Curriculum, curriculum2::Curriculum, runningtally::Vector{Float64}, verbose::Bool=true)
    relevant_fields = filter(x ->
            x != :vertex_id &&
                x != :cross_listed &&
                x != :requisites &&
                x != :learning_outcomes &&
                x != :metrics &&
                x != :passrate &&
                x != :metadata,
        fieldnames(Course))

    for field in relevant_fields
        field1 = getfield(course1, field)
        field2 = getfield(course2, field)
        if (field1 == field2)
            if (verbose)
                println("✅Course 1 and Course 2 have the same $field: $field1")
            end
        else
            println("❌Course 1 has $(field): $field1 and Course 2 has $(field): $field2")
        end
    end

    # METRICS
    # complexity
    if (course1.metrics["complexity"] == course2.metrics["complexity"])
        if (verbose)
            println("✅Course 1 and Course 2 have the same complexity: $(course1.metrics["complexity"])")
        end
    else
        println("❌Course 1 has complexity $(course1.metrics["complexity"]) and Course 2 has complexity $(course2.metrics["complexity"])")
        runningtally[1] += (course2.metrics["complexity"] - course1.metrics["complexity"])
    end
    # centrality
    explanations_centrality = Dict()
    if (course1.metrics["centrality"] == course2.metrics["centrality"])
        if (verbose)
            println("✅Course 1 and Course 2 have the same centrality: $(course1.metrics["centrality"])")
        end
    else
        println("❌Course 1 has centrality $(course1.metrics["centrality"]) and Course 2 has centrality $(course2.metrics["centrality"])")
        runningtally[2] += (course2.metrics["centrality"] - course1.metrics["centrality"])

        # run the investigator and then compare
        centrality_c1 = centrality_investigator(course1, curriculum1)
        centrality_c2 = centrality_investigator(course2, curriculum2)

        # turn those into course names
        # note that its an array of arrays so for each entry you have to convert to course names
        centrality_c1_set = Set()
        centrality_c2_set = Set()
        for path in centrality_c1
            path_names = courses_to_course_names(path)
            push!(centrality_c1_set, path_names)
        end
        for path in centrality_c2
            path_names = courses_to_course_names(path)
            push!(centrality_c2_set, path_names)
        end
        # set diff
        not_in_c2 = setdiff(centrality_c1_set, centrality_c2_set)
        not_in_c1 = setdiff(centrality_c2_set, centrality_c1_set)

        # analyse
        println("The paths in course 1's centrality that aren't in course 2's are:")
        for path in not_in_c2
            pretty_print_course_names(path)
        end

        println("The paths in course 2's centrality that aren't in course 1's are:")
        for path in not_in_c1
            pretty_print_course_names(path)
        end

        explanations_centrality["paths not in c2"] = collect(not_in_c2)
        explanations_centrality["paths not in c1"] = collect(not_in_c1)
        explanations_centrality["courses not in c2 paths"] = Dict()
        explanations_centrality["courses not in c1 paths"] = Dict()

        # TODO: consider explaining these differences, but they should be explainable by changes in the block and delay factors. 
        # The only complication there is that these changes can be attributed to changes in the prereqs of those block and delay factors so theyre compounded. It's a lot harder
        # Would have to go through all the members of those paths and check each of those for changes. Could be.

        # To explain differences grab all the courses in the set of paths not in c2 
        # check them against the matching courses in c2 looking for changes in prereqs
        # grab all the courses in the set of paths not in c1 
        # check them against the matching courses in c1 looking for changes in prereqs

        println("checking courses in paths in curriculum 1 but not in curriculum 2")
        # grab all the courses in the set of paths not in c2
        all_courses_not_in_c2 = []
        for path in not_in_c2
            # this is a vector of AbstractString. look in each entry of that vector for course names
            for course in path
                if (!(course in all_courses_not_in_c2))
                    push!(all_courses_not_in_c2, course)
                end
            end
        end
        # check them against matching courses in c2 looking for different prereqs
        for course in all_courses_not_in_c2
            c1 = course_from_name(curriculum1, course)
            c2 = course_from_name(curriculum2, course)
            # find their prerequisites
            prereqs_in_curr1 = Set(courses_to_course_names(get_course_prereqs(curriculum1, c1)))
            prereqs_in_curr2 = Set(courses_to_course_names(get_course_prereqs(curriculum2, c2)))
            # compare the prerequisites
            # lost prereqs are those that from c1 to c2 got dropped
            # gained prerqs are those that from c1 to c2 got added
            lost_prereqs = setdiff(prereqs_in_curr1, prereqs_in_curr2)
            gained_prereqs = setdiff(prereqs_in_curr2, prereqs_in_curr1)

            explanations_centrality["courses not in c2 paths"][course] = Dict()
            explanations_centrality["courses not in c2 paths"][course]["lost prereqs"] = lost_prereqs
            explanations_centrality["courses not in c2 paths"][course]["gained prereqs"] = gained_prereqs

            if (length(lost_prereqs) == 0)
                if (verbose)
                    print("$(course) lost no prereqs")
                end
            else
                println("$(course) lost these prereqs: $(prereq_print(lost_prereqs))")
            end

            if (length(gained_prereqs) == 0)
                if (verbose)
                    println("$(course) gained no prereqs")
                end
            else
                println("$(course) gained these prereqs: : $(prereq_print(gained_prereqs))")
            end
        end

        println("checking courses in paths in curriculum 2 but not in curriculum 1")
        # grab all the courses in the set of paths not in c1
        all_courses_not_in_c1 = []
        for path in not_in_c1
            # this is a vector of AbstractString. look in each entry of that vector for course names
            for course in path
                if (!(course in all_courses_not_in_c1))
                    push!(all_courses_not_in_c1, course)
                end
            end
        end
        # check them against matching courses in c2 looking for different prereqs
        for course in all_courses_not_in_c1
            c1 = course_from_name(curriculum1, course)
            c2 = course_from_name(curriculum2, course)
            # find their prerequisites
            prereqs_in_curr1 = Set(courses_to_course_names(get_course_prereqs(curriculum1, c1)))
            prereqs_in_curr2 = Set(courses_to_course_names(get_course_prereqs(curriculum2, c2)))
            # compare the prerequisites
            # lost prereqs are those that from c1 to c2 got dropped
            # gained prerqs are those that from c1 to c2 got added
            lost_prereqs = setdiff(prereqs_in_curr1, prereqs_in_curr2)
            gained_prereqs = setdiff(prereqs_in_curr2, prereqs_in_curr1)

            explanations_centrality["courses not in c1 paths"][course] = Dict()
            explanations_centrality["courses not in c1 paths"][course]["lost prereqs"] = lost_prereqs
            explanations_centrality["courses not in c1 paths"][course]["gained prereqs"] = gained_prereqs

            if (length(lost_prereqs) == 0)
                if (verbose)
                    print("$(course) lost no prereqs")
                end
            else
                println("$(course) lost these prereqs: $(prereq_print(lost_prereqs))")
            end

            if (length(gained_prereqs) == 0)
                if (verbose)
                    println("$(course) gained no prereqs")
                end
            else
                println("$(course) gained these prereqs: : $(prereq_print(gained_prereqs))")
            end
        end

    end
    # make Dict for return values
    explanations_blockingfactor = Dict()
    # blocking factor
    if (course1.metrics["blocking factor"] == course2.metrics["blocking factor"])
        if (verbose)
            println("✅Course 1 and Course 2 have the same blocking factor: $(course1.metrics["blocking factor"])")
        end
    else
        println("❌Course 1 has blocking factor $(course1.metrics["blocking factor"]) and Course 2 has blocking factor $(course2.metrics["blocking factor"])")
        runningtally[3] += (course2.metrics["blocking factor"] - course1.metrics["blocking factor"])

        # since they have different blocking factors, investigate why and get a set of blocking factors
        unblocked_field_course_1 = blocking_factor_investigator(course1, curriculum1)
        unblocked_field_course_2 = blocking_factor_investigator(course2, curriculum2)
        unblocked_field_course_1_names = Set(courses_to_course_names(unblocked_field_course_1))
        unblocked_field_course_2_names = Set(courses_to_course_names(unblocked_field_course_2))
        # use setdiff to track which courses aren't in course 2's unblocked field and which aren't in course 1's unblocked field
        not_in_c2_unbl_field = setdiff(unblocked_field_course_1_names, unblocked_field_course_2_names)
        not_in_c1_unbl_field = setdiff(unblocked_field_course_2_names, unblocked_field_course_1_names)

        explanations_blockingfactor["length not in c2 ufield"] = length(not_in_c2_unbl_field)
        explanations_blockingfactor["not in c2 ufield"] = Dict()
        if (length(not_in_c2_unbl_field) != 0)
            # there are courses in c1's unblocked that aren't in course2s
            println("the following courses aren't in course 2's unblocked field:")
            # FIND THE COURSES HERE THAT HAVE CHANGED THEIR PREREQS
            for course_name in not_in_c2_unbl_field
                explanations_blockingfactor["not in c2 ufield"][course_name] = Dict()
                # find course to match name in curriculum1 and curriculum2
                course_in_curr1 = course_from_name(curriculum1, course_name)
                course_in_curr2 = course_from_name(curriculum2, course_name)
                # find their prerequisites
                prereqs_in_curr1 = Set(courses_to_course_names(get_course_prereqs(curriculum1, course_in_curr1)))
                prereqs_in_curr2 = Set(courses_to_course_names(get_course_prereqs(curriculum2, course_in_curr2)))
                # compare the prerequisites
                # lost prereqs are those that from c1 to c2 got dropped
                # gained prerqs are those that from c1 to c2 got added
                lost_prereqs = setdiff(prereqs_in_curr1, prereqs_in_curr2)
                gained_prereqs = setdiff(prereqs_in_curr2, prereqs_in_curr1)
                explanations_blockingfactor["not in c2 ufield"][course_name]["lost prereqs"] = lost_prereqs
                explanations_blockingfactor["not in c2 ufield"][course_name]["gained prereqs"] = gained_prereqs

                # check if the prereqs haven't changed. If they haven't changed, we need to find which of their prereqs did
                if (length(lost_prereqs) == 0 && length(gained_prereqs) == 0)
                    # find this course's prereqs and match them with any other courses in not_in_c2_unbl_field
                    # find this course's prereqs in curriculum 1
                    prereqs_in_curr1_set = Set(prereqs_in_curr1)
                    # cross reference with the list of courses not in not_in_c2_unbl_field
                    not_in_c2_unbl_field_set = Set(not_in_c2_unbl_field)

                    in_both = intersect(prereqs_in_curr1_set, not_in_c2_unbl_field_set)

                    println("$(course_name)'s prerequisites have not changed, but it depends on $(prereq_print(in_both)), which might have changed")
                    explanations_blockingfactor["not in c2 ufield"][course_name]["in_both"] = collect(in_both)

                else
                    println("$(course_name): lost prereqs: $(prereq_print(lost_prereqs)), gained prereqs: $(prereq_print(gained_prereqs))")
                    explanations_blockingfactor["not in c2 ufield"][course_name]["in_both"] = []
                end
            end
        else
            println("every course in course 1's unblocked field is in course 2's unblocked field")
        end
        explanations_blockingfactor["length not in c1 ufield"] = length(not_in_c1_unbl_field)
        explanations_blockingfactor["not in c1 ufield"] = Dict()
        if (length(not_in_c1_unbl_field) != 0)
            # there are courses in c2's unblocked that aren't in course1s
            println("the following courses aren't in course 1's unblocked field:")
            # TODO: FIND THE COURSES HERE THAT HAVE CHANGED THEIR PREREQS
            for course_name in not_in_c1_unbl_field
                explanations_blockingfactor["not in c1 ufield"][course_name] = Dict()
                # find course to match name in curriculum1 and curriculum2
                course_in_curr1 = course_from_name(curriculum1, course_name)
                course_in_curr2 = course_from_name(curriculum2, course_name)
                # find their prerequisites
                prereqs_in_curr1 = Set(courses_to_course_names(get_course_prereqs(curriculum1, course_in_curr1)))
                prereqs_in_curr2 = Set(courses_to_course_names(get_course_prereqs(curriculum2, course_in_curr2)))
                # compare the prerequisites
                lost_prereqs = setdiff(prereqs_in_curr1, prereqs_in_curr2)
                gained_prereqs = setdiff(prereqs_in_curr2, prereqs_in_curr1)

                explanations_blockingfactor["not in c1 ufield"][course_name]["lost prereqs"] = lost_prereqs
                explanations_blockingfactor["not in c1 ufield"][course_name]["gained prereqs"] = gained_prereqs
                # check if the prereqs haven't changed. If they haven't changed, we need to find which of their prereqs did
                if (length(lost_prereqs) == 0 && length(gained_prereqs) == 0)
                    # find this course's prereqs and match them with any other courses in not_in_c1_unbl_field
                    # find this course's prereqs in curriculum 2
                    prereqs_in_curr2_set = Set(prereqs_in_curr2)
                    # cross reference with the list of courses not in not_in_c1_unbl_field
                    not_in_c1_unbl_field_set = Set(not_in_c1_unbl_field)

                    in_both = intersect(prereqs_in_curr2_set, not_in_c1_unbl_field_set)

                    println("$(course_name)'s prerequisites have not changed, but it depends on $(prereq_print(in_both)), which might have changed")
                    explanations_blockingfactor["not in c1 ufield"][course_name]["in_both"] = collect(in_both)
                else
                    println("$(course_name): lost prereqs: $(prereq_print(lost_prereqs)), gained prereqs: $(prereq_print(gained_prereqs))")
                    explanations_blockingfactor["not in c1 ufield"][course_name]["in_both"] = []
                end
            end
        else
            println("every course in course 2's unblocked field is in course 1's unblocked field")
        end
    end
    # delay factor
    explanations_delayfactor = Dict()
    if (course1.metrics["delay factor"] == course2.metrics["delay factor"])
        if (verbose)
            println("✅Course 1 and Course 2 have the same delay factor: $(course1.metrics["delay factor"])")
        end
    else
        println("❌Course 1 has delay factor $(course1.metrics["delay factor"]) and Course 2 has delay factor $(course2.metrics["delay factor"])")
        runningtally[4] += (course2.metrics["delay factor"] - course1.metrics["delay factor"])
        df_path_course_1 = courses_to_course_names(delay_factor_investigator(course1, curriculum1))
        df_path_course_2 = courses_to_course_names(delay_factor_investigator(course2, curriculum2))
        print("Course 1's delay factor path:")
        pretty_print_course_names(df_path_course_1)
        print("Course 2's delay factor path:")
        pretty_print_course_names(df_path_course_2)

        explanations_delayfactor["df path course 1"] = df_path_course_1
        explanations_delayfactor["df path course 2"] = df_path_course_2
        # explain why
        df_set_c1 = Set(df_path_course_1)
        df_set_c2 = Set(df_path_course_2)

        all_courses_in_paths = union(df_set_c1, df_set_c2)
        explanations_delayfactor["courses involved"] = Dict()

        for course in all_courses_in_paths
            explanations_delayfactor["courses involved"][course] = Dict()
            # find course to match name in curriculum1 and curriculum2
            course_in_curr1 = course_from_name(curriculum1, course)
            course_in_curr2 = course_from_name(curriculum2, course)
            # find their prerequisites
            prereqs_in_curr1 = Set(courses_to_course_names(get_course_prereqs(curriculum1, course_in_curr1)))
            prereqs_in_curr2 = Set(courses_to_course_names(get_course_prereqs(curriculum2, course_in_curr2)))
            # compare the prerequisites
            # lost prereqs are those that from c1 to c2 got dropped
            # gained prerqs are those that from c1 to c2 got added
            lost_prereqs = setdiff(prereqs_in_curr1, prereqs_in_curr2)
            gained_prereqs = setdiff(prereqs_in_curr2, prereqs_in_curr1)
            explanations_delayfactor["courses involved"][course]["lost prereqs"] = lost_prereqs
            explanations_delayfactor["courses involved"][course]["gained prereqs"] = gained_prereqs
            if (length(lost_prereqs) != 0 || length(gained_prereqs) != 0)
                println("$(course) has had changes: lost $(prereq_print(lost_prereqs)) and gained $(prereq_print(gained_prereqs))")
            end
        end

    end
    # requisites
    # collate all the prerequisite names from course 1
    course1_prereqs = Set(courses_to_course_names(get_course_prereqs(curriculum1, course1)))

    course2_prereqs = Set(courses_to_course_names(get_course_prereqs(curriculum2, course2)))

    println("The sets of prerequisites being equal is $(issetequal(course1_prereqs, course2_prereqs))")
    if (!issetequal(course1_prereqs, course2_prereqs))
        println("Courses in course 1's prereq list:")
        for course in course1_prereqs
            println("\t$(course)")
        end
        println("Courses in course 2's prereq list:")
        for course in course2_prereqs
            println("\t$(course)")
        end
    end

    [runningtally, explanations_blockingfactor, explanations_centrality, explanations_delayfactor]

end

function curricular_diff(curriculum1::Curriculum, curriculum2::Curriculum, verbose::Bool=true)
    # using fieldnames instead of explicit names
    relevant_fields = filter(x ->
            x != :courses &&
                x != :graph &&
                x != :learning_outcomes &&
                x != :learning_outcome_graph &&
                x != :course_learning_outcome_graph &&
                x != :metrics &&
                x != :metadata,
        fieldnames(Curriculum))

    for field in relevant_fields
        field1 = getfield(curriculum1, field)
        field2 = getfield(curriculum2, field)
        if (field1 == field2)
            if (verbose)
                println("✅Curriculum 1 and Curriculum 2 have the same $field: $field1")
            end
        else
            println("❌Curriculum 1 has $(field): $field1 and Curriculum 2 has $(field): $field2")
        end
    end

    # compare metrics
    try
        basic_metrics(curriculum1)
    catch
    end
    try
        basic_metrics(curriculum2)
    catch
    end
    metrics_same = true
    # complexity and max complexity
    if (curriculum1.metrics["complexity"][1] == curriculum2.metrics["complexity"][1])
        if (verbose)
            println("✅Curriculum 1 and Curriculum 2 have the same total complexity: $(curriculum1.metrics["complexity"][1])")
        end
    else
        println("❌Curriculum 1 has a total complexity score of $(curriculum1.metrics["complexity"][1]) and Curriculum2 has a total complexity score $(curriculum2.metrics["complexity"][1])")
        metrics_same = false
    end
    if (curriculum1.metrics["max. complexity"] == curriculum2.metrics["max. complexity"])
        if (verbose)
            println("✅Curriculum 1 and Curriculum 2 have the same max complexity : $(curriculum1.metrics["max. complexity"])")
        end
    else
        println("❌Curriculum 1 has a max complexity of $(curriculum1.metrics["max. complexity"]) and Curriculum 2 has a max complexity of $(curriculum2.metrics["max. complexity"])")
        metrics_same = false
    end
    # centrality and max centrality
    if (curriculum1.metrics["centrality"][1] == curriculum2.metrics["centrality"][1])
        if (verbose)
            println("✅Curriculum 1 and Curriculum 2 have the same total centrality: $(curriculum1.metrics["centrality"][1])")
        end
    else
        println("❌Curriculum 1 has a total centrality score of $(curriculum1.metrics["centrality"][1]) and Curriculum2 has a total centrality score $(curriculum2.metrics["centrality"][1])")
        metrics_same = false
    end
    if (curriculum1.metrics["max. centrality"] == curriculum2.metrics["max. centrality"])
        if (verbose)
            println("✅Curriculum 1 and Curriculum 2 have the same max centrality : $(curriculum1.metrics["max. centrality"])")
        end
    else
        println("❌Curriculum 1 has a max centrality of $(curriculum1.metrics["max. centrality"]) and Curriculum 2 has a max centrality of $(curriculum2.metrics["max. centrality"])")
        metrics_same = false
    end
    # blocking factor and max blocking factor
    if (curriculum1.metrics["blocking factor"][1] == curriculum2.metrics["blocking factor"][1])
        if (verbose)
            println("✅Curriculum 1 and Curriculum 2 have the same total blocking factor: $(curriculum1.metrics["blocking factor"][1])")
        end
    else
        println("❌Curriculum 1 has a total blocking factor score of $(curriculum1.metrics["blocking factor"][1]) and Curriculum2 has a total blocking factor score $(curriculum2.metrics["blocking factor"][1])")
        metrics_same = false
    end
    if (curriculum1.metrics["max. blocking factor"] == curriculum2.metrics["max. blocking factor"])
        if (verbose)
            println("✅Curriculum 1 and Curriculum 2 have the same max blocking factor : $(curriculum1.metrics["max. blocking factor"])")
        end
    else
        println("❌Curriculum 1 has a max blocking factor of $(curriculum1.metrics["max. blocking factor"]) and Curriculum 2 has a max blocking factor of $(curriculum2.metrics["max. blocking factor"])")
        metrics_same = false
    end
    # delay factor and max delay factor
    if (curriculum1.metrics["delay factor"][1] == curriculum2.metrics["delay factor"][1])
        if (verbose)
            println("✅Curriculum 1 and Curriculum 2 have the same total delay factor: $(curriculum1.metrics["delay factor"][1])")
        end
    else
        println("❌Curriculum 1 has a total delay factor score of $(curriculum1.metrics["delay factor"][1]) and Curriculum2 has a total delay factor score $(curriculum2.metrics["delay factor"][1])")
        metrics_same = false
    end
    if (curriculum1.metrics["max. delay factor"] == curriculum2.metrics["max. delay factor"])
        if (verbose)
            println("✅Curriculum 1 and Curriculum 2 have the same max delay factor : $(curriculum1.metrics["max. delay factor"])")
        end
    else
        println("❌Curriculum 1 has a max delay factor of $(curriculum1.metrics["max. delay factor"]) and Curriculum 2 has a max delay factor of $(curriculum2.metrics["max. delay factor"])")
        metrics_same = false
    end

    # if the stats don't match up or we asked for a deep dive, take a deep dive!
    if (!metrics_same || verbose)
        println("Taking a look at courses")
        # make the initial changes array, i.e. what we're trying to explain
        explain = [curriculum2.metrics["complexity"][1] - curriculum1.metrics["complexity"][1],
            curriculum2.metrics["centrality"][1] == curriculum1.metrics["centrality"][1],
            curriculum2.metrics["blocking factor"][1] == curriculum1.metrics["blocking factor"][1],
            curriculum2.metrics["delay factor"][1] == curriculum1.metrics["delay factor"][1],
        ]

        explained = [0.0, 0.0, 0.0, 0.0]
        # for each course in curriculum 1, try to find a similarly named course in curriculum 2
        for course in curriculum1.courses
            # this is the catch: MATH 20A and MATH 20A or 10A are not going to match
            matching_course = filter(x -> x.name == course.name, curriculum2.courses)
            if (length(matching_course) == 0)
                println("No matching course found for $(course.name)")
            elseif (length(matching_course) == 1)
                println("Match found for $(course.name)")
                course2 = matching_course[1]
                explained = course_diff(course, course2, curriculum1, curriculum2, explained, verbose)
                explained = explained[1]
                println("explained so far: $(explained[1]), $(explained[2]), $(explained[3]), $(explained[4])")
            else
                println("Something weird here, we have more than one match")
            end
        end
    end
end