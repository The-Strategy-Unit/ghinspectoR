# Get a GitHub token, selecting the source automatically

A convenience wrapper that selects an appropriate GitHub token depending
on where code is running. On Posit Connect, it returns an application
(content) credential via \[get_connect_app_token()\]. Outside of Posit
Connect, it returns a locally stored credential via
\[get_local_token()\].

## Usage

``` r
get_token(env_var = "GH_PAT")
```

## Arguments

- env_var:

  Character. The name of the keyring entry and/or environment variable
  to use when falling back to \[get_local_token()\]. Defaults to
  \`"GH_PAT"\`. Ignored when running on Posit Connect.

## Value

A character string containing a GitHub token.

## Details

This function is intended for \*\*non-interactive contexts\*\*, such as
Quarto reports, scripts, or scheduled jobs, where there is no individual
"viewer" to authenticate as. It detects whether it is running on Posit
Connect via the \`CONNECT_SERVER\` environment variable.

This function deliberately does \*\*not\*\* dispatch to
\[get_connect_user_token()\], since that function requires a Shiny
\`session\` object that only exists inside an interactive Shiny
application. Shiny apps requiring per-user GitHub authentication should
call \[get_connect_user_token()\] directly from the server function
rather than relying on this wrapper.

## See also

\[get_local_token()\], \[get_connect_app_token()\],
\[get_connect_user_token()\]

## Examples

``` r
if (FALSE) { # \dontrun{
# Works both locally and when deployed as a Quarto report on Posit Connect
token <- get_token()
repos <- get_repos(org = "my-org", token = token)
} # }
```
