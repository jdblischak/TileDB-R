% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Group.R
\name{tiledb_group_add_member}
\alias{tiledb_group_add_member}
\title{Add Member to TileDB Group}
\usage{
tiledb_group_add_member(grp, uri, relative, name = NULL)
}
\arguments{
\item{grp}{A TileDB Group object as for example returned by
\code{tiledb_group()}}

\item{uri}{A character value with a new URI}

\item{relative}{A logical value indicating whether URI is
relative to the group}

\item{name}{An optional character providing a name for the
object, defaults to \code{NULL}}
}
\value{
The TileDB Group object, invisibly
}
\description{
Add Member to TileDB Group
}
