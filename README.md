# SPF - Stress ProDOS Filesystem

The purpose of SPF is simple: to stress-test the ProDOS filesystem.  It can do that in two ways:

 * Writes, reads and verifies every byte of a volume
 * Benchmarks the time to read and write files and complete volume block-by-block reads

SPF comes on a virtual disk image that can be reconstituted to a physical floppy via ADTPro, or mounted as a virtual floppy disk image on the CFFA3000.  The disk a bootable ProDOS volume, and will start up with a simple menu that lets you either start SPF, or quit to Applesoft BASIC.
