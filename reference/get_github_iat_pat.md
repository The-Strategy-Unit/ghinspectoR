# Generate a GitHub App installation access token

\`get_github_iat_pat()\` exchanges a GitHub App JSON Web Token (JWT) for
an installation access token. This token is required for making
authenticated requests on behalf of a GitHub App installation.

The function performs the standard GitHub App authentication flow:

1\. A JWT is created using \`get_github_jwt()\`. 2. The installation ID
is retrieved using \`get_github_app_installation_id()\`. 3. A POST
request is made to the GitHub API to obtain an installation access
token.

The returned token can be used as a bearer token for subsequent API
calls.

## Usage

``` r
get_github_iat_pat(
  jwt = get_github_jwt(),
  installation_id = get_github_app_installation_id(),
  github_api_ep = "https://api.github.com/"
)
```

## Arguments

- jwt:

  A GitHub App JSON Web Token. Defaults to the value returned by
  \`get_github_jwt()\`.

- installation_id:

  The GitHub App installation ID. Defaults to the value returned by
  \`get_github_app_installation_id()\`.

- github_api_ep:

  The GitHub API endpoint root. Defaults to
  \`"https://api.github.com/"\`.

## Value

A character string containing the installation access token.

## See also

\[get_github_jwt()\], \[get_github_app_installation_id()\]

## Examples

``` r
if (FALSE) { # \dontrun{
token <- get_github_iat_pat()
} # }
```
