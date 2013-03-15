SIM_SRC=tb_kvs.v ../../crc32/rtl/crc32.v ../../crc16/rtl/crc16.v ../rtl/kvs.v

test: request.hex isim

tb_system: $(SIM_SRC)
	iverilog -o tb_system $(SIM_SRC)

isim: tb_system
	./tb_system

wave: test
	gtkwave test.vcd

clean:
	rm -f tb_system verilog.log test.vcd

.PHONY: clean isim wave
