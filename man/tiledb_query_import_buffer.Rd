% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ArrowIO.R
\name{tiledb_query_import_buffer}
\alias{tiledb_query_import_buffer}
\title{Import to Query Buffer from Pair of Arrow IO Pointers}
\usage{
tiledb_query_import_buffer(
  query,
  name,
  nanoarrowptr,
  ctx = tiledb_get_context()
)
}
\arguments{
\item{query}{A TileDB Query object}

\item{name}{A character variable identifying the buffer}

\item{nanoarrowptr}{A \code{nanoarrow} object (which is an external pointer to an Arrow Array
with the Arrow Schema stored as the external pointer tag) classed as an S3 object}

\item{ctx}{tiledb_ctx object (optional)}
}
\value{
The update Query external pointer is returned
}
\description{
This function imports to the named buffer for a \sQuote{WRITE} query
from two Arrow exerternal pointers.
}
