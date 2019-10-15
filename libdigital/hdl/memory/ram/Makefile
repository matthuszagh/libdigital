# formal:
# 	sby ram.sby

synth: synth.ilang

synth.ilang: synth.ys
	yosys synth.ys

xilinx: synth xilinx.ys
	yosys xilinx.ys

clean:
	rm *.ilang

.PHONY: clean synth xilinx
