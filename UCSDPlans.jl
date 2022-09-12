# include the output from somewhere. This is my case. Don't replicate
include("./../../Basic CA Stats/Sean's Stats/ExploratoryCurricularAnalytics/Output.jl")
include("./Diff.jl")
using DataStructures
current_year = 2022

# "borrowed" from Utils.jl in Sean's fork of ExploratoryCA
function convert_to_curriculum(plan::DegreePlan)
    c = Curriculum(plan.name, [course for term in plan.terms for course in term.courses])
    if !isvalid_curriculum(c)
        error("$(plan.name) is not a valid curriculum")
    end
    c
end

all_plans = Dict()
# First, reformat the Output from year -> major -> college into major -> college -> year
# Get all the possible majors
all_majors = keys(Output.plans[2015])
for year in 2016:2050
    if year ∉ keys(Output.plans)
        break
    end
    global all_majors = union(all_majors, keys(Output.plans[year]))
end
for major in all_majors
    all_plans[major] = Dict()
    for college in Output.colleges
        all_plans[major][college] = OrderedDict()
    end
end


for year in 2015:2050
    if year ∉ keys(Output.plans)
        break
    end
    for major in sort(collect(keys(Output.plans[year])))
        degree_plans = Output.output(year, major)

        for college in Output.colleges
            # Ignoring Seventh before 2020 because its plans were scuffed (and it
            # didn't exist)
            if college ∉ keys(degree_plans) || college == "SN" && year < 2020
                continue
            end

            plan = degree_plans[college]
            curriculum = convert_to_curriculum(plan)
            all_plans[major][college][year] = curriculum
        end
    end
end

# OK, so now you're here, holding a massive amount of data in memory like a champ
# Now loop through each non-empty plan and run the diffs 

results = Dict()
for major in keys(all_plans)
    results[major] = Dict()
    println(major)
    for college in keys(all_plans[major])
        results[major][college] = Dict()
        println(college)
        if (length(all_plans[major][college]) > 1)
            for year in keys(all_plans[major][college])
                println("$major, $college, $year")
                if (year < last(collect(keys(all_plans[major][college]))))
                    results[major][college]["$year to $(year+1)"] = curricular_diff(all_plans[major][college][year], all_plans[major][college][year+1], false)
                end
            end
        end
    end
end
