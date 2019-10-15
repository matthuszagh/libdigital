test:
	iverilog -DPACKET_SIMULATE packet.v -o tb/packet_tb
	./tb/packet_tb
	gtkwave tb/packet_tb.vcd
