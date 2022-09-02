Todo:
- [x] Verbose print of two curricula
- [x] Verbose option
- [ ] Explain the differences in complexity and centrality (and thereby blocking and delay factors)
- [x] Blocking factor investigative function.
- [x] Delay factor investigative function.
- [ ] Centrality investigative function.
- [ ] Prettier output (MUCH PRETTIER)
- [ ] Consider removing redundant explanations (or mushing them together) like blocking factor of course A changing because its not a prereq of course B and then saying Course A is not a prereq of Course B. Probably mush them together
- [ ] Consider using levels of verbosity.
- [ ] Running tally of complexity score differences (presumably *from* curriculum 1 *to* curriculum 2)
- [ ] use fieldnames instead of naming each field manually.
- [ ] expand to degree plans
- [x] check if co-reqs matters in blocking factor investigator fn. THEY DO!
- [ ] consider refactoring blocking_factor_investigator into being recursive

Today:
- [ ] Add the case where a prereq set hasnt changed but a course has disappeared from the u-field because it is reached through a course that *has* changed its prereqs