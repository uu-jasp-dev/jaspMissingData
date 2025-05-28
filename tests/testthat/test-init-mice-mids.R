test_that("initMiceMids runs without errors", {

  expect_null(
    .initMiceMids(list(MiceMids = "notnull"))
  )
  expect_error(
    .initMiceMids(NULL)
  )
})
