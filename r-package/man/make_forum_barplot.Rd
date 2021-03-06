% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/forum_server.R
\name{make_forum_barplot}
\alias{make_forum_barplot}
\title{Make the main barplot for displaying the forum data.}
\usage{
make_forum_barplot(forum_data, xvar_string, plot_variable, fill_value,
  axis_limit, category, ylabel, breakdown)
}
\arguments{
\item{forum_data}{The forum data for the main barplot.}

\item{xvar_string}{A string that matches the function to call for the x value
of aes_string().}

\item{plot_variable}{One of (default) \code{posts}, \code{authors}, or 
\code{views}.}

\item{fill_value}{A hex value representing the color for the bar fill.}

\item{axis_limit}{The maximum axis limit for the horizontal axis in the main 
barplot.}

\item{category}{The selected category.}

\item{ylabel}{The label of the y-axis in the main barplot.}

\item{breakdown}{One of \code{TRUE} or \code{FALSE}; determines whether the 
post types breakdown is shown.}
}
\value{
\code{forum_barplot} A ggplot2 object to be rendered as the main 
  forum barplot.
}
\description{
Make the main barplot for displaying the forum data.
}
\examples{
make_forum_barplot(
  forum_data, 
  xvar_string = "fct_reorder(discussion_category, 
                             course_order, 
                             .desc = TRUE)", 
  plot_variable = "authors", 
  fill_value = "red", 
  axis_limit = 100, 
  category = "All", 
  ylabel = "Category", 
  breakdown = FALSE
)
}
