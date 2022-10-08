# pandoc-template with nix

[![Project Status: Inactive – The project has reached a stable, usable state but is no longer being actively developed; support/maintenance will be provided as time allows.](https://www.repostatus.org/badges/latest/inactive.svg)](https://www.repostatus.org/#inactive)

*This project is considered stable and no significant feature development is currently planned.*
*However, pull requests and issues are welcome: support/maintenance will be provided as time allows.*

This repository is a template for a custom pandoc document creation process that generates a PDF file and HTML from Markdown.
It includes an [automatic conversion](https://github.com/localthomas/pandoc-drawio) for [draw.io](https://www.diagrams.net/) files for integration into the Markdown sources.

## Requirements

The only dependency is the [nix package manager](https://nixos.org/download.html) with [flake support](https://nixos.wiki/wiki/Flakes).
All dependencies for building the output can be found in the [flake.nix](flake.nix) file and a wrapper for using `nix-shell` is provided in the [shell.nix](shell.nix) file.

Recommended tools for the development are Visual Studio Code with the following extensions:
* [arrterian.nix-env-selector](https://marketplace.visualstudio.com/items?itemName=arrterian.nix-env-selector) (required if any other extensions from this list are used)
* [james-yu.latex-workshop](https://marketplace.visualstudio.com/items?itemName=James-Yu.latex-workshop) (for formatting and linting of `*.tex` and `*.bib` files)
* [jnoortheen.nix-ide](https://marketplace.visualstudio.com/items?itemName=jnoortheen.nix-ide) (only for development of the `*.nix` files)

## Usage

These folders are relevant for the development of the document:
* `src/main.md`: the main entry point for compilation
  * `graphics` with
    * `drawio`: all `*.drawio` files are auto-converted into their required output image formats. This folder contains a `.gitignore` file that already ignores the auto-generated images. See [`main.md`](src/main.md) for an example.
    * `images`: the folder for all images that are ready without further pre-processing (does not include the `.gitignore` and therefore can contain normal image formats)
* `out`: contains the resulting data from the build script
* `result`: contains the result of the `nix build` building process

Enter the nix shell via `nix develop` or `nix-shell` and execute `./build-pdf.sh` (or `./build-html.sh`) for building the documents using caching.
This should provide shorter building times after the first execution and helps with fast iteration times.
The [VSCode task](https://code.visualstudio.com/docs/editor/tasks) `Build PDF` can be used to execute the build script as well.

For a reproducible build `nix build` is preferred, which builds the output in an isolated environment.
Note that network access is disabled and the system time is set to epoch, which means any usage of the compile time inside the documents might result in unexpected values (e.g. using latex `\today`).

#### License

Licensed under either of

 * Apache License, Version 2.0
   ([LICENSE-APACHE](LICENSES/Apache-2.0.txt) or http://www.apache.org/licenses/LICENSE-2.0)
 * MIT license
   ([LICENSE-MIT](LICENSES/MIT.txt) or http://opensource.org/licenses/MIT)

at your option.

#### Contribution

Unless you explicitly state otherwise, any contribution intentionally submitted
for inclusion in the work by you, as defined in the Apache-2.0 license, shall be
dual licensed as above, without any additional terms or conditions.
