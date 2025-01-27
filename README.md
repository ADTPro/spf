# SPF - Stress ProDOS Filesystem

The purpose of SPF is simple: to stress-test the ProDOS filesystem.  It can do that in two ways:

 * Writes, reads and verifies every byte of a volume
 * Benchmarks the time to read and write files and complete volume block-by-block reads

SPF comes on a virtual disk image that can be reconstituted to a physical floppy via ADTPro, or mounted as a virtual floppy disk image on the CFFA3000.  The disk a bootable ProDOS volume, and will start up with a simple menu that lets you either start SPF, or quit to Applesoft BASIC.

## Timing Functionality

SPF has the ability to do some rough timing calculations for what might loosely be termed "benchmarking."
An internal clock on the Apple side is required for this functionality to be enabled.  Supported clock protocols include:

 1. IIgs built-in clock
 2. NoSlotClock
 3. Thunderclock

Additional slot-based clocks (such as the Thunderclock) can be added as long as firmware can be detectected and the time-getting routine is added.
All clock functionality is implemented in [src/prodos/gettime.asm](https://github.com/ADTPro/spf/blob/master/src/prodos/gettime.asm).
