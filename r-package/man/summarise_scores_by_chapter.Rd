% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/problem_module.R
\name{summarise_scores_by_chapter}
\alias{summarise_scores_by_chapter}
\title{Summarise scores by chapter}
\usage{
summarise_scores_by_chapter(summarised_scores, lookup_table)
}
\arguments{
\item{summarised_scores}{the result of `get_mean_scores_filterable`}

\item{lookup_table}{The result of `create_question_lookup_from_json`}
}
\value{
A dataframe where each row is a chapter that contains the average
  score on that chapter
}
\description{
Calculates the average score on problems for each of the chapters based.
}
