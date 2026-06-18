# Convert raw issue data into a tidy data frame

\`tidy_issues()\` converts the list returned by \[get_issues()\] into a
tidy data frame. Each row represents one issue within one repository and
includes the issue number, title, and associated labels.

This function is intentionally general and does not filter for specific
labels. Filtering (for example, identifying tech debt issues) should be
done in downstream analysis.

## Usage

``` r
tidy_issues(issue_list)
```

## Arguments

- issue_list:

  A named list of issue objects returned by \[get_issues()\].

## Value

A data frame with the following columns: \* \`repo_name\`: the name of
the repository, \* \`issue_number\`: the issue number, \*
\`issue_title\`: the issue title, \* \`labels\`: a comma-separated
string of all labels applied to the issue.

## Details

The function extracts the issue number, title, and labels from each
issue object. Labels are returned as a comma-separated string. Missing
or empty issue lists are handled safely, and missing values are recorded
as \`NA\`.

## See also

\* \[get_issues()\] for retrieving raw issue data

## Examples

``` r
if (FALSE) { # \dontrun{
issues <- get_issues(
  repos = c("repo1", "repo2"),
  org = "my-org"
)

tidy_issues(issues)
} # }
```
