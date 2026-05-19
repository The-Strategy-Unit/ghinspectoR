#' Retrieve organisation teams
#'
#' @description
#' Retrieves teams (grouped members) within a GitHub organisation.
#'
#' @param token A GitHub installation access token or personal access token.
#' Default uses `get_github_iat_pat()`
#' @param org GitHub organisation name.
#'
#' @examples
#' \dontrun{
#' get_teams(org = "my-org")
#' }
#'
#' @return list user objects returned by the GitHub API.
#'
#' @export
get_teams <- function(org, token = get_github_iat_pat()) {
  validate_org(org)

  gh_safe(
    "GET /orgs/{org}/teams",
    org = org,
    .limit = Inf,
    token = token
  )
}


#' Convert team list into a tidy data frame
#'
#' @description
#' Converts team information in list returned by [get_teams] into a tidy
#' data frame.
#'
#' @param team_list A list of team objects.
#'
#' @examples
#' \dontrun{
#' get_teams(org = "my-org") |> tidy_teams()
#' }
#'
#' @return data frame
#'
#' @export
tidy_teams <- function(team_list) {
  purrr::map_dfr(
    team_list,
    \(team) {
      tibble::tibble(
        team_name = purrr::pluck(team, "name", .default = NA_character_),
        team_slug = purrr::pluck(team, "slug", .default = NA_character_),
        description = purrr::pluck(
          team,
          "description",
          .default = NA_character_
        )
      )
    }
  )
}


#' Retrieve members of a team
#'
#' @description
#' Retrieves all members of a specific GitHub organisation team.
#'
#' @param org GitHub organisation name.
#' @param token A GitHub installation access token or personal access token.
#' Default uses `get_github_iat_pat()`
#' @param teams usually from [get_teams] and [tidy_teams] functions containing
#' `team_slug` column
#'
#' @examples
#' \dontrun{
#' teams <- get_teams(org = "my-org") |> tidy_teams()
#' get_team_members(org = "my-org", teams = teams)
#'
#' get_team_members(org = "my-org", teams = "my-team-name")
#' }
#'
#' @return A list of team member objects.
#'
#' @export
get_team_members <- function(teams, org, token = get_github_iat_pat()) {
  validate_org(org)

  team_slugs <- teams

  # If a tibble, extract the slug column
  if (is.data.frame(teams)) {
    team_slugs <- teams$team_slug
  }

  purrr::map(
    team_slugs,
    \(team_slug) gh_get_team_members(org, team_slug, "all", token)
  ) |>
    rlang::set_names(team_slugs)
}

#' Tidy team membership data returned from the GitHub API
#'
#' @description
#' Converts team information in list returned by [get_team_members] into a tidy
#' data frame.
#'
#' @param team_members_list A named list of raw team membership responses
#'
#' @return
#' A tibble with two columns:
#' \describe{
#'   \item{team_slug}{The team slug associated with each member.}
#'   \item{login}{The GitHub username of the team member.}
#' }
#'
#' @examples
#' \dontrun{
#' teams <- get_teams(org = "my-org") |> tidy_teams()
#' get_team_members(teams, org = "my-org") |> tidy_team_members(raw)
#' }
#'
#' @seealso
#' [gh_get_team_members(), get_team_members()]
#'
#' @export
tidy_team_members <- function(team_members_list) {
  purrr::imap_dfr(
    team_members_list,
    \(members, team_slug) {
      if (length(members) == 0) {
        tibble::tibble(team_slug = team_slug, login = NA_character_)
      } else {
        tibble::tibble(
          team_slug = rep(team_slug, length(members)),
          login = purrr::map_chr(members, "login")
        )
      }
    }
  )
}
