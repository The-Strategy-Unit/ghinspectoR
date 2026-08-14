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

#' Retrieve member details
#'
#' @description
#' Retrieves details for multiple members of a GitHub organisation.
#'
#' @param usernames Character vector of GitHub usernames (e.g. from
#'   `tidy_members()$login`).
#' @param token A GitHub installation access token or personal access token.
#'   Default uses `get_token()`.
#'
#' @return A list of user objects returned by the GitHub API, one per
#'   username.
#' @seealso [tidy_member_details()]
#'
#' @examples
#' \dontrun{
#' members <- get_members(org = "my-org") |>
#'   tidy_members()
#'
#' get_member_details(usernames = members$login)
#' }
#'
#' @export
get_member_details <- function(
  usernames,
  token = get_token()
) {
  purrr::map(
    usernames,
    gh_get_member_details,
    token = token
  )
}

#' Tidy member details
#'
#' @description
#' Converts a list of raw GitHub user objects (as returned by
#' [get_member_details()]) into a tidy tibble.
#'
#' @param members A list of user objects, as returned by
#'   [get_member_details()].
#'
#' @returns A tibble with one row per member and columns `login`, `name`,
#'   `company`, `location`, `email`, and `bio`. Members that failed to
#'   fetch (`NULL`) are dropped.
#' @seealso [get_member_details()]
#'
#' @examples
#' \dontrun{
#' members <- get_members(org = "my-org") |>
#'   tidy_members()
#'
#' get_member_details(usernames = members$login) |>
#'   tidy_member_details()
#' }
#'
#' @export
tidy_member_details <- function(members) {
  members <- purrr::compact(members)

  tibble::tibble(
    login = purrr::map_chr(members, "login", .default = NA_character_),
    name = purrr::map_chr(members, "name", .default = NA_character_),
    company = purrr::map_chr(members, "company", .default = NA_character_),
    location = purrr::map_chr(members, "location", .default = NA_character_),
    email = purrr::map_chr(members, "email", .default = NA_character_),
    bio = purrr::map_chr(members, "bio", .default = NA_character_)
  )
}
