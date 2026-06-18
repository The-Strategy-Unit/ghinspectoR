# Tidy a single file retrieved from a GitHub repository

Converts the raw output from \`get_file()\` into a tidy tibble. It
extracts metadata such as file name, path, size, and SHA, and decodes
the base64‑encoded file content.

## Usage

``` r
tidy_single_file(file_raw, repo_name)
```

## Arguments

- file_raw:

  A raw file object returned by \`get_file()\`.

- repo_name:

  The name of the repository the file was retrieved from.

## Value

A tibble containing metadata and decoded content for the file.

## See also

\[tidy_files()\], \[get_file()\], \[get_files()\]

## Examples

``` r
if (FALSE) { # \dontrun{
tidy_single_file(file_raw, repo_name = "my-repo")
} # }
```
