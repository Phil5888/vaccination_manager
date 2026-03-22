# vaccination_manager

A new Flutter project.

Todo:
Delete User
Remove "Select user in user list"
Keep all header text left
Add to calendeart
check animations and unify them (no hard switches)

Okay now a larger refactoring to Improve UI consistency:

- Create a central theme. This way we can switch e. g. colors faster
- Create central styles for buttons / inputs etc. You can take the Vaccination screen as template. Here we have a highligthed button to add a vaccination and a not highligthed button for search
- Overwrite default styles and remove customization from current UI elements.
- Create styles for all elements were it makes sense
