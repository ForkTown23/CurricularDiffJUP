using CurricularAnalytics

function curricular_diff(curriculum1::Curriculum, curriculum2::Curriculum)

    # do the basic comparisons like name, BA/BS etc
    # compare names
    curriculum1.name == curriculum2.name ? println("Curriculum 1 and Curriculum 2 have the same name: $(curriculum1.name)") : println("Curriculum 1 is named $(curriculum1.name) and Curriculum 2 is named $(curriculum2.name)")
    # compare institution
    curriculum1.institution == curriculum2.institution ? println("Curriculum 1 and Curriculum 2 have the same institution: $(curriculum1.institution)") : println("Curriculum 1 has institution $(curriculum1.institution) and Curriculum 2 has institution $(curriculum2.institution)")
    # compare degree_type

    # compare system_type
    # compare CIP
    # compare num_courses
    # compare credit_hours
    # compare metrics

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