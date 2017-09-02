# A stat_summary with a geom_lineribbon
#
# Author: mjskay
###############################################################################


# Names that should be suppressed from global variable check by codetools
# Names used broadly should be put in _global_variables.R
globalVariables(c("...prob.."))


#' Multiple probability interval stats
#'
#' A variants of a \code{\link{stat_summary}} and a \code{\link{geom_lineribbon}}
#'
#' @param mapping The aesthetic mapping, usually constructed with
#' \code{\link{aes}} or \code{\link{aes_string}}. Only needs to be set at the
#' layer level if you are overriding the plot defaults.
#' @param data A layer specific dataset - only needed if you want to override
#' the plot defaults.
#' @param geom Use to override the default connection between
#' \code{geom_lineribbon} and \code{stat_lineribbon}.
#' @param position The position adjustment to use for overlapping points on this layer.
#' @param ...  Other arguments passed to \code{\link{layer}}. They may also be parameters to the paired geom.
#' @param fun.data A function that is given a vector and should
#'   return a data frame with variables \code{y}, \code{ymin} and \code{ymax}. See the \code{point_interval} family of functions.
#' @param point.interval Alias for \code{fun.data}
#' @param .prob The \code{.prob} argument passed to \code{fun.data}.
#' @param fun.args Other optional arguments passed to \code{fun.data}.
#' @param na.rm	If \code{FALSE}, the default, missing values are removed with a warning. If \code{TRUE}, missing
#' values are silently removed.
#' @param show.legend Should this layer be included in the legends? \code{NA}, the default, includes if any aesthetics
#' are mapped. \code{FALSE} never includes, and \code{TRUE} always includes.
#' @param inherit.aes If \code{FALSE}, overrides the default aesthetics, rather than combining with them. This is
#' most useful for helper functions that define both data and aesthetics and shouldn't inherit behaviour from the
#' default plot specification, e.g. borders.
#' @seealso \code{\link{geom_lineribbon}}
#' @examples
#'
#' library(dplyr)
#' library(ggplot2)
#'
#' data_frame(x = 1:10) %>%
#'   group_by_all() %>%
#'   do(data_frame(y = rnorm(100, .$x))) %>%
#'   ggplot(aes(x = x, y = y)) +
#'   stat_lineribbon() +
#'   scale_fill_brewer()
#'
#' @export
#' @export
stat_lineribbon <- function(mapping = NULL, data = NULL,
  geom = "lineribbon", position = "identity",
  ...,
  point.interval = median_qi,
  fun.data = point.interval,
  .prob = c(.5, .8, .95),
  fun.args = list(),
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE
) {
  # Probs are drawn on top of each other in order by geom_lineribbon, so we have to sort in decreasing order
  # to make sure the largest interval is not drawn last (over-writing all other intervals)
  .prob %<>% sort()

  l = layer(
    data = data,
    mapping = mapping,
    #we can re-use StatPointinterval internally because it does exactly the same thing
    #we would have done for a StatLineribbon
    stat = StatPointinterval,
    geom = geom,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      fun.data = fun.data,
      .prob = .prob,
      fun.args = fun.args,
      na.rm = na.rm,
      ...
    )
  )

  #provide some default computed aesthetics
  default_computed_aesthetics = aes(
    fill = forcats::fct_rev(ordered(...prob..)),  # nolint
    group = forcats::fct_rev(ordered(...prob..))  # nolint
  )

  compute_aesthetics = l$compute_aesthetics
  l$compute_aesthetics = function(self, data, plot) {
    apply_default_computed_aesthetics(self, plot, default_computed_aesthetics)
    compute_aesthetics(data, plot)
  }

  map_statistic = l$map_statistic
  l$map_statistic = function(self, data, plot) {
    apply_default_computed_aesthetics(self, plot, default_computed_aesthetics)
    map_statistic(data, plot)
  }

  l
}