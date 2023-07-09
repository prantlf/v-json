# Changes

## [0.0.8](https://github.com/prantlf/v-json/compare/v0.0.7...v0.0.8) (2023-07-09)

### Features

* Propagate options from parse and stringify to unmarshal and marshal ([344012e](https://github.com/prantlf/v-json/commit/344012eb6a5de968535c260e46682a0186e3ab96))

## [0.0.7](https://github.com/prantlf/v-json/compare/v0.0.6...v0.0.7) (2023-07-09)

### Bug Fixes
* Parse an escaped character in the middle of a string properly ([563332f](https://github.com/prantlf/v-json/commit/563332f41ffd4047e2837d93d20851ea4af8873d))

### Features

* Allow single quotes (starting JSON5) ([82b7b92](https://github.com/prantlf/v-json/commit/82b7b9274a00da3ca239474f8ee7d480d6a91fb8))

## [0.0.6](https://github.com/prantlf/v-json/compare/v0.0.5...v0.0.6) (2023-06-25)

### Features

* Allow adding trailing commans to array and objects when stringifying ([7f3c200](https://github.com/prantlf/v-json/commit/7f3c20032b93f3974f974aec852b1ea83322396c))

## [0.0.5](https://github.com/prantlf/v-json/compare/v0.0.4...v0.0.5) (2023-06-24)

### Features

* Add JSON/JSONC parsing, marshalling and unmarshalling ([97382f3](https://github.com/prantlf/v-json/commit/97382f3f4574c38d0bfef01a7a396eae4279bd7e))

### BREAKING CHANGES

* StringifyOpts is expected by parse by reference. This
will probably not break your code, because the compiler does it
automatically. However, in rare cases you may nor need to pass the
reference explicitly.

## [0.0.4](https://github.com/prantlf/v-json/compare/v0.0.3...v0.0.4) (2023-06-08)

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
