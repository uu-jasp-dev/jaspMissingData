# rm(list = ls(all = TRUE))
#
# remotes::install_github("uu-jasp-dev/jaspRegression@missingData")
#
# setupJaspTools()
#
# library(testthat)
# library(mice)
# library(dplyr)
# library(jaspTools)
#
# setPkgOption("module.dirs", here::here())
#
# setwd(here::here())
# source(test_path("setup.R"))

boys <- readRDS(test_path("fixtures", "boys.rds"))
miceMids <- readRDS(test_path("fixtures", "mice_mids.rds"))
options <- readRDS(test_path("fixtures", "lin_reg_large_model_options.rds"))

options$covarianceMatrix <- TRUE

results <- jaspTools::runAnalysis("MissingDataImputation", boys, options)

# Extract and processing the coefficients table from JASP
coefTab <- results[["results"]][["ModelContainer"]][["collection"]][["ModelContainer_coeffTable"]][["data"]]
jaspCoefTab <- data.frame(
  est = sapply(coefTab, "[[", x = "unstandCoeff"),
  se = sapply(coefTab, "[[", x = "SE"),
  t = sapply(coefTab, "[[", x = "t"),
  p = sapply(coefTab, "[[", x = "p")
)

### --------------------------------------------------------------------------------------------------------------------

test_that("Linear regression parameters pooled correctly for an intercept-only model.", {
  mipoCoef <- with(miceMids, lm(tv ~ 1)) |>
    mice::pool() |>
    summary() |>
    dplyr::select(-term, -df) |>
    as.data.frame()

  colnames(mipoCoef) <- c("est", "se", "t", "p")

  expect_equal(head(jaspCoefTab, 1), mipoCoef)
})

### --------------------------------------------------------------------------------------------------------------------

test_that("Linear regression parameters pool correctly with only one predictor.", {
  mipoCoef <- with(miceMids, lm(tv ~ hgt)) |>
    mice::pool() |>
    summary() |>
    dplyr::select(-term, -df) |>
    as.data.frame()

  colnames(mipoCoef) <- c("est", "se", "t", "p")

  jaspCoefTab[2:3, ] |>
    data.frame(row.names = 1:2) |>
    expect_equal(mipoCoef)
})

### --------------------------------------------------------------------------------------------------------------------

test_that("Linear regression parameters pool correctly with only numeric predictors.", {
  mipoCoef <- with(miceMids, lm(tv ~ hgt + wgt)) |>
    mice::pool() |>
    summary() |>
    dplyr::select(-term, -df) |>
    as.data.frame()

  colnames(mipoCoef) <- c("est", "se", "t", "p")

  jaspCoefTab[4:6, ] |>
    data.frame(row.names = 1:3) |>
    expect_equal(mipoCoef)
})

### --------------------------------------------------------------------------------------------------------------------

test_that("Linear regression parameters pool correctly with numeric and categorical predictors.", {
  mipoCoef <- with(miceMids, lm(tv ~ hgt + wgt + reg)) |>
    mice::pool() |>
    summary() |>
    dplyr::select(-term, -df) |>
    as.data.frame()

  colnames(mipoCoef) <- c("est", "se", "t", "p")

  jaspCoefTab[7:13, ] |>
    data.frame(row.names = 1:7) |>
    expect_equal(mipoCoef)
})

### --------------------------------------------------------------------------------------------------------------------

test_that("Linear regression parameters pool correctly when adding one interaction term.", {
  mipoCoef <- with(miceMids, lm(tv ~ hgt + wgt + reg + hgt * wgt)) |>
    mice::pool() |>
    summary() |>
    dplyr::select(-term, -df) |>
    as.data.frame()

  colnames(mipoCoef) <- c("est", "se", "t", "p")

  jaspCoefTab[14:21, ] |>
    data.frame(row.names = 1:8) |>
    expect_equal(mipoCoef)
})

### --------------------------------------------------------------------------------------------------------------------

test_that("Linear regression parameters pool correctly when adding interactions involving dummy codes.", {
  mipoCoef <- with(miceMids, lm(tv ~ hgt + wgt + reg + hgt * wgt + wgt * reg)) |>
    mice::pool() |>
    summary() |>
    dplyr::select(-term, -df) |>
    as.data.frame()

  colnames(mipoCoef) <- c("est", "se", "t", "p")

  tail(jaspCoefTab, 12) |>
    data.frame(row.names = 1:12) |>
    expect_equal(mipoCoef)
})

