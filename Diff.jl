using CurricularAnalytics

function curricular_diff(curriculum1::Curriculum, curriculum2::Curriculum)

    # do the basic comparisons like name, BA/BS etc
    # compare names
    curriculum1.name == curriculum2.name ? println("Curriculum 1 and Curriculum 2 have the same name: $(curriculum1.name)") : println("Curriculum 1 is named $(curriculum1.name) and Curriculum 2 is named $(curriculum2.name)")
    # compare institution
    curriculum1.institution == curriculum2.institution ? println("Curriculum 1 and Curriculum 2 have the same institution: $(curriculum1.institution)") : println("Curriculum 1 has institution $(curriculum1.institution) and Curriculum 2 has institution $(curriculum2.institution)")
    # compare degree_type
    curriculum1.degree_type == curriculum2.degree_type ? println("Curriculum 1 and Curriculum 2 have the same degree type: $(curriculum1.degree_type)") : println("Curriculum 1 has degree type $(curriculum1.degree_type) and Curriculum 2 has degree type $(curriculum2.degree_type)")
    # compare system_type
    curriculum1.system_type == curriculum2.system_type ? println("Curriculum 1 and Curriculum 2 have the same system type: $(curriculum1.system_type)") : println("Curriculum 1 has system type $(curriculum1.system_type) and Curriculum 2 has system type $(curriculum2.system_type)")
    # compare CIP
    curriculum1.CIP == curriculum2.CIP ? println("Curriculum 1 and Curriculum 2 have the same CIP: $(curriculum1.CIP)") : println("Curriculum 1 has CIP $(curriculum1.CIP) and Curriculum 2 has CIP $(curriculum2.CIP)")
    # compare num_courses
    curriculum1.num_courses == curriculum2.num_courses ? println("Curriculum 1 and 2 have the same number of courses: $(curriculum1.num_courses)") : println("Curriculum 1 has number of courses $(curriculum1.num_courses) and Curriculum 2 has number of courses $(curriculum2.num_courses)")
    # compare credit_hours
    curriculum1.credit_hours == curriculum2.credit_hours ? println("Curriculum 1 and 2 have the same number of credit hours: $(curriculum1.credit_hours)") : println("Curriculum 1 has number of credit hours $(curriculum1.credit_hours) and Curriculum 2 has number of credit hourse $(curriculum2.credit_hours)")
    # compare metrics

    try
        basic_metrics(curriculum1)
    catch
    end
    try
        basic_metrics(curriculum2)
    catch
    end
    # complexity and max complexity
    if (curriculum1.metrics["complexity"][1] == curriculum2.metrics["complexity"][1])
        println("Curriculum 1 and Curriculum 2 have the same total complexity: $(curriculum1.metrics["complexity"][1])")
    else
        println("Curriculum 1 has a total complexity score of $(curriculum1.metrics["complexity"][1]) and Curriculum2 has a total complexity score $(curriculum2.metrics["complexity"][1])")
    end
    if (curriculum1.metrics["max. complexity"] == curriculum2.metrics["max. complexity"])
        println("Curriculum 1 and Curriculum 2 have the same max complexity : $(curriculum1.metrics["max. complexity"])")
    else
        println("Curriculum 1 has a max complexity of $(curriculum1.metrics["max. complexity"]) and Curriculum 2 has a max complexity of $(curriculum2.metrics["max. complexity"])")
    end
    # centrality and max centrality
    if (curriculum1.metrics["centrality"][1] == curriculum2.metrics["centrality"][1])
        println("Curriculum 1 and Curriculum 2 have the same total centrality: $(curriculum1.metrics["centrality"][1])")
    else
        println("Curriculum 1 has a total centrality score of $(curriculum1.metrics["centrality"][1]) and Curriculum2 has a total centrality score $(curriculum2.metrics["centrality"][1])")
    end
    if (curriculum1.metrics["max. centrality"] == curriculum2.metrics["max. centrality"])
        println("Curriculum 1 and Curriculum 2 have the same max centrality : $(curriculum1.metrics["max. centrality"])")
    else
        println("Curriculum 1 has a max centrality of $(curriculum1.metrics["max. centrality"]) and Curriculum 2 has a max centrality of $(curriculum2.metrics["max. centrality"])")
    end
    # blocking factor and max blocking factor
    if (curriculum1.metrics["blocking factor"][1] == curriculum2.metrics["blocking factor"][1])
        println("Curriculum 1 and Curriculum 2 have the same total blocking factor: $(curriculum1.metrics["blocking factor"][1])")
    else
        println("Curriculum 1 has a total blocking factor score of $(curriculum1.metrics["blocking factor"][1]) and Curriculum2 has a total blocking factor score $(curriculum2.metrics["blocking factor"][1])")
    end
    if (curriculum1.metrics["max. blocking factor"] == curriculum2.metrics["max. blocking factor"])
        println("Curriculum 1 and Curriculum 2 have the same max blocking factor : $(curriculum1.metrics["max. blocking factor"])")
    else
        println("Curriculum 1 has a max blocking factor of $(curriculum1.metrics["max. blocking factor"]) and Curriculum 2 has a max blocking factor of $(curriculum2.metrics["max. blocking factor"])")
    end
    # delay factor and max delay factor
    if (curriculum1.metrics["delay factor"][1] == curriculum2.metrics["delay factor"][1])
        println("Curriculum 1 and Curriculum 2 have the same total delay factor: $(curriculum1.metrics["delay factor"][1])")
    else
        println("Curriculum 1 has a total delay factor score of $(curriculum1.metrics["delay factor"][1]) and Curriculum2 has a total delay factor score $(curriculum2.metrics["delay factor"][1])")
    end
    if (curriculum1.metrics["max. delay factor"] == curriculum2.metrics["max. delay factor"])
        println("Curriculum 1 and Curriculum 2 have the same max delay factor : $(curriculum1.metrics["max. delay factor"])")
    else
        println("Curriculum 1 has a max delay factor of $(curriculum1.metrics["max. delay factor"]) and Curriculum 2 has a max delay factor of $(curriculum2.metrics["max. delay factor"])")
    end

    # for each course in curriculum 1, try to find a similarly named course in curriculum 2
    for course in curriculum1.courses
        matching_course = filter(x -> x.name == course.name, curriculum2.courses)
        if (length(matching_course) == 0)
            println("No matching course found for $(course.name)")
        else
            println("Match found for $(course.name)")
        end
    end
end