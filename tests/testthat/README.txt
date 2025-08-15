- We call devtools::setup() in setup.R to force instantiation of all functions defined in R/*, regardless of how/where
  the tests are run.
- All test-* files including a leading digit to ensure that all tests of internal functions are run before running any
  jaspTools-based testing of JASP-level functionality.
  - The jaspTools-based testing nukes the environment we created with setup.R.
  - Tests of internal functions run after the jaspTools-based test will fail.
- The 'fixtures' directory contains external resources that need to persist across testing runs (e.g., datasets).