### --------------------------------------------------------------------------------------------------------------------

# fmt: skip
test_that("Coefficients table results match", {
  table <- results[["results"]][["ModelContainer"]][["collection"]][["ModelContainer_coeffTable"]][["data"]]
  jaspTools::expect_equal_tables(
    table,
    list(
      "FALSE", 0.317136961972974,    "M<unicode>", "(Intercept)",                                 1.35330367518679e-68, "",                 26.8975708497525,   8.53021390374332,
      "TRUE",  0.708873174014227,    "M<unicode>", "(Intercept)",                                 8.86275108703199e-14, "",                 -12.7906601770648,  -9.06695587745329,
      "FALSE", 0.00499156035123898,  "M<unicode>", "hgt",                                         3.1897185383045e-25,  0.767934154176535,  26.8958131117783,   0.134252074343086,
      "TRUE",  1.12294585537918,     "M<unicode>", "(Intercept)",                                 0.623439537219199,    "",                 0.501333872418568,  0.562970794193624,
      "FALSE", 0.0143862762569725,   "M<unicode>", "hgt",                                         0.103017056467338,    -0.140707858817893, -1.71107017886869,  -0.0246159282882723,
      "FALSE", 0.0235543976790782,   "M<unicode>", "wgt",                                         2.26827112777922e-14, 0.962667920811472,  12.7906300989981,   0.301275587917789,
      "TRUE",  1.14364457591177,     "M<unicode>", "(Intercept)",                                 0.835784106152615,    "",                 0.209392120408636,  0.239470162744001,
      "FALSE", 0.0149121191054207,   "M<unicode>", "hgt",                                         0.0752398180676156,   -0.162793721544542, -1.90983633392695,  -0.0284797068833786,
      "FALSE", 0.0241501272576832,   "M<unicode>", "wgt",                                         1.23922439792427e-12, 1.00403022899397,   13.0111237547281,   0.314220294442148,
      "FALSE", 1.00543719969302,     "M<unicode>", "reg (east)",                                  0.542292613001919,    "",                 0.6303635594114,    0.633790971963124,
      "FALSE", 0.953701784350436,    "M<unicode>", "reg (north)",                                 0.0134465278143179,   "",                 -2.70670672925286,  -2.58139103740179,
      "FALSE", 0.889180258751549,    "M<unicode>", "reg (south)",                                 0.383197362172974,    "",                 0.901355194941502,  0.801467245465137,
      "FALSE", 0.731908549034349,    "M<unicode>", "reg (west)",                                  0.228924837688115,    "",                 1.22763875396341,   0.898519299151693,
      "TRUE",  1.13368446737647,     "M<unicode>", "(Intercept)",                                 0.0246794502424529,   "",                 2.43989827675499,   2.76607477833575,
      "FALSE", 0.0140562976304611,   "M<unicode>", "hgt",                                         0.0537992427351074,   0.164394508261335,  2.04604049405229,   0.0287597541483747,
      "FALSE", 0.0940790421813547,   "M<unicode>", "wgt",                                         8.48990579070407e-10, -2.18739930203406,  -7.2765015241376,   -0.684566293822033,
      "FALSE", 0.962471064915285,    "M<unicode>", "reg (east)",                                  0.695989229018646,    "",                 0.403385502447546,  0.388246874112077,
      "FALSE", 0.908478735553678,    "M<unicode>", "reg (north)",                                 0.00178011320781525,  "",                 -3.70982037207923,  -3.37029292075781,
      "FALSE", 0.840585568163697,    "M<unicode>", "reg (south)",                                 0.606892700458836,    "",                 0.528389424376757,  0.444156524501425,
      "FALSE", 0.683637373335424,    "M<unicode>", "reg (west)",                                  0.562232866626577,    "",                 0.58702121939076,   0.401309644516457,
      "FALSE", 0.000438490228953687, "M<unicode>", "hgt <unicode><unicode><unicode> wgt",         5.95703113498419e-13, 2.90998824316858,   10.4194792494438,   0.00456883984166682,
      "TRUE",  1.14670679251089,     "M<unicode>", "(Intercept)",                                 0.00766736056844569,  "",                 2.75936768336421,   3.16418566554877,
      "FALSE", 0.0136251218772375,   "M<unicode>", "hgt",                                         0.10928038410362,     0.130076011163306,  1.67014692619142,   0.0227559554222516,
      "FALSE", 0.0981358547953189,   "M<unicode>", "wgt",                                         1.11569115149143e-08, -2.27043810086242,  -7.24051402600686,  -0.710554033099679,
      "FALSE", 1.13184072406492,     "M<unicode>", "reg (east)",                                  0.92589762000984,     "",                 0.0934746729770686, 0.105798441544097,
      "FALSE", 1.28168864114974,     "M<unicode>", "reg (north)",                                 0.207188108412884,    "",                 1.26710002070577,   1.62402770373919,
      "FALSE", 0.989837968590423,    "M<unicode>", "reg (south)",                                 0.743111382325445,    "",                 0.328303938435167,  0.324967703500901,
      "FALSE", 0.998239501008155,    "M<unicode>", "reg (west)",                                  0.892145545199016,    "",                 0.135971800139478,  0.135732421922413,
      "FALSE", 0.000438786648278225, "M<unicode>", "hgt <unicode><unicode><unicode> wgt",         1.24186496609766e-12, 3.05757049848511,   10.9405152359345,   0.00480055201081256,
      "FALSE", 0.0246619230652773,   "M<unicode>", "wgt <unicode><unicode><unicode> reg (east)",  0.761913380772249,    "",                 0.303572231043631,  0.00748667500675263,
      "FALSE", 0.0260163577181576,   "M<unicode>", "wgt <unicode><unicode><unicode> reg (north)", 7.68599542715154e-05, "",                 -4.0268018200786,   -0.104762716611293,
      "FALSE", 0.0267415749498798,   "M<unicode>", "wgt <unicode><unicode><unicode> reg (south)", 0.904823541057647,    "",                 0.120457134818176,  0.00322121349898803,
      "FALSE", 0.0256139016043506,   "M<unicode>", "wgt <unicode><unicode><unicode> reg (west)",  0.811692473843971,    "",                 0.239965963171674,  0.00614646456907246
    )
  )
})

