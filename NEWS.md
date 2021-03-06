# projections 0.4.1

- `project()` will can now take single dates or single projections as inputs.
  (@acori, @zkamvar, #18).

# projections 0.4.0

- `project` can now use time-varying R by specifying `time_change`, a vector of
  dates at which R changes, and providing a `vector` or a `list` of values for
  `R` instead of a vector, in which case it needs to have `length(time_change) +
  1` components, each of which is a vector of R values.

# projections 0.3.2

- A bug in `project()` where R was being resampled recursively was fixed
  (#11, @jarvisc1; #12, @zkamvar)

# projections 0.3.1

 - `get_dates()` now inherits the generic `get_dates()` from incidence

# projections 0.3.0

## New features

This is a big release! Plenty of new features have been added, including:

- `projections` can now be subsetted like matrices using `x[i,j]`, or using the
  function `subset`
  
- new function `cumulate` to compute cumulative incidence for `projections`
  objects, akin to the similar function in the `incidence` package
  
- much improved graphics; `plot` now call upons `add_projections`, which
  implements many options for plotting projections, including quantiles lines,
  ribbon, and boxplots; `add_projections` can also be used to add such plots to
  an existing `incidence` plot

- `build_projections` can be used to build a `projections` object from an input
  matrix and optional dates



# projections 0.1.1

## New features

- `project` can now use a Negative Binomial model as an alternative to the
  original Poisson model to account for over-dispersion in new cases /
  super-spreading.


## Bug fixes

Fixed the calls to `sample`, which has a rather irrational behaviour when
passing a first argument of length 1 (i.e. not bootstrapping from the vector).




# projections 0.0.1

First release of the package!


## New features

- `project`: a function generating projections from an existing *incidence*
  object, a serial interval distribution, and a set of plausible reproduction
  numbers ($R$); returns a `projections` object.
  
- `plot`/`print`: plotting and printing methods for `projections` objects.

- `get_dates`: accessors for `projections` objects.

- `as.data.frame`: conversion from `projections` objects to `data.frame`.

