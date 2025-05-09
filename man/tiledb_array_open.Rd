% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Array.R
\name{tiledb_array_open}
\alias{tiledb_array_open}
\title{Open a TileDB Array}
\usage{
tiledb_array_open(
  arr,
  type = if (tiledb_version(TRUE) >= "2.12.0") {
     c("READ", "WRITE", "DELETE",
    "MODIFY_EXCLUSIVE")
 } else {
     c("READ", "WRITE")
 }
)
}
\arguments{
\item{arr}{A TileDB Array object as for example returned by \code{tiledb_array()}}

\item{type}{A character value that must be either \sQuote{READ}, \sQuote{WRITE}
or (for TileDB 2.12.0 or later) \sQuote{DELETE} or \sQuote{MODIFY_EXCLUSIVE}}
}
\value{
The TileDB Array object but opened for reading or writing
}
\description{
Open a TileDB Array
}
