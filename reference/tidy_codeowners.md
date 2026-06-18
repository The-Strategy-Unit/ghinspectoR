# Convert CODEOWNERS API responses into a tidy data frame

Converts the list returned by \[get_codeowners\] into a tidy data frame.

## Usage

``` r
tidy_codeowners(codeowner_list)
```

## Arguments

- codeowner_list:

  A named list returned by \[get_codeowners\].

## Value

A data frame with columns: \* \`repo_name\`: repository name,get\_ \*
\`has_codeowners\`: logical indicator, \* \`codeowners_path\`: the path
where the file was found, \* \`codeowners_text\`: decoded file contents.

## Details

When a CODEOWNERS file exists, the function decodes the base64-encoded
content and records the path where the file was found (as determined by
\[gh_get_file\]).

When no CODEOWNERS file exists, the function records: \*
\`has_codeowners = FALSE\` \* \`codeowners_path = NA\` \*
\`codeowners_text = NA\`

## Examples

``` r
if (FALSE) { # \dontrun{
my_repos <- get_repos("my-org") |> tidy_repos()
get_codeowners(org = "my-org", repos = my_repos) |> tidy_codeowners()
} # }
```
