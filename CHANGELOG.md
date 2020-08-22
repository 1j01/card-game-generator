# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

This project does not adhere to [Semantic Versioning](https://semver.org/spec/v2.0.0.html) yet, since it's pre-1.0.0.

Refer to the [latest version of the changelog](https://github.com/1j01/card-game-generator/blob/master/CHANGELOG.md)
for potential future corrections.
(The changelog can't be retroactively updated within an npm release, so if a change was accidentally omitted, it wouldn't be in the changelog in the release, but it *could* be added later to the changelog on GitHub.)

[Unreleased]: https://github.com/1j01/card-game-generator/compare/v0.5.0...HEAD
## [Unreleased]
<details>
	<summary>
		Changes in master that are not yet released.
		Click to see more.
	</summary>

Nothing here yet!

</details>

[0.8.0]: https://github.com/1j01/card-game-generator/compare/v0.7.0...v0.8.0
## [0.8.0] - 2020-08-21
### Changed
- Rewritten with Pupeteer instead of NW.js
- The `scale` option must be an integer. This option is respected again.
- Page to render is served with an HTTP server, instead of using `file:` protocol and relying on `"chromium-args": "--allow-file-access-from-files --allow-file-access"`
- Export is seemingly MUCH faster tho I haven't benchmarked it.

### Added
- The package is now marked as cross-platform, not restricted to Windows.
- You can now specify an environment variable `TABLETOP_SIMULATOR_FOLDER` to point to the "Tabletop Simulator" folder for Tabletop Simulator export. Previously it expected a specific path to exist, and would not support different Steam library locations or operating systems.

### Removed
- The fancy loading indicators window is removed. It now operates completely headlessly (i.e. no windows pop up) by default.

[0.7.0]: https://github.com/1j01/card-game-generator/compare/v0.6.0...v0.7.0
## [0.7.0] - 2019-04-01
### Removed
- No longer respects `scale` option (for now). It is assumed to be `2`.

### Changed
- No longer uses magic numbers, but now uses a wrapper page.
- Always shows capture windows because [capturePage isn't working with hidden windows](https://github.com/nwjs/nw.js/issues/4814)

[0.1.0]: https://github.com/1j01/card-game-generator/commit/77f0022e7ea8ea59e36a456bed8bc8ab26df2032
## [0.1.0] - 2016-04-21
### Added
- Initial release
