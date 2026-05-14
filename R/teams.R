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
  gh_get_teams(org, token)
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
#' }
#'
#' @return list user objects returned by the GitHub API.
#'
#' @export
get_team_members <- function(
  org,
  teams,
  token = get_github_iat_pat()
) {
  slugs <- teams$team_slug

  purrr::map(
    slugs,
    \(slug) get_members(org = org)
  ) |>
    purrr::set_names(slugs)
}


#' Convert team members list into a tidy data frame
#'
#' @description
#' Converts team members information in list returned by [get_team_members]
#' into a tidy data frame.
#'
#' @param team_members_list A list of team members objects.
#'
#' @returns data frame
#' @export
#'
#' @examples
#' \dontrun{
#' teams <- get_teams(org = "my-org") |> tidy_teams()
#' get_team_members(org = "my-org", teams = teams) |> tidy_team_members()
#' }
tidy_team_members <- function(team_members_list) {
  get
  purrr::imap_dfr(
    team_members_list,
    \(members, team_slug) {
      if (is.null(members) || length(members) == 0) {
        return(tibble::tibble(
          team_slug = team_slug,
          login = NA_character_
        ))
      }

      tibble::tibble(
        team_slug = team_slug,
        login = purrr::map_chr(
          members,
          purrr::pluck,
          "login",
          .default = NA_character_
        )
      )
    }
  )
}
