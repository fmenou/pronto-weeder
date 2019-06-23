# Pronto runner for Weeder

[![Build Status](https://travis-ci.org/fretlink/pronto-weeder.svg?branch=master)](https://travis-ci.org/fretlink/pronto-weeder)
[![Gem Version](https://badge.fury.io/rb/pronto-weeder.svg)](http://badge.fury.io/rb/pronto-weeder)

Pronto runner for [Weeder](https://hackage.haskell.org/package/weeder), pluggable linting utility for Haskell. [What is Pronto?](https://github.com/mmozuras/pronto)

## Prerequisites

You'll need to install [weeder by yourself with cabal or stack][weeder-install]. If `weeder` is in your `PATH`, everything will simply work, otherwise you have to provide pronto-weeder your custom executable path (see [below](#configuration-of-weeder)).

[weeder-install]: https://github.com/ndmitchell/weeder/#weeder----

## Configuration of Weeder

Configuring Weeder via [.weeder.yaml][.weeder.yaml] will work just fine with pronto-weeder.

[.weeder.yaml]: https://github.com/ndmitchell/weeder/#ignoring-weeds

## Configuration of Pronto-Weeder

pronto-weeder can be configured by placing a `.pronto_weeder.yml` inside the directory where pronto will run.

Following options are available:

| Option            | Meaning                                                                                  | Default                             |
| ----------------- | ---------------------------------------------------------------------------------------- | ----------------------------------- |
| weeder_executable | Weeder executable to call.                                                               | `weeder` (calls `weeder` in `PATH`) |
| files_to_lint     | What files to lint. Absolute path of offending file will be matched against this Regexp. | `(\.hs)$`                           |
| cmd_line_opts     | Command line options to pass to weeder when running                                      | ``                                  |

Example configuration to call custom weeder executable and only lint files ending with `.my_custom_extension`:

```yaml
# .pronto_weeder.yml
weeder_executable: '/my/custom/path/.bin/weeder'
files_to_lint: '\.my_custom_extension$'
cmd_line_opts: '-j $(nproc) --typecheck'
```
