1. 
```bash
make
```

2. 
```bash
qemu-system-i386 -fda build/main.img
# or
qemu-system-i386 -fda build/main.img -nographic -serial mon:stdio
```

3. if use -nographic -serial mon:stdio
to quit the qemu press `CTRL+A` and then press `X`
