
test_that(".parseCharacterFormula parses correctly", {
  encoded <- decoded <- colnames(mice::boys)
  form <- "bmi = wgt/(hgt/100)^2"
  expect_equal(
    .parseCharacterFormula(form, encoded, decoded),
    c(var = "bmi", eq = "wgt/(hgt/100)^2")
  )
  form <- "bmi =  wgt/(hgt/100)^2"
  expect_equal(
    .parseCharacterFormula(form, encoded, decoded),
    c(var = "bmi", eq = "wgt/(hgt/100)^2")
  )
  # note that variable checks occur within mice.
})
