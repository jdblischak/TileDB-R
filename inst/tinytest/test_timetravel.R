library(tinytest)
library(tiledb)

isOldWindows <- Sys.info()[["sysname"]] == "Windows" && grepl('Windows Server 2008', osVersion)
if (isOldWindows) exit_file("skip this file on old Windows releases")
isMacOS <- (Sys.info()['sysname'] == "Darwin")

ctx <- tiledb_ctx(limitTileDBCores())

if (tiledb_version(TRUE) < "2.3.0") exit_file("TileDB time travel tests require TileDB 2.3.* or greater")



## tests formerly in test_tiledbarray.R


## timestamp_start and timestamp_end
uri <- tempfile()

data <- data.frame(grp = rep(1:4, each=10), 				# 4 distinct groups
                   val = rep(1:4, each=10) * 100 + 1:10)    # and 4 sets of value (used as index)

times <- Sys.time() + 0:3          			# pre-allocate for four time stamps

deltat <- 0.100                     		# start with this gap of 'delta_t'
success <- FALSE

## the test has seen to be sensitive to the test environment; some CI frameworks were 'randomly'
## failing even with a 'moderately large' timestep. so we now invert this by first finding a suitable
## timestep (still starting from a small value) and then using that value
while (deltat < 30) {
    if (dir.exists(uri)) unlink(uri, TRUE)

    fromDataFrame(subset(data, grp==1), # write array, but only write group one
                  uri, sparse=TRUE,
                  col_index="val", tile_domain=list(val=range(data$val)))

    arr <- tiledb_array(uri)
    for (i in 2:4) {                        # in loop, write groups two to four
        Sys.sleep(deltat)
        arr[] <- subset(data, grp==i)
        times[i] <- Sys.time()              # and note time
    }

    ## we need an 'epsilon' because when we record 'times' is not exactly where the array timestamp is
    epst <- deltat/2

    res1 <- tiledb_array(uri, as.data.frame=TRUE)[]							 		# no limits
    res2 <- tiledb_array(uri, as.data.frame=TRUE, timestamp_end=times[1]+epst)[]    # end after 1st timestamp
    res3 <- tiledb_array(uri, as.data.frame=TRUE, timestamp_start=times[4]+epst)[] 	# start after fourth
    res4 <- tiledb_array(uri, as.data.frame=TRUE, timestamp_end=times[3]-epst)[]    # end before 3rd
    res5 <- tiledb_array(uri, as.data.frame=TRUE, timestamp_start=times[2]-epst, timestamp_end=times[3]+epst)[]

    if (isTRUE(all.equal(NROW(res1), 40)) &&                    # all four groups
        isTRUE(all.equal(NROW(res2), 10)) &&		            # expect group one (10 elements)
        isTRUE(all.equal(NROW(res3), 0))  &&		            # expect zero data
        isTRUE(all.equal(NROW(res4), 20)) &&  					# expect 2 groups, 20 obs
        isTRUE(all.equal(max(res4$grp), 2))  &&		            # with groups being 1 and 2
        isTRUE(all.equal(NROW(res5), 20)) && 		            # expects 2 groups, 2 and 3, with 20 obs
        isTRUE(all.equal(min(res5$grp), 2)) &&
        isTRUE(all.equal(max(res5$grp), 3))) {
        if (Sys.getenv("CI") != "") message("Success with gap time of ", deltat)
        success <- TRUE
        break
    }
    deltat <- deltat * 5
}

if (!success) exit_file("Issue with time traveling")

res1 <- tiledb_array(uri, as.data.frame=TRUE)[] 		# no limits
expect_equal(NROW(res1), 40)                            # all four observations

res2 <- tiledb_array(uri, as.data.frame=TRUE, timestamp_end=times[1]+epst)[]    # end before 1st timestamp
expect_equal(NROW(res2), 10)            # expect group one (10 elements)

res3 <- tiledb_array(uri, as.data.frame=TRUE, timestamp_start=times[4]+epst)[] # start after fourth
expect_equal(NROW(res3), 0)             # expect zero data

res4 <- tiledb_array(uri, as.data.frame=TRUE, timestamp_end=times[3]-epst)[]    # end before 3rd
expect_equal(NROW(res4), 20)            # expect 2 groups, 20 obs
expect_equal(max(res4$grp), 2)          # with groups being 1 and 2

