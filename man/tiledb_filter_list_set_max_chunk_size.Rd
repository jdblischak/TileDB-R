% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/FilterList.R
\name{set_max_chunk_size}
\alias{set_max_chunk_size}
\alias{set_max_chunk_size,tiledb_filter_list,numeric-method}
\alias{tiledb_filter_list_set_max_chunk_size}
\title{Set the filter_list's max_chunk_size}
\usage{
set_max_chunk_size(object, value)

\S4method{set_max_chunk_size}{tiledb_filter_list,numeric}(object, value)

tiledb_filter_list_set_max_chunk_size(object, value)
}
\arguments{
\item{object}{tiledb_filter_list}

\item{value}{A numeric value}
}
\description{
Set the filter_list's max_chunk_size
}
\examples{
\dontshow{
ctx <- tiledb_ctx(limitTileDBCores())
}
flt <- tiledb_filter("ZSTD")
tiledb_filter_set_option(flt, "COMPRESSION_LEVEL", 5)
filter_list <- tiledb_filter_list(c(flt))
set_max_chunk_size(filter_list, 10)
}
