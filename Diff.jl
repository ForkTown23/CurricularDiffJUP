using CurricularAnalytics

# helper functions
function courses_to_course_names(courses::Vector{Course})
    course_names = []
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

end

function longest_path_to_me(course_me::Course, curriculum::Curriculum, filter_course::Course, filter::Bool=false)
    # for each prereq of mine find the longest path up to that course
    longest_path_to_course_me = Course[]
    longest_paths_to_me = []
    for (key, value) in course_me.requisites
        if (value == pre) # reconsider if coreqs count here *shrug*
            longest_path_to_prereq = longest_path_to_me(curriculum.courses[key], curriculum, filter_course, filter)
            push!(longest_paths_to_me, longest_path_to_prereq)
        end
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
function course_diff(course1::Course, course2::Course, curriculum1::Curriculum, curriculum2::Curriculum, verbose::Bool=true)
    # compare:
    # name
    if (course1.name == course2.name)
        if (verbose)
            println("✅Course 1 and Course 2 have the same name: $(course1.name)")
        end
    else
        println("❌Course 1 has name $(course1.name) and Course 2 has name $(course2.name)")
    end

    # credit_hours
    if (course1.credit_hours == course2.credit_hours)
        if (verbose)
            println("✅Course 1 and Course 2 have the same credit_hours: $(course1.credit_hours)")
        end
    else
        println("❌Course 1 has credit_hours $(course1.credit_hours) and Course 2 has credit_hours $(course2.credit_hours)")
    end

    # prefix
    if (course1.prefix == course2.prefix)
        if (verbose)
            println("✅Course 1 and Course 2 have the same prefix: $(course1.prefix)")
        end
    else
        println("❌Course 1 has prefix $(course1.prefix) and Course 2 has prefix $(course2.prefix)")
    end

    # num
    if (course1.num == course2.num)
        if (verbose)
            println("✅Course 1 and Course 2 have the same num: $(course1.num)")
        end
    else
        println("❌Course 1 has num $(course1.num) and Course 2 has num $(course2.num)")
    end

    # institution
    if (course1.institution == course2.institution)
        if (verbose)
            println("✅Course 1 and Course 2 have the same institution: $(course1.institution)")
        end
    else
        println("❌Course 1 has institution $(course1.institution) and Course 2 has institution $(course2.institution)")
    end

    # college
    if (course1.college == course2.college)
        if (verbose)
            println("✅Course 1 and Course 2 have the same college: $(course1.college)")
        end
    else
        println("❌Course 1 has college $(course1.college) and Course 2 has college $(course2.college)")
    end

    # department
    if (course1.department == course2.department)
        if (verbose)
            println("✅Course 1 and Course 2 have the same department: $(course1.department)")
        end
    else
        println("❌Course 1 has department $(course1.department) and Course 2 has department $(course2.department)")
    end

    # canonical_name
    if (course1.canonical_name == course2.canonical_name)
        if (verbose)
            println("✅Course 1 and Course 2 have the same canonical_name: $(course1.canonical_name)")
        end
    else
        println("❌Course 1 has canonical_name $(course1.canonical_name) and Course 2 has canonical_name $(course2.canonical_name)")
    end

    # METRICS
    # complexity
    if (course1.metrics["complexity"] == course2.metrics["complexity"])
        if (verbose)
            println("✅Course 1 and Course 2 have the same complexity: $(course1.metrics["complexity"])")
        end
    else
        println("❌Course 1 has complexity $(course1.metrics["complexity"]) and Course 2 has complexity $(course2.metrics["complexity"])")
    end
    # centrality
    if (course1.metrics["centrality"] == course2.metrics["centrality"])
        if (verbose)
            println("✅Course 1 and Course 2 have the same centrality: $(course1.metrics["centrality"])")
        end
    else
        println("❌Course 1 has centrality $(course1.metrics["centrality"]) and Course 2 has centrality $(course2.metrics["centrality"])")
    end
    # blocking factor
    if (course1.metrics["blocking factor"] == course2.metrics["blocking factor"])
        if (verbose)
            println("✅Course 1 and Course 2 have the same blocking factor: $(course1.metrics["blocking factor"])")
        end
    else
        println("❌Course 1 has blocking factor $(course1.metrics["blocking factor"]) and Course 2 has blocking factor $(course2.metrics["blocking factor"])")
        # since they have different blocking factors, investigate why and get a set of blocking factors
        unblocked_field_course_1 = Set(courses_to_course_names(blocking_factor_investigator(course1, curriculum1)))
        unblocked_field_course_2 = Set(courses_to_course_names(blocking_factor_investigator(course2, curriculum2)))
        # use setdiff to track which courses aren't in course 2's unblocked field and which aren't in course 1's unblocked field
        not_in_c2_unbl_field = setdiff(unblocked_field_course_1, unblocked_field_course_2)
        not_in_c1_unbl_field = setdiff(unblocked_field_course_2, unblocked_field_course_1)
        if (length(not_in_c2_unbl_field) != 0)
            # there are courses in c1's unblocked that aren't in course2s
            println("the following courses aren't in course 2's unblocked field:")
            for course in not_in_c2_unbl_field
                println("$(course)")
            end
        else
            println("every course in course 1's unblocked field is in course 2's unblocked field")
        end
        if (length(not_in_c1_unbl_field) != 0)
            # there are courses in c2's unblocked that aren't in course1s
            println("the following courses aren't in course 1's unblocked field:")
            for course in not_in_c1_unbl_field
                println("$(course)")
            end
        else
            println("every course in course 2's unblocked field is in course 1's unblocked field")
        end
    end
    # delay factor
    if (course1.metrics["delay factor"] == course2.metrics["delay factor"])
        if (verbose)
            println("✅Course 1 and Course 2 have the same delay factor: $(course1.metrics["delay factor"])")
        end
    else
        println("❌Course 1 has delay factor $(course1.metrics["delay factor"]) and Course 2 has delay factor $(course2.metrics["delay factor"])")
    end
    # requisites
    # collate all the prerequisite names from course 1
    course1_prereqs = Set()
    for (key, value) in course1.requisites
        # get the course name
        course_name = curriculum1.courses[key].name
        push!(course1_prereqs, course_name)
    end

    course2_prereqs = Set()
    for (key, value) in course2.requisites
        # get the course name
        course_name = curriculum2.courses[key].name
        push!(course2_prereqs, course_name)
    end

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


