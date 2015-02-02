# DDR2 Controller
Generally speaking, what I did in this project:
- Designed and implemented a DDR2 controller in Verilog HDL and simulated the designs along with Denali’s DDR2 model using Cadence NC-Verilog. 
- Synthesized the entire design with Synopsys Design Compiler. 
- Ran post-synthesis simulation and verified the correct operation of the synthesized design.

#### RTL Implementation (Pre-synthesis)
- The DDR2 controller provided a simple FIFO based front-end that would support write and read transactions like scalar, block and atomic to and from the DDR2 SDRAM.
- All timing, bus interface and initialization specifications are refering from [the JEDEC DDR2 SDRAM Standard (JESD79-2C)]().
- The controller would initialize the DDR2 model (chip) with the given parameters like CAS latency and Burst length etc. Normal data transactions would start after a successful completion of the DDR2 initialization sequence.

![image] (https://dl.dropboxusercontent.com/s/il4y5c0wc0xtiod/ddr.png?dl=0) <br />


So we wrote the [Processing_logic.v]() and the ring buffer [ddr2_ring_buffer8.v]() to make things clear and organised.<br />
Simply speaking, when you read a block of data instead of just one single unit, you could save the data temporarily in this ring buffer. Then you could take your time to let the data out to the port in whatever sequence you like. [Processing_logic.v]() is where we deal with different kinds of operations. So all [ddr_controller.v]() needs to do is interface only.

#### Synthesis
To narrow the clock period so as to let the DDR run in its favourate frequency, we really spent some nights. 
I used the tools <b>Design Compiler and the GUI Design Vision</b> to locate and analyze the longest path, then modify the RTL to cut that path short. Actually our group was kind of lucky, because we only modified two paths and it's done.  <br />

Still, tt made me realized how important it is to use "reg" instead of "wire" in a design. Especially when the project is a big one which contains several parts. If you use a "wire" as the connection between two parts, you'll suffer.

And as I knew, many other group sufferred because of FIFO. You don't need a complicate design, and it's used everywhere. So the more concise your FIFO, the easier your job.

#### Post Synthesis and Automatic Layout

(to be continued...)
