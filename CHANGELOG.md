# CHANGELOG for print

This file is used to list changes made in each version of print.

## [3.0.0](https://github.com/sous-chefs/windows_print/compare/v2.1.4...v3.0.0) (2026-11-12)


### ⚠ BREAKING CHANGES

* migrate Windows Print to custom resources ([#51](https://github.com/sous-chefs/windows_print/issues/51))

### Features

* migrate Windows Print to custom resources ([#51](https://github.com/sous-chefs/windows_print/issues/51)) ([9210f45](https://github.com/sous-chefs/windows_print/commit/9210f4541ddd7552f401addcffdbe58e822c89cf))


### Bug Fixes

* **ci:** Update workflows to use release pipeline ([#38](https://github.com/sous-chefs/windows_print/issues/38)) ([3870bcb](https://github.com/sous-chefs/windows_print/commit/3870bcb86264e8b36da0cd18d07265e9d1cdb7d7))

## [2.1.4](https://github.com/sous-chefs/windows_print/compare/2.1.3...v2.1.4) (2025-10-16)


### Bug Fixes

* **ci:** Update workflows to use release pipeline ([#38](https://github.com/sous-chefs/windows_print/issues/38)) ([3870bcb](https://github.com/sous-chefs/windows_print/commit/3870bcb86264e8b36da0cd18d07265e9d1cdb7d7))

## 2.1.0 - *2023-10-31*

* Update CI permissions
* Change LICENSE to Apache-2.0

## 2.0.1 - *2023-10-03*

* Standardise files with files in sous-chefs/repo-management
* Transfer ownership to sous-chefs
* Remove Map Network drive for driver and printer resources.

## 2.0.0

* Providers removed in favor of resources
* Restructured cookbook - move sample files into test.
* Test kitchen support
* Delivery support
* Github Issues

## 1.0.2

* Skip restore settings if the file does not exist

## 1.0.0

* Support for data bag items with recipes to create and delete printer objects and printer settings.

## 0.9.0

* Changelog has been ignored for sometime.
  * Current features: Add, remove ports, printers, drivers
  * Create and restore printer defaults.

## 0.1.0

* Initial release of windows_print
