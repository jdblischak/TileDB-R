% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ArraySchema.R
\name{describe}
\alias{describe}
\title{Describe a TileDB array schema via code to create it}
\usage{
describe(arr)
}
\arguments{
\item{arr}{A TileDB Array object}
}
\value{
Nothing is returned as the function is invoked for the side effect
of printing the schema via a sequence of R instructions to re-create it.
}
\description{
Note that this function is an unexported internal function that can be called
using the colons as in \code{tiledb:::describe(arr)}.
}
