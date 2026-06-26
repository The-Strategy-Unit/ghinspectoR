#' Retrieve organisation members
#'
#' @description
#' Retrieves all members of a GitHub organisation.
#'
#' @param org GitHub organisation name.
#' @param token A GitHub installation access token or personal access token.
#' Default uses `get_token()`
#'
#' @return list user objects returned by the GitHub API.
#' @seealso [tidy_members()]
#'
#' @examples
#' \dontrun{
#' get_members(org = "my-org")
#' }
#'
#' @export
get_members <- function(
  org,
  token = get_token(),
  limit = Inf
) {
  validate_org(org)

  gh::gh(
    "GET /orgs/{org}/members",
    org = org,
    .limit = limit,
    .token = token
  )
}

#' Convert organisation member list into a tidy data frame
#'
#' @description
#' Converts the list returned by [get_members] into a tidy data frame.
#'
#' @param list A list of user objects returned by [get_members]
#'
#' @return data frame
#'
#' @examples
#' \dontrun{
#' get_members(org = "my-org") |> tidy_members()
#' }
#'
#' @export
tidy_members <- function(list) {
  tibble::tibble(
    login = purrr::map_chr(list, "login", .default = NA_character_),
    type = "member"
  ) |>
    dplyr::mutate(login = tolower(login))
}

#' Retrieve organisation owners
#'
#' @description
#' Retrieves users with the `admin` role (organisation owners).
#'
#' @param org GitHub organisation name.
#' @param token A GitHub installation access token or personal access token.
#' Default uses `get_token()`
#'
#' @return list user objects returned by the GitHub API.
#'
#' @examples
#' \dontrun{
#' get_owners(org = "my-org")
#' }
#'
#' @export
get_owners <- function(
  org,
  token = get_token()
) {
  validate_org(org)

  gh::gh(
    "GET /orgs/{org}/members",
    org = org,
    role = "admin",
    .limit = Inf,
    .token = token
  )
}

#' Convert organisation owner list into a tidy data frame
#'
#' @description
#' Converts the list returned by [get_owners] into a tidy data frame.
#'
#' @param list A list of user objects
#'
#' @return tibble
#'
#' @examples
#' \dontrun{
#' get_owners(org = "my-org") |> tidy_owners()
#' }
#'
#' @export
tidy_owners <- function(list) {
  tibble::tibble(
    login = purrr::map_chr(list, "login", .default = NA_character_),
    type = "owner"
  ) |>
    dplyr::mutate(login = tolower(login))
}


#' Retrieve outside collaborators
#'
#' @description
#' Retrieves outside collaborators for a GitHub organisation. Outside
#' collaborators have access to specific repositories but are not organisation
#' members.
#'
#' @param org GitHub organisation name.
#' @param token A GitHub installation access token or personal access token.
#' Default uses `get_token()`
#'
#' @return list user objects returned by the GitHub API.
#'
#' @examples
#' \dontrun{
#' get_outside_collaborators(org = "my-org")
#' }
#'
#' @export
get_outside_collaborators <- function(
  org,
  token = get_token()
) {
  validate_org(org)

  gh::gh(
    "GET /orgs/{org}/outside_collaborators",
    org = org,
    .limit = Inf,
    .token = token
  )
}

#' Convert list outside collaborator data into a tidy data frame
#'
#' @description
#' Converts the list returned by [get_outside_collaborators]
#' into a tidy data frame.
#'
#' Outside collaborators are users who have access to specific repositories but
#' are not members of the organisation.
#'
#' @param list A list of user objects returned by [get_outside_collaborators]
#'
#' @return tibble
#'
#' @examples
#' \dontrun{
#' get_outside_collaborators(org = "my-org") |>
#' tidy_outside_collaborators()
#' }
#'
#' @export
tidy_outside_collaborators <- function(list) {
  tibble::tibble(
    login = purrr::map_chr(list, "login", .default = NA_character_),
    type = "outside"
  ) |>
    dplyr::mutate(login = tolower(login))
}

#' Details for members with GitHub profile information and members of organisation
#'
#' @description
#' Adds additional profile information (such as a user's
#' display name, company, and location) to a data frame created by
#' [tidy_members], [tidy_owners] or [tidy_outside_collaborators].
#'
#' The GitHub organisation endpoints do not return profile fields such as
#' `name`, so this function retrieves them by calling the GitHub user profile
#' endpoint (`GET /users/\{username\}`) for each login.
#'
#' @param people A tibble containing at least a `login` column
#' @param token A GitHub installation access token or personal access token.
#' Default uses `get_token()`
#'
#' @details
#' GitHub's organisation-level APIs return only minimal user information.
#' To obtain profile data, this function performs an additional API
#' request for each user via the `/users/\{username\}` endpoint. The returned
#' fields are merged back into the input data frame
#'
#' The following fields are added:
#' * `name` — the user's display name,
#' * `company` — the user's listed organisation,
#' * `location` — the user's location.
#'
#' Missing fields are recorded as `NA`.
#'
#' @return tibble containing the original columns plus additional profile fields.
#'
#' @seealso
#' * [combine_org_people()]
#' * [tidy_members()]
#' * [tidy_owners()]
#' * [tidy_outside_collaborators()]
#'
#' @examples
#' \dontrun{
#' members <- get_members(org) |> tidy_members() |> add_member_details()
#' collaborators <- get_outside_collaborators(org) |>
#' tidy_outside_collaborators() |>
#'   add_member_details()
#' owners <- get_owners(org) |> tidy_owners() |> add_member_details()
#'
#' }
#'
#' @export
add_member_details <- function(
  members,
  token = get_token()
) {
  profiles <- purrr::map(
    members$login,
    \(u) {
      gh::gh(
        "GET /users/{username}",
        username = u,
        .token = get_token()
      )
    }
  )

  members$name <- purrr::map_chr(profiles, "name", .default = NA_character_)
  members$company <- purrr::map_chr(
    profiles,
    "company",
    .default = NA_character_
  )
  members$location <- purrr::map_chr(
    profiles,
    "location",
    .default = NA_character_
  )

  members
}
