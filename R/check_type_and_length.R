check_type_and_length <- function(...,
                                  call = rlang::caller_env(),
                                  env = rlang::caller_env()) {
  dots <- list(...)
  if (length(dots) == 0) {
    return(invisible(TRUE))
  }

  if (is.null(names(dots)) || any(names(dots) == "")) {
    rlang::abort(
      "All arguments to `check_type_and_length()` must be named.",
      class = "rsi_unnamed_check_args",
      call = call
    )
  }

  problem_args <- character()
  for (dot in names(dots)) {
    arg <- get(dot, envir = env)
    if (is.null(arg)) next

    arg_class <- class(arg)
    dot_class <- class(dots[[dot]])
    if (!any(arg_class %in% dot_class)) {
      if ("integer" %in% arg_class && "numeric" %in% dot_class) {
        next # Purposefully doing nothing -- rely on implicit conversion
      } else if ("integer" %in% dot_class && rlang::is_integerish(arg)) {
        next # Purposefully doing nothing -- rely on implicit conversion
      } else {
        problem_args <- c(
          problem_args,
          glue::glue("{dot} should be a {class(dots[[dot]])}, but is a {class(arg)}.")
        )
      }
    }
    if (length(dots[[dot]]) && length(arg) != length(dots[[dot]])) {
      problem_args <- c(
        problem_args,
        glue::glue("{dot} should be of length {length(dots[[dot]])}, but is length {length(arg)}.")
      )
    }
  }

  if (length(problem_args)) {
    names(problem_args) <- rep("*", length(problem_args))
    rlang::abort(
      c(
        "Some input arguments weren't the right class or length:",
        problem_args
      ),
      call = call,
      class = "rsi_incorrect_type_or_length"
    )
  }
  return(invisible(TRUE))
}
