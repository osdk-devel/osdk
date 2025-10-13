# CONTRIBUTING

```bash
cmake -b build
cd build
make -j8
```

Compile Operating System Using OSDK
```bash
osdk program.c -o program.elf
obsect -Target=BIOS program.elf -o os.flp
```