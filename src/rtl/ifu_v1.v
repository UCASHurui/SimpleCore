/*
  Basic functions and interface of IFU module
  1. IFU的PC生成单元产生下一条指令的PC。
     The PC generator generates the Program Counter(PC) of next instruction
  2. 该PC传输到地址判断和ICB生成单元，就是根据PC值产生相应读指请求，可能的指令目的是ITCM或者外部存储，外部存储通过BIU访问。
     Such PC is then transmitted to address discriminator and ICB generator, loading instruction request is generated according to PC, possible destination are ITCM or external memory.
     external memory is read through BIU. 
  3. 该PC值也会传输到和EXU单元接口的PC寄存器中。
     Such is PC is also transmitted to PC register interfaced with EXU unit. 
  4. 取回的指令会放置到和EXU接口的IR(Instruction register)寄存器中。EXU单元会根据指令和其对应的PC值进行后续的操作。
  5. 因为每个周期都要产生下一条指令的PC，所以取回的指令也会传入Mini-Decode单元，进行简单的译码操作，判别当前指令是普通指令还是分支跳转指令。
     如果判别为分支跳转指令，则在同一周期进行分支预测。
     最后，根据译码的信息和分支预测的信息生成下一条指令的PC。
  6. 来自commit模块的冲刷管线请求会复位PC值。
*/