# DDR2 and DDR3
#### RTL Implementation

Generally speaking, this project is to wite a so-called [ddr_controller.v]() to control this DDR to do all the read and write operations. Of course you need to be very familiar with the specs of the DDR, so as to let the FIFOs, buffer etc, cooperate well and the timing protocols.<br />
![image] (https://dl.dropboxusercontent.com/s/il4y5c0wc0xtiod/ddr.png?dl=0) <br />
Knowing that, here comes the upgraded fancy version of read and write. We have to let the DDR perform operations like:
<b>Scalar Read and Write, Block Read and Write and Atomic Read and Write</b>. And we went more detailed with different block sizes and different kinds of atomic operations.<br />
So we wrote the [Processing_logic.v]() and the ring buffer [ddr2_ring_buffer8.v]() to make things clear and organised.<br />
Simply speaking, when you read a block of data instead of just one single unit, you could save the data temporarily in this ring buffer. Then you could take your time to let the data out to the port in whatever sequence you like. [Processing_logic.v]() is where we deal with different kinds of operations. So all [ddr_controller.v]() needs to do is interface only.

#### Synthesis
To narrow the clock period so as to let the DDR run in its favourate frequency, we really spent some nights. 
I used the tools <b>Design Compiler and the GUI Design Vision</b> to locate and analyze the longest path, then modify the RTL to cut that path short. Actually our group was kind of lucky, because we only modified two paths and it's done.  <br />

Still, tt made me realized how important it is to use "reg" instead of "wire" in a design. Especially when the project is a big one which contains several parts. If you use a "wire" as the connection between two parts, you'll suffer.

And as I knew, many other group sufferred because of FIFO. You don't need a complicate design, and it's used everywhere. So the more concise your FIFO, the easier your job.

#### Post Synthesis and Automatic Layout

(to be continued...)
