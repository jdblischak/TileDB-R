% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Dim.R
\name{domain,tiledb_dim-method}
\alias{domain,tiledb_dim-method}
\title{Return the \code{tiledb_dim} domain}
\usage{
\S4method{domain}{tiledb_dim}(object)
}
\arguments{
\item{object}{A \code{tiledb_dim} object}
}
\value{
a vector of (lb, ub) inclusive domain of the dimension
}
\description{
Return the \code{tiledb_dim} domain
}
\examples{
\dontshow{
ctx <- tiledb_ctx(limitTileDBCores())
}
d1 <- tiledb_dim("d1", domain = c(5L, 10L))
domain(d1)

}
