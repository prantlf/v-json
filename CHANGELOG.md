# Changes

## [0.2.6](https://github.com/prantlf/v-json/compare/v0.2.5...v0.2.6) (2024-11-16)

### Bug Fixes

* Replace get_uchar with get_rune ([1f02e40](https://github.com/prantlf/v-json/commit/1f02e401e2e60bbe88fa51b4003c591b714ac5f5))

## [0.2.5](https://github.com/prantlf/v-json/compare/v0.2.4...v0.2.5) (2024-11-16)

### Bug Fixes

* Replace deprecated index_u8_last with last_index_u8 ([60ee485](https://github.com/prantlf/v-json/commit/60ee4855256e64cfcb456f9fd3c4710d1f141c64))
* Fix sources for the new V compiler ([7e10163](https://github.com/prantlf/v-json/commit/7e1016339260feaa31b16bd59bd6a9fc1acfd23d))

## [0.2.4](https://github.com/prantlf/v-json/compare/v0.2.3...v0.2.4) (2024-04-17)

### Bug Fixes

* Clone unsafely created string saved in arrays ([1e300ab](https://github.com/prantlf/v-json/commit/1e300abbce966c76dad72f89b53e9cff708cdef7))

## [0.2.3](https://github.com/prantlf/v-json/compare/v0.2.2...v0.2.3) (2024-04-17)

### Bug Fixes

* Replace constant arrays with fixed arrays ([61c8554](https://github.com/prantlf/v-json/commit/61c8554e80f921a4afe8974d211ee70f001281f1))

## [0.2.2](https://github.com/prantlf/v-json/compare/v0.2.1...v0.2.2) (2024-03-24)

### Bug Fixes

* Add the now mandatory & for passing references ([5e910c8](https://github.com/prantlf/v-json/commit/5e910c852067a2be2278d5146d7a52ead9557e39))

## [0.2.1](https://github.com/prantlf/v-json/compare/v0.2.0...v0.2.1) (2024-01-28)

### Bug Fixes

* Fix sources for the new V compiler ([814260a](https://github.com/prantlf/v-json/commit/814260a174169bba789a0cac06f4107c06b14ac0))

## [0.2.0](https://github.com/prantlf/v-json/compare/v0.1.4...v0.2.0) (2024-01-01)

### Features

* Implement marshal without Any, introduce marshal_opt ([31b1257](https://github.com/prantlf/v-json/commit/31b1257b8c177b2e3ca74124c7322bfdd3aa312d))
* Remove options from parse, stringify and unmarshal ([cbf9de6](https://github.com/prantlf/v-json/commit/cbf9de6ec0885b0854a81636ea9ded6f9767e417))
* Add escape and escape_opt for just escaping string values ([a4d20b5](https://github.com/prantlf/v-json/commit/a4d20b5512536a3498bfe92f46b5adab4725fca3))

### BREAKING CHANGES

If you just pass default options to the functions,
just delete them. They do not expect options any more. If you use
non-empty options, replace the function name with `<name>_opt`,
which supports options.

If you just pass default options to `marshal`,
just delete them. The `marshal` does not expect options. If you
use non-empty options, replace `marshal` with `marshal_opt`,
which supports options. Also, although replacing the implementation
should not change the behaviour of the interface, there might be
bugs, which the existing tests had not discovered.

## [0.1.4](https://github.com/prantlf/v-json/compare/v0.1.3...v0.1.4) (2023-12-31)

### Bug Fixes

* Fix writing through UTF-8 bytes to builder ([a799e1a](https://github.com/prantlf/v-json/commit/a799e1a72e17d79fc43a5407c7dc030b0b23ba7c))

## [0.1.3](https://github.com/prantlf/v-json/compare/v0.1.2...v0.1.3) (2023-12-11)

### Bug Fixes

* Adapt for V langage changes ([cf6f61f](https://github.com/prantlf/v-json/commit/cf6f61fc2fdbb67b3aae08f374892e16aa47ad2e))

## [0.1.2](https://github.com/prantlf/v-json/compare/v0.1.1...v0.1.2) (2023-11-14)

### Bug Fixes

* Reduce memory allocations when writing escape sequences ([148fd9c](https://github.com/prantlf/v-json/commit/148fd9ca46c40e3892fec6555dc3d05e88825032))

## [0.1.1](https://github.com/prantlf/v-json/compare/v0.1.0...v0.1.1) (2023-11-14)

### Bug Fixes

* Pad hex numbers in escaped Unicode to 4 digits ([4e174bf](https://github.com/prantlf/v-json/commit/4e174bfd485e4e4f68f4901f3a5534cc3996d629))

## [0.1.0](https://github.com/prantlf/v-json/compare/v0.0.9...v0.1.0) (2023-08-15)

### Features

* Add unmarshal_to to modify an existing object ([2cf9949](https://github.com/prantlf/v-json/commit/2cf9949f9d55ff9b192d94282a09cbef518a281f))

## [0.0.9](https://github.com/prantlf/v-json/compare/v0.0.8...v0.0.9) (2023-07-09)

### Bug Fixes

* Escape control characters in the stringified output ([9c9aac6](https://github.com/prantlf/v-json/commit/9c9aac67c050b7c91ab4046f0f26332aedf57b15))
* Fail parsing if an invalid escape seqauence is detected ([f86d4b5](https://github.com/prantlf/v-json/commit/f86d4b5baee59c9a7aba82f36c4d11b49071d59f))
* Parse and stringify unicode escape sequences ([4ac6be5](https://github.com/prantlf/v-json/commit/4ac6be5139bd747d648512be709d1ad505ae0719))

### Features

* Allow escaping multibyte characters in the JSON output ([25d4511](https://github.com/prantlf/v-json/commit/25d451177067ff7e30ac7c9cf9c0d114f5c71925))
* Allow escaping slashes in the stringified output ([115f81c](https://github.com/prantlf/v-json/commit/115f81c979ba80855938dccb53121946c7f11122))

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
