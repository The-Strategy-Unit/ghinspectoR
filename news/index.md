# Changelog

## ghinspectoR 0.0.0.9000

Functions created with Copilot and Claude AI assistance to access the
GitHub API.

Includes Authentication functions in order connect locally to GitHub,
locally to publish on Posit Connect and from Posit Connect to GitHub
(subset again for Shiny interactive and Quarto static reports).

Where functions are looped across GitHub items like repositories these
are split into two functions with a single request from a function that
is prefixed with `gh_` and is then used within a higher function
prefixed with `get_`.

Functions pull data as lists using the `get_` functions can then be
converted to tibbles and columns specified using corresponding `tidy_`
functions.

This package relies upon `renv` to manage the R package environment to
support the use within the Posit Connect environment.
