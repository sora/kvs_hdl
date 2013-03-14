### KVS_HDL

A minimal implementation for CPU-less Key-Value Store on FPGA. See [Spec and Design](https://github.com/sora/kvs_hdl/wiki/Spec-and-Design).

**Simulation on OSX**

```
$ brew install icarus-verilog gtkwave
$ cd cores/kvs/test
$ make
$ make wave
```
------------------------

**Supported FPGA board**

* [Lattice ECP3 Versa Development Kit](http://www.latticesemi.com/products/developmenthardware/developmentkits/ecp3versadevelopmentkit/index.cfm)
* ~~NetFPGA-1G~~

**Sources**

```
/boards/ecp3versa/synthesis           -- project files
/boards/ecp3versa/rtl/kvs_hdl_top.v   -- top module
/cores/crc32/rtl/crc32.v              -- generate ethernet FCS
/cores/crc16/rtl/crc16.v              -- generate hashkey
/cores/kvs/rtl/kvs.v                  -- Key-Value Store module
```
