# -*- Makefile -*-

BUILD_DIR := builds
PKG_NAME := jaspMissingData

all: renv

## Build and install the package via renv:
renv:
	Rscript ./renv_build.R

## Update the packages in the renv project library:
update:
	Rscript -e "renv::update()"

## Update the state of the lockfile to match the renv library state:
snapshot:
	Rscript -e "renv::snapshot()"

## Build the package:
build: R/* roxygen | $(BUILD_DIR)
	R CMD build ./ > $(BUILD_DIR)/$(PKG_NAME).tar.gz

## Run unit tests:
test: tests/*
	Rscript -e 'jaspTools::setPkgOption("module.dirs", "./"); jaspTools::testAll()'

## Update the NAMESPACE and help files:
roxygen:
	Rscript -e "roxygen2::roxygenize(clean = TRUE)"

## Make sure we have a build directory:
$(BUILD_DIR):
	mkdir $(BUILD_DIR)

.PHONY: $(BUILD_DIR) roxygen renv update snapshot
