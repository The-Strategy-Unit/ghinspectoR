# Get a GitHub token for local development

Retrieves a GitHub Personal Access Token (PAT) for use outside of Posit
Connect, such as when running scripts or rendering reports interactively
on a local machine. The token is looked up from three sources in turn,
stopping at the first one found (even if this is out of date/incorrect):
passwords saved using the \`keyring\` package, a Git credential stored
using the \`gitcreds\` package (for example set up via the \`gh\` CLI or
\`usethis::create_github_token()\` or \`gitcreds::gitcreds_set()\`), and
finally an environment variable typically set in \`.Renviron\` either
globally \`usethis::edit_r_environ()\` or by project by adding the
argument \`scope = "project"\`.

## Usage

``` r
get_local_token(env_var = "GH_PAT")
```

## Arguments

- env_var:

  Character. The name of the keyring entry and/or environment variable
  holding the GitHub PAT. Defaults to \`"GH_PAT"\`.

## Value

A character string containing the GitHub PAT.

## Details

This function is intended for \*\*local use only\*\*. On Posit Connect,
use \[get_connect_app_token()\] (for non-interactive content such as
Quarto reports) or \[get_connect_user_token()\] (for Shiny apps using
per-user OAuth) instead. See \[get_token()\] for a wrapper that selects
the appropriate function automatically based on execution context.

Credentials are checked in the following order:

1\. \*\*\`keyring\`\*\* — a password explicitly stored under \`env_var\`
using \`keyring::key_set()\` package and function. This is the most
deliberate and most secure option but is not always available if used in
connecting to outside servers like Posit Connect from a local machine.
2. \*\*\`gitcreds\`\*\* — a credential already known to Git tooling,
typically discovered via the same OS credential store used by the
\`keyring\` package. This picks up a token if you have previously
authenticated \`git\` on the command line (CLI), run \`gh auth login\`,
or use the R package and function \`usethis::create_github_token()\`. 3.
\*\*Environment variable / \`.Renviron\`\*\* — a plain-text fallback.
This is the least secure of the three options, since the value is stored
unencrypted on disk. \*\*Take care that any file containing the token
(such as \`.Renviron\`) is never committed to version control or synced
via cloud storage (such as Google Drive, Dropbox).\*\* Ensure the
\`.Renviron\` file is included in the \`.gitignore\` file before using.

## See also

\[get_token()\], \[get_connect_app_token()\],
\[get_connect_user_token()\]

## Examples

``` r
if (FALSE) { # \dontrun{
# Looks up GH_PAT in keyring, then gitcreds, then Sys.getenv("GH_PAT")
token <- get_local_token()

# Ensure that either the GH_PAT is saved as MY_OTHER_GH_PAT or change the
# details below
token <- get_local_token("MY_OTHER_GH_PAT")
} # }
```