end

function curricular_diff(curriculum1::Curriculum, curriculum2::Curriculum, verbose::Bool=true)

    # do the basic comparisons like name, BA/BS etc
    # compare names
    if (curriculum1.name == curriculum2.name)
        if (verbose)
            println("✅Curriculum 1 and Curriculum 2 have the same name: $(curriculum1.name)")
        end
    else
        println("❌Curriculum 1 is named $(curriculum1.name) and Curriculum 2 is named $(curriculum2.name)")
    end

    # compare institution
    if (curriculum1.institution == curriculum2.institution)
        if (verbose)
            println("✅Curriculum 1 and Curriculum 2 have the same institution: $(curriculum1.institution)")
        end
    else
        println("❌Curriculum 1 has institution $(curriculum1.institution) and Curriculum 2 has institution $(curriculum2.institution)")
    end

    # compare degree_type
    if (curriculum1.degree_type == curriculum2.degree_type)
        if (verbose)
            println("✅Curriculum 1 and Curriculum 2 have the same degree type: $(curriculum1.degree_type)")
        end
    else
        println("❌Curriculum 1 has degree type $(curriculum1.degree_type) and Curriculum 2 has degree type $(curriculum2.degree_type)")
    end

    # compare system_type
    if (curriculum1.system_type == curriculum2.system_type)
        if (verbose)
            println("✅Curriculum 1 and Curriculum 2 have the same system type: $(curriculum1.system_type)")
        end
    else
        println("❌Curriculum 1 has system type $(curriculum1.system_type) and Curriculum 2 has system type $(curriculum2.system_type)")
    end

    # compare CIP
    if (curriculum1.CIP == curriculum2.CIP)
        if (verbose)
            println("✅Curriculum 1 and Curriculum 2 have the same CIP: $(curriculum1.CIP)")
        end
    else
        println("❌Curriculum 1 has CIP $(curriculum1.CIP) and Curriculum 2 has CIP $(curriculum2.CIP)")
    end

    # compare num_courses
    if (curriculum1.num_courses == curriculum2.num_courses)
        if (verbose)
            println("✅Curriculum 1 and 2 have the same number of courses: $(curriculum1.num_courses)")
        end
    else
        println("❌Curriculum 1 has number of courses $(curriculum1.num_courses) and Curriculum 2 has number of courses $(curriculum2.num_courses)")
    end

    # compare credit_hours
    if (curriculum1.credit_hours == curriculum2.credit_hours)
        if (verbose)
            println("✅Curriculum 1 and 2 have the same number of credit hours: $(curriculum1.credit_hours)")
        end
    else
        println("❌Curriculum 1 has number of credit hours $(curriculum1.credit_hours) and Curriculum 2 has number of credit hourse $(curriculum2.credit_hours)")
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
        # for each course in curriculum 1, try to find a similarly named course in curriculum 2
        for course in curriculum1.courses
            # this is the catch: MATH 20A and MATH 20A or 10A are not going to match
            matching_course = filter(x -> x.name == course.name, curriculum2.courses)
            if (length(matching_course) == 0)
                println("No matching course found for $(course.name)")
            elseif (length(matching_course) == 1)
                println("Match found for $(course.name)")
                course2 = matching_course[1]
                course_diff(course, course2, curriculum1, curriculum2, verbose)
            else
                println("Something weird here, we have more than one match")
            end
        end
    end
end