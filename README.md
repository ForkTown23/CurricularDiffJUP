Todo:
- [x] Verbose print of two curricula
- [x] Verbose option
- [ ] Explain the differences in complexity and centrality (and thereby blocking and delay factors)
- [x] Blocking factor investigative function.
- [x] Delay factor investigative function.
- [x] Centrality investigative function.
- [ ] Prettier output (MUCH PRETTIER)
- [ ] Consider removing redundant explanations (or mushing them together) like blocking factor of course A changing because its not a prereq of course B and then saying Course A is not a prereq of Course B. Probably mush them together
- [ ] Consider using levels of verbosity.
- [x] Running tally of complexity score differences (presumably *from* curriculum 1 *to* curriculum 2)
- [x] use fieldnames instead of naming each field manually.
- [ ] expand to degree plans
- [x] check if co-reqs matters in blocking factor investigator fn. THEY DO!
- [ ] consider refactoring blocking_factor_investigator into being recursive
- [ ] consider the cases where changes balance out (is it even important to us?)
- [ ] consider swapping over to a return-based system rather than having each function print stuff

9/2/22:
- [x] Add the case where a prereq set hasnt changed but a course has disappeared from the u-field because it is reached through a course that *has* changed its prereqs
- [x] Change course_diff to use field names
- [x] Running Tally of Score differences, from curr1 to curr2

9/6/22:
- [x] Centrality investigative function
- [x] Consider a refactor to use less course names and more courses to avoid converting back and forth
    It's not yet super feasible until I know more about the set diff thing. If i don't convert to course names, running set diff on sets of courses is going to turn up tons of differences because the course objects themselves are not the same.
- [x] Swap to return based system of dicts and arrays
- [x] Delete all the previous prints
- [ ] New pretty print
- [ ] New to-JSON print
- [ ] 
