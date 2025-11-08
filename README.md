# SwiftDDC

DDC Library for Apple Silicon Macs + ddc cli

## Usage - library

See example `ddc` code.

For sample implementation take a look at the source code of [MonitorControl](https://github.com/MonitorControl/MonitorControl) (as `Arm64DDC.swift` in the project)

Please mention this repo publicly if used. :)

## Usage - CLI

**Warning**: This CLI is for DDC/CI (protocol) and not for MCCS (command set) and some displays only partially adhere to MCCS (e.g. store unexpected data in MH/SH or invalid in ML). It's outside the scope of this program to interpret/correct it. Only `--verify-single` (or `--noverify`) can be used to bypass such issues.

### Building

```bash
swift build
./.build/arm64-apple-macosx/debug/ddc --help
```

### CLI syntax

`ddc --help`

```
OVERVIEW: SwiftDDC

USAGE: ddc <subcommand>

OPTIONS:
  -h, --help              Show help information.

SUBCOMMANDS:
  detect (default)        Detect connected display.
  getvcp                  Read value for given VCP.
  setvcp                  Sets value for given VCP.
  capabilities            Qeuery all VCPs.

  See 'ddc help <subcommand>' for detailed help.
```

`ddc detect --help`

```
OVERVIEW: Detect connected display.

USAGE: ddc detect

OPTIONS:
  -h, --help              Show help information.
```

`ddc getvcp --help`

```
OVERVIEW: Read value for given VCP.

USAGE: ddc getvcp [--terse] [--sn <sn>] [--display <display>] [--edid <edid>] <vcp>

ARGUMENTS:
  <vcp>                   Raw VCP code (decimal or hex prefixed with 0x or x)

OPTIONS:
  --terse                 Terse output (similar to ddcutil --terse)
  -n, --sn <sn>           Alphanumeric serial number of target device. If omitted, first working display will be tried.
  -d, --display, --dis <display>
                          ioDisplayLocation of target device. If omitted, first working display will be tried.
  -e, --edid <edid>       EDID of target device. If omitted, first working display will be tried.
  -h, --help              Show help information.
```

`ddc setvcp --help`

```
OVERVIEW: Sets value for given VCP.

USAGE: ddc setvcp [--noverify] [--verify-single] [--terse] [--sn <sn>] [--display <display>] [--edid <edid>] <vcp> <value>

ARGUMENTS:
  <vcp>                   Raw VCP code (decimal or hex prefixed with 0x or x)
  <value>                 Raw VCP value (decimal or hex prefixed with 0x or x)

OPTIONS:
  --noverify              Do not read VCP value after setting it
  --verify-single         Read VCP value after setting it, but only check lower byte
  --terse                 Terse output (similar to ddcutil --terse)
  -n, --sn <sn>           Alphanumeric serial number of target device. If omitted, first working display will be tried.
  -d, --display, --dis <display>
                          ioDisplayLocation of target device. If omitted, first working display will be tried.
  -e, --edid <edid>       EDID of target device. If omitted, first working display will be tried.
  -h, --help              Show help information.
```

`ddc capabilities --help`

```
OVERVIEW: Qeuery all VCPs.

USAGE: ddc capabilities [--terse] [--sn <sn>] [--display <display>] [--edid <edid>]

OPTIONS:
  --terse                 Terse output (similar to ddcutil --terse)
  -n, --sn <sn>           Alphanumeric serial number of target device. If omitted, first working display will be tried.
  -d, --display, --dis <display>
                          ioDisplayLocation of target device. If omitted, first working display will be tried.
  -e, --edid <edid>       EDID of target device. If omitted, first working display will be tried.
  -h, --help              Show help information.
```