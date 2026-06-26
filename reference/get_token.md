# Retrieve a GitHub personal access token

Retrieves a GitHub personal access token (PAT) from one of several
sources, depending on the environment in which the code is running.
Sources are tried in the following order:

1\. \*\*Posit Connect\*\* — if the \`CONNECT_SERVER\` environment
variable is set, OAuth content credentials are retrieved via
\`connectapi\`. 2. \*\*Keyring\*\* — if a secret matching \`env_var\`
exists in the system keyring, it is returned. This is the preferred
local approach. 3. \*\*Environment variable\*\* — if \`env_var\` is set
in the global or project-level \`.Renviron\`, that value is returned.

If none of these sources yields a token, the function stops with a
message guiding the user to set credentials via \`keyring::key_set()\`
or \`.Renviron\`.

## Usage

``` r
get_token(env_var = "GH_PAT")
```

## Arguments

- env_var:

  A string giving the name of the credential to look up in the keyring
  and environment. Defaults to \`"GH_PAT"\`. Override this if your
  project uses a different credential name.

## Value

A string containing the GitHub PAT, or a Posit Connect OAuth credentials
object when running on Connect.

## See also

\[keyring::key_set()\] to store credentials in the keyring,
\[connectapi::get_oauth_content_credentials()\] for Posit Connect
authentication.

## Examples

``` r
if (FALSE) { # \dontrun{
# Use the default credential name
token <- get_token()

# Use a project-specific credential name
token <- get_token(env_var = "GH_PAT_MYPROJECT")
} # }
```