res5 <- tiledb_array(uri, as.data.frame=TRUE, timestamp_start=times[2]-epst, timestamp_end=times[3]+epst)[]
expect_equal(NROW(res5), 20)            # expects 2 groups, 2 and 3, with 20 obs
expect_equal(min(res5$grp), 2)
expect_equal(max(res5$grp), 3)

## now given the existing array we can also read its timestamps
## from the fragment info and use with a smaller eps_t
fi <- tiledb_fragment_info(uri)
n <- tiledb_fragment_info_get_num(fi)
expect_equal(n, 4)
times <- do.call(c, lapply(seq_len(n), function(i) tiledb_fragment_info_get_timestamp_range(fi, i-1)[1]))

epst <- 0.005
res1 <- tiledb_array(uri, as.data.frame=TRUE)[]							 		# no limits
res2 <- tiledb_array(uri, as.data.frame=TRUE, timestamp_end=times[1]+epst)[]    # end before 1st timestamp
res3 <- tiledb_array(uri, as.data.frame=TRUE, timestamp_start=times[4]+epst)[] 	# start after fourth
res4 <- tiledb_array(uri, as.data.frame=TRUE, timestamp_end=times[3]-epst)[]    # end before 3rd
res5 <- tiledb_array(uri, as.data.frame=TRUE, timestamp_start=times[2]-epst, timestamp_end=times[3]+epst)[]
expect_equal(NROW(res1), 40)
expect_equal(NROW(res2), 10)		            # expect group one (10 elements)
expect_equal(NROW(res3), 0)			            # expect zero data
expect_equal(NROW(res4), 20)  					# expect 2 groups, 20 obs
expect_equal(max(res4$grp), 2)		            # with groups being 1 and 2
expect_equal(NROW(res5), 20) 		            # expects 2 groups, 2 and 3, with 20 obs
expect_equal(min(res5$grp), 2)
expect_equal(max(res5$grp), 3)



## timestamp_start and timestamp_end



## time-travel vaccum test
vfs <- tiledb_vfs()
ndirfull <- tiledb_vfs_ls(uri, vfs=vfs)
array_consolidate(uri, start_time=times[2]-epst, end_time=times[3]+epst)
array_vacuum(uri, start_time=times[2]-epst, end_time=times[3]+epst)
ndircons <- tiledb_vfs_ls(uri, vfs=vfs)
expect_true(length(ndircons) < length(ndirfull))
array_consolidate(uri, start_time=times[1]-0.5, end_time=times[3])
array_vacuum(uri, start_time=times[1]-0.5, end_time=times[3])
ndircons2 <- tiledb_vfs_ls(uri, vfs=vfs)
expect_true(length(ndircons2) < length(ndircons))

## earlier time travel test recast via timestamp_{start,end}
## time travel
tmp <- tempfile()
dir.create(tmp)
dom <- tiledb_domain(dims = c(tiledb_dim("rows", c(1L, 10L), 5L, "INT32"),
                              tiledb_dim("cols", c(1L, 10L), 5L, "INT32")))
schema <- tiledb_array_schema(dom, attrs=c(tiledb_attr("a", type = "INT32")), sparse = TRUE)
invisible( tiledb_array_create(tmp, schema) )

I <- c(1, 2, 2)
J <- c(1, 4, 3)
data <- c(1L, 2L, 3L)
now1 <- Sys.time()
A <- tiledb_array(uri = tmp, timestamp_start=now1)
A[I, J] <- data

Sys.sleep(deltat)

now2 <- Sys.time()
I <- c(8, 6, 9)
J <- c(5, 7, 8)
data <- c(11L, 22L, 33L)
A <- tiledb_array(uri = tmp, timestamp_start=now2)
A[I, J] <- data

epst <- 0.1
A <- tiledb_array(uri = tmp, as.data.frame=TRUE, timestamp_end=now1 - epst)
expect_equal(nrow(A[]), 0)
A <- tiledb_array(uri = tmp, as.data.frame=TRUE, timestamp_start=now1 + epst)
expect_equal(nrow(A[]), 3)
A <- tiledb_array(uri = tmp, as.data.frame=TRUE, timestamp_end=now2 - epst)
expect_equal(nrow(A[]), 3)
A <- tiledb_array(uri = tmp, as.data.frame=TRUE, timestamp_end=now2 + epst)
expect_equal(nrow(A[]), 6)