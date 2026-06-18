# Convert repository list data into a tidy data frame

Converts the list returned by \[get_repos\] into a tidy data frame. Each
row represents one repository and includes its name, visibility, archive
status, issue count, URL, and creation timestamp.

## Usage

``` r
tidy_repos(result)
```

## Arguments

- result:

  A list of repository objects returned by \[get_repos\].

## Value

A data frame with the following columns: \* \`repo_name\`: the name of
the repository, \* \`is_private\`: whether the repository is private, \*
\`archived\`: whether the repository is archived, \*
\`open_issues_count\`: the number of open issues, \* \`repo_url\`: the
URL of the repository on GitHub, \* \`created_at\`: the timestamp when
the repository was created.

## Details

The function extracts selected fields from each repository object and
constructs a tidy data frame. This format is suitable for summarising
repository characteristics or joining with other repository-level data.

## See also

\* \[get_repos\] for retrieving the raw repository data