### --------------------------------------------------------------------------------------------------------------------

# fmt: skip
test_that("Coefficients Covariance Matrix table results match", {
  table <- results[["results"]][["ModelContainer"]][["collection"]][["ModelContainer_coeffCovMatrixTable"]][["data"]]
  jaspTools::expect_equal_tables(
    table,
    list(
      "TRUE",  2.4915674740061e-05,  "",                    "M<unicode>", "hgt",                                         "",                   "",                   "",                   "",                    "",                    "",                    "",                    "",                    "",
      "TRUE",  0.00020696494454193,  "",                    "M<unicode>", "hgt",                                         "",                   "",                   "",                   "",                    -0.000323630371339812, "",                    "",                    "",                    "",
      "FALSE", "",                   "",                    "M<unicode>", "wgt",                                         "",                   "",                   "",                   "",                    0.000554809650024162,  "",                    "",                    "",                    "",
      "TRUE",  0.000222371296214252, "",                    "M<unicode>", "hgt",                                         -0.00654075922958338, -0.00371701880119683, -0.00453491157177295, -0.0016099510620988,   -0.000345122815213528, "",                    "",                    "",                    "",
      "FALSE", "",                   "",                    "M<unicode>", "wgt",                                         0.0091067673272683,   0.00466488512459495,  0.00637937962480349,  0.00212160674735191,   0.000583228646562292,  "",                    "",                    "",                    "",
      "FALSE", "",                   "",                    "M<unicode>", "reg (east)",                                  1.01090396252654,     0.743951985474387,    0.773924650974141,    0.561347905525883,     "",                    "",                    "",                    "",                    "",
      "FALSE", "",                   "",                    "M<unicode>", "reg (north)",                                 "",                   0.909547093473206,    0.669189476374106,    0.52322635874467,      "",                    "",                    "",                    "",                    "",
      "FALSE", "",                   "",                    "M<unicode>", "reg (south)",                                 "",                   "",                   0.790641532553472,    0.523987552453788,     "",                    "",                    "",                    "",                    "",
      "FALSE", "",                   "",                    "M<unicode>", "reg (west)",                                  "",                   "",                   "",                   0.535690124149566,     "",                    "",                    "",                    "",                    "",
      "TRUE",  0.000197579503076106, 9.5655375578211e-07,   "M<unicode>", "hgt",                                         -0.00461866197930602, -0.00261668836790339, -0.00312027284889224, -0.000351355754703625, -0.000495356498869455, "",                    "",                    "",                    "",
      "FALSE", "",                   -4.00832722634737e-05, "M<unicode>", "wgt",                                         -0.0210906323300234,  -0.0153144106965355,  -0.0167939351566541,  -0.0133174569794143,   0.00885086617776112,   "",                    "",                    "",                    "",
      "FALSE", "",                   0.000136135978455183,  "M<unicode>", "reg (east)",                                  0.926350550799162,    0.695297768406631,    0.70912542153704,     0.486769808560472,     "",                    "",                    "",                    "",                    "",
      "FALSE", "",                   9.18618646201988e-05,  "M<unicode>", "reg (north)",                                 "",                   0.825333612953209,    0.616858195618011,    0.462208251147866,     "",                    "",                    "",                    "",                    "",
      "FALSE", "",                   0.000105004292703824,  "M<unicode>", "reg (south)",                                 "",                   "",                   0.706584097405086,    0.452772159840067,     "",                    "",                    "",                    "",                    "",
      "FALSE", "",                   6.81997451375351e-05,  "M<unicode>", "reg (west)",                                  "",                   "",                   "",                   0.467360058220958,     "",                    "",                    "",                    "",                    "",
      "FALSE", "",                   1.92273680887857e-07,  "M<unicode>", "hgt <unicode><unicode><unicode> wgt",         "",                   "",                   "",                   "",                    "",                    "",                    "",                    "",                    "",
      "TRUE",  0.000185643946169575, 7.79380249408831e-07,  "M<unicode>", "hgt",                                         -0.00499040114029576, -0.00388192194753744, -0.00353292490773434, -0.00376134063698312,  -0.000487328399113558, 1.7123746868524e-05,   4.31601601468567e-05,  1.48256204430994e-05,  9.65327493087047e-05,
      "FALSE", "",                   -4.07218363100514e-05, "M<unicode>", "wgt",                                         -0.00641862847539528, -0.00477419065332399, 0.00966655109484257,  0.00562364767655493,   0.00963064599640791,   -0.000625856082267898, -0.000558574923342364, -0.000948745002862805, -0.000697056196638581,
      "FALSE", "",                   0.000123847331440984,  "M<unicode>", "reg (east)",                                  1.2810634246518,      0.893450098673291,    0.809671005867983,    0.857434702510607,     "",                    -0.0159134568945403,   -0.0114357784201611,   -0.00824272983371292,  -0.0145327394437149,
      "FALSE", "",                   0.00010264637743141,   "M<unicode>", "reg (north)",                                 "",                   1.64272577285228,     0.746836578472546,    0.795310409882893,     "",                    -0.00900016480918096,  -0.022584955105668,    -0.00695500406970958,  -0.0125691261108267,
      "FALSE", "",                   4.2971161607731e-05,   "M<unicode>", "reg (south)",                                 "",                   "",                   0.979779204063214,    0.77397619839796,      "",                    -0.0121685598124272,   -0.0129932432437634,   -0.0164682899096299,   -0.0157110051066485,
      "FALSE", "",                   6.16904149736281e-05,  "M<unicode>", "reg (west)",                                  "",                   "",                   "",                   0.996482101373011,     "",                    -0.0114016248747759,   -0.0127272855710132,   -0.0110588269774939,   -0.0191195983911415, 
      "FALSE", "",                   1.92533722707238e-07,  "M<unicode>", "hgt <unicode><unicode><unicode> wgt",         "",                   "",                   "",                   "",                    "",                    7.54612080973541e-07,  2.38184105349021e-07,  2.10167223116993e-06,  3.74773471662641e-07,
      "FALSE", "",                   "",                    "M<unicode>", "wgt <unicode><unicode><unicode> reg (east)",  "",                   "",                   "",                   "",                    "",                    0.000608210449277658,  0.000427639376208469,  0.000498632474975143,  0.000439646133798769,
      "FALSE", "",                   "",                    "M<unicode>", "wgt <unicode><unicode><unicode> reg (north)", "",                   "",                   "",                   "",                    "",                    "",                    0.000676850868919141,  0.000474788447070905,  0.000463718719727937,
      "FALSE", "",                   "",                    "M<unicode>", "wgt <unicode><unicode><unicode> reg (south)", "",                   "",                   "",                   "",                    "",                    "",                    "",                    0.00071511183080004,   0.00050366704111736, 
      "FALSE", "",                   "",                    "M<unicode>", "wgt <unicode><unicode><unicode> reg (west)",  "",                   "",                   "",                   "",                    "",                    "",                    "",                    "",                    0.000656071955397353
    )
  )
})
