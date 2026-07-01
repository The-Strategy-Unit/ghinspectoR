# Get a GitHub token via Posit Connect's application OAuth credentials

Retrieves a GitHub OAuth token tied to the deployed content itself (a
service-account-style "application" credential), rather than to an
individual viewer. This is the appropriate credential type for
non-interactive content such as Quarto reports and scheduled jobs
running on Posit Connect.

## Usage

``` r
get_connect_app_token()
```

## Value

A character string containing the OAuth access token.

## Details

This function calls \[connectapi::connect()\] and
\[connectapi::get_oauth_content_credentials()\] to obtain a token
associated with the content's configured GitHub OAuth integration on
Posit Connect.

\*\*This is not the same as a per-user credential.\*\* Because the token
is tied to the content rather than to a viewer, it is the same for every
execution of that content and is not appropriate for use cases requiring
per-user GitHub identity or permissions. For Shiny apps where each
viewer should authenticate with their own GitHub account, use
\[get_connect_user_token()\] instead.

This function will only succeed when run on Posit Connect with a GitHub
OAuth integration configured for the content. It will error if called
locally or if no such integration exists.

## See also

\[get_token()\], \[get_local_token()\], \[get_connect_user_token()\]

## Examples

``` r
if (FALSE) { # \dontrun{
# Within a Quarto report deployed to Posit Connect:
token <- get_connect_app_token()
repos <- get_repos(org = "my-org", token = token)
} # }
```
