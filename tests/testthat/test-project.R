context("Test project function")

setup(RNGversion("3.5.3"))
teardown({
  cur_R_version <- trimws(substr(R.version.string, 10, 16))
  RNGversion(cur_R_version)
})


test_that("Projections can be performed for a single day", {
  i <- incidence::incidence(as.Date('2020-01-23'))
  si <- c(0.2, 0.5, 0.2, 0.1)
  R0 <- 2
  
  p <- project(x = i,
    si = si,
    R = R0,
    n_sim = 2,  # doesn't work with 1 in project function
    R_fix_within = TRUE,
    n_days = 1, # doing 2 days as project function currently not working with one day - will only use first day though
    model = "poisson"
  )

  expect_identical(get_dates(p), as.Date("2020-01-24"))
})

test_that("Projections can be performed for a single day", {
  i <- incidence::incidence(as.Date('2020-01-23'))
  si <- c(0.2, 0.5, 0.2, 0.1)
  R0 <- 2
  
  p <- project(x = i,
    si = si,
    R = R0,
    n_sim = 1,  # doesn't work with 1 in project function
    R_fix_within = TRUE,
    n_days = 2, # doing 2 days as project function currently not working with one day - will only use first day though
    model = "poisson"
  )

  expect_identical(get_dates(p), as.Date("2020-01-24") + 0:1)
  expect_identical(ncol(p), 1L)
})

test_that("Projections can be performed for a single day and single simulation", {
  i <- incidence::incidence(as.Date('2020-01-23'))
  si <- c(0.2, 0.5, 0.2, 0.1)
  R0 <- 2
  
  p <- project(x = i,
    si = si,
    R = R0,
    n_sim = 1,  # doesn't work with 1 in project function
    R_fix_within = TRUE,
    n_days = 1, # doing 2 days as project function currently not working with one day - will only use first day though
    model = "poisson"
  )

  expect_identical(get_dates(p), as.Date("2020-01-24"))
  expect_identical(ncol(p), 1L)
})

test_that("Test against reference results", {
    skip_on_cran()

    ## simulate basic epicurve
    dat <- c(0, 2, 2, 3, 3, 5, 5, 5, 6, 6, 6, 6)
    i <- incidence::incidence(dat)


    ## example with a function for SI
    si <- distcrete::distcrete("gamma", interval = 1L,
                               shape = 1.5,
                               scale = 2, w = 0)

    set.seed(1)
    pred_1 <- project(i, runif(100, 0.8, 1.9), si, n_days = 30)
    attributes(pred_1)$class <- attributes(pred_1)$class[(1:2)]
    expect_equal_to_reference(pred_1, file = "rds/pred_1.rds", update = FALSE)


    ## time-varying R (fixed within time windows)
    set.seed(1)
    pred_2 <- project(i,
                      R = c(1.5, 0.5, 2.1, .4, 1.4),
                      si = si,
                      n_days = 60,
                      time_change = c(10, 15, 20, 30),
                      n_sim = 100)
    attributes(pred_2)$class <- attributes(pred_2)$class[(1:2)]
    expect_equal_to_reference(pred_2, file = "rds/pred_2.rds", update = FALSE)


    ## time-varying R, 2 periods, R is 2.1 then 0.5
    set.seed(1)
    
    pred_3 <- project(i,
                      R = c(2.1, 0.5),
                      si = si,
                      n_days = 60,
                      time_change = 40,
                      n_sim = 100)
    attributes(pred_3)$class <- attributes(pred_3)$class[(1:2)]
    expect_equal_to_reference(pred_3, file = "rds/pred_3.rds", update = FALSE)

    ## time-varying R, 2 periods, separate distributions of R for each period
    set.seed(1)
    R_period_1 <- runif(100, min = 1.1, max = 3)
    R_period_2 <- runif(100, min = 0.6, max = .9)
    
    pred_4 <- project(i,
                      R = list(R_period_1, R_period_2),
                      si = si,
                      n_days = 60,
                      time_change = 20,
                      n_sim = 100)
    attributes(pred_4)$class <- attributes(pred_4)$class[(1:2)]
    expect_equal_to_reference(pred_4, file = "rds/pred_4.rds", update = FALSE)    
    
})





test_that("Test that dates start when needed", {
    skip_on_cran()

    ## simulate basic epicurve
    dat <- c(0, 2, 2, 3, 3, 5, 5, 5, 6, 6, 6, 6)
    i <- incidence::incidence(dat)


    ## example with a function for SI
    si <- distcrete::distcrete("gamma", interval = 1L,
                               shape = 1.5,
                               scale = 2, w = 0)

    set.seed(1)
    pred_1 <- project(i, runif(100, 0.8, 1.9), si, n_days = 30)
    expect_equal(max(i$dates) + 1, min(get_dates(pred_1)))

})




test_that("Errors are thrown when they should", {
    expect_error(project(NULL),
                 "x is not an incidence object")

    i <- incidence::incidence(1:10, 3)
    expect_error(project(i),
                 "daily incidence needed, but interval is 3 days")

    i <- incidence::incidence(1:10, 1, group = letters[1:10])
    expect_error(project(i),
                 "cannot use multiple groups in incidence object")
    i <- incidence::incidence(seq(Sys.Date(), by = "month", length.out = 12), "month")
    expect_error(project(i),
		 "daily incidence needed, but interval is 30 days")

    i <- incidence::incidence(1)
    si <- distcrete::distcrete("gamma", interval = 5L,
                               shape = 1.5,
                               scale = 2, w = 0)

    expect_error(project(i, 1, si = si),
                 "interval used in si is not 1 day, but 5")
    expect_error(project(i, -1, si = si),
                 "R < 0 (value: -1.00)", fixed = TRUE)
    expect_error(project(i, Inf, si = si),
                 "R is not a finite value", fixed = TRUE)
    expect_error(project(i, "tamere", si = si),
                 "R is not numeric", fixed = TRUE)
    expect_error(project(i, R = list(1), si = si, time_change = 2),
                "`R` must be a `list` of size 2 to match 1 time changes; found 1",
                fixed = TRUE)
    
})
