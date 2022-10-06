# include the output from somewhere. This is my case. Don't replicate
#include("./../../Basic CA Stats/Sean's Stats/ExploratoryCurricularAnalytics/Output.jl")
include("./Diff.jl")
using DataStructures, CurricularAnalytics, JSON

colleges = ["FI", "MU", "RE", "SI", "SN", "TH", "WA"]
#apparently there's no UNPSRE2017 plan, oh well
#exceptions = ["UNPSRE2017", "UNHARE2017", "PS30TH2016", "CH37FI2016", "UN27RE2017", "UNSSRE2016"]
exceptions = []

# "borrowed" from Utils.jl in Sean's fork of ExploratoryCA
function convert_to_curriculum(plan::DegreePlan)
    c = Curriculum(plan.name, [course for term in plan.terms for course in term.courses])
    if !isvalid_curriculum(c)
        error("$(plan.name) is not a valid curriculum")
    end
    c
end

#= This is the output.jl version but that has certain issues so we'll use read_csv
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
=#

# OK, so now you're here, holding a massive amount of data in memory like a champ
# Now loop through each non-empty plan and run the diffs 

#=results = Dict()
for major in keys(all_plans)
    results[major] = Dict()
    println(major)
    for college in keys(all_plans[major])
        results[major][college] = Dict()
        println(college)
        if (length(all_plans[major][college]) > 1)
            for year in keys(all_plans[major][college])
                println("$major, $college, $year")
                if !("$major$college$year" in exceptions || "$major$college$(year+1)" in exceptions)
                    if (year < last(collect(keys(all_plans[major][college]))))
                        results[major][college]["$year to $(year+1)"] = curricular_diff(all_plans[major][college][year], all_plans[major][college][year+1], false)
                    end
                end
            end
        end
    end
end
=#

# First, find all majors, i.e. all the folders in the output$year folders in ./files/massive
all_majors = []
items = [item for item in walkdir("./files/massive/")]
index = 2 # magic number
while index < length(items)
    global all_majors = union(all_majors, items[index][2])
    global index = index + length(items[index][2]) + 1
end
all_plans = Dict()
exceptions = []
for major in all_majors
    println(major)
    all_plans[major] = Dict()
    for college in colleges
        println(college)
        all_plans[major][college] = []
        for year in 2015:2022
            #=if (college == "SN" && year < 2020)
                continue
            end
            try
                all_plans[major][college][year] = read_csv("./files/massive/output$(year)/$(major)/$(college).csv")
                println(year)
            catch err
                if (isa(err, SystemError))
                    push!(exceptions, "$major$college$year")
                end
            end=#
            if (college == "SN" && year < 2020)
                continue
            end
            if isfile("./files/massive/output$(year)/$(major)/$(college).csv") &&
               isfile("./files/massive/output$(year+1)/$(major)/$(college).csv")

                push!(all_plans[major][college], year)
                println(year)
            else
                if year != 2022
                    push!(exceptions, "$(major)$(college)$(year)")
                end
            end
        end
    end
end

results = Dict()
for major in all_majors
    results[major] = Dict()
    println("***********************$major*************************")
    for (college, years) in all_plans[major]
        results[major][college] = Dict()
        for year in years
            dp1 = read_csv("./files/massive/output$(year)/$(major)/$(college).csv")
            dp2 = read_csv("./files/massive/output$(year+1)/$(major)/$(college).csv")
            dp1.curriculum.name = "$(major)$(college)$(year)"
            dp2.curriculum.name = "$(major)$(college)$(year+1)"
            results[major][college]["$year to $(year+1)"] = curricular_diff(dp1.curriculum, dp2.curriculum, true, true, "./files/redundant_names_tiny.csv")
        end
    end
end

open("./results.json", "w") do f
    JSON.print(f, results)
end

open("./results_pretty.json", "w") do f
    JSON.print(f, results, 4)
end