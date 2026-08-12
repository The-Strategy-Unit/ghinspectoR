get_projects <- function(
  org,
  token = get_token()
) {
  validate_org(org)

  gh::gh(
    "GET /orgs/{org}/projectsV2",
    org = "The-Strategy-Unit",
    .token = token,
    progress = TRUE
  )
}

tidy_projects <- function(result) {
  pojects <- purrr::pluck(
    result,
    "data",
    "organization",
    "projectsV2",
    "nodes",
    .default = list()
  )

  purrr::map_dfr(
    projects,
    \(x) {
      tibble::tibble(
        project_number = purrr::pluck(
          x,
          "number",
          .default = NA_integer_
        ),
        project_title = purrr::pluck(
          x,
          "title",
          .default = NA_character_
        ),
        project_id = purrr::pluck(
          x,
          "id",
          .default = NA_character_
        )
      )
    }
  )
}

get_project_details <- function(
  org,
  token = get_token()
) {
  validate_org(org)

  project_numbers <-
    get_projects(
      org = org,
      token = token
    ) |>
    tidy_projects() |>
    dplyr::pull(project_number)

  purrr::map(
    project_numbers,
    \(project_number) {
      gh_get_project_details(
        org = org,
        project_number = project_number,
        token = token
      )
    }
  ) |>
    purrr::set_names(
      as.character(project_numbers)
    )
}


tidy_project_details <- function(project_details) {
  purrr::imap_dfr(
    project_details,
    \(project, project_number) {
      items <-
        project$data$organization$projectV2$items$nodes

      purrr::map_dfr(
        items,
        \(item) {
          issue_number <- purrr::pluck(
            item,
            "content",
            "number",
            .default = NA_integer_
          )

          issue_title <- purrr::pluck(
            item,
            "content",
            "title",
            .default = NA_character_
          )

          repo_name <- purrr::pluck(
            item,
            "content",
            "repository",
            "name",
            .default = NA_character_
          )

          assignees <- paste(
            purrr::map_chr(
              purrr::pluck(
                item,
                "content",
                "assignees",
                "nodes",
                .default = list()
              ),
              "login",
              .default = NA_character_
            ),
            collapse = ", "
          )

          labels <- paste(
            purrr::map_chr(
              purrr::pluck(
                item,
                "content",
                "labels",
                "nodes",
                .default = list()
              ),
              "name",
              .default = NA_character_
            ),
            collapse = ", "
          )

          state <- purrr::pluck(
            item,
            "content",
            "state",
            .default = NA_character_
          )

          purrr::map_dfr(
            item$fieldValues$nodes,
            \(field) {
              value <- dplyr::coalesce(
                purrr::pluck(
                  field,
                  "name",
                  .default = NA_character_
                ),
                purrr::pluck(
                  field,
                  "text",
                  .default = NA_character_
                ),
                as.character(
                  purrr::pluck(
                    field,
                    "number",
                    .default = NA_real_
                  )
                ),
                purrr::pluck(
                  field,
                  "date",
                  .default = NA_character_
                )
              )

              tibble::tibble(
                project_number = as.integer(project_number),

                issue_number = issue_number,
                issue_title = issue_title,

                repo_name = repo_name,

                assignees = assignees,
                labels = labels,

                state = state,

                field_name = purrr::pluck(
                  field,
                  "field",
                  "name",
                  .default = NA_character_
                ),

                field_value = value,

                field_type = purrr::pluck(
                  field,
                  "__typename",
                  .default = NA_character_
                )
              )
            }
          ) |>
            dplyr::filter(
              !is.na(field_name),
              field_name != ""
            )
        }
      )
    }
  )
}
