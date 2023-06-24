## [0.0.5](https://github.com/prantlf/v-json/compare/v0.0.4...v0.0.5) (2023-06-24)


### Features

* Add JSONi/JSONC parsing, marshalling and unmarshalling ([97382f3](https://github.com/prantlf/v-json/commit/97382f3f4574c38d0bfef01a7a396eae4279bd7e))


### BREAKING CHANGES

* StringifyOpts is expected by parse by reference. This
will probably not break your code, because the compiler does it
automatically. However, in rare cases you may nor need to pass the
reference explicitly.



## [0.0.4](https://github.com/prantlf/v-json/compare/v0.0.3...v0.0.4) (2023-06-08)


### Bug Fixes

* Upgrade jany dependency ([2f13f7d](https://github.com/prantlf/v-json/commit/2f13f7d778db127e66fbea4aa3735cf37ac50d4e))



## [0.0.3](https://github.com/prantlf/v-json/compare/v0.0.2...v0.0.3) (2023-06-06)


### Bug Fixes

* Fix the dependency on jany ([3c36752](https://github.com/prantlf/v-json/commit/3c36752100ef07402c2e265a875b775ade89c958))



## [0.0.2](https://github.com/prantlf/v-json/compare/v0.0.1...v0.0.2) (2023-06-06)


### chore

* Rename jsany to jany ([44665aa](https://github.com/prantlf/v-json/commit/44665aa0808db5d281567038b0857921ac5925dd))


### BREAKING CHANGES

* The type Any is imported from `prantlf.jany`
instead of from `pratlf.jsany`. You have to rename the import
module name in your sources.



## 0.0.1 (2023-06-06)



# [0.0.4](https://github.com/prantlf/v-json/compare/v0.0.3...v0.0.4) (2023-06-08)


### Bug Fixes

* Upgrade `jany` dependency ([2f13f7d](https://github.com/prantlf/v-json/commit/2f13f7d778db127e66fbea4aa3735cf37ac50d4e))



## [0.0.3](https://github.com/prantlf/v-json/compare/v0.0.2...v0.0.3) (2023-06-06)


### Bug Fixes

* Fix the dependency on `jany` ([3c36752](https://github.com/prantlf/v-json/commit/3c36752100ef07402c2e265a875b775ade89c958))



## [0.0.2](https://github.com/prantlf/v-json/compare/v0.0.1...v0.0.2) (2023-06-06)


### chore

* Rename jsany to jany ([44665aa](https://github.com/prantlf/v-json/commit/44665aa0808db5d281567038b0857921ac5925dd))


### BREAKING CHANGES

* The type Any is imported from `prantlf.jany` instead of from `pratlf.jsany`. You have to rename the import module name in your sources.



## 0.0.1 (2023-06-06)


Initial release.
