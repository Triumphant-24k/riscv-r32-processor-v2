# Instruction walkthroughs

The core is stallable and non-pipelined. Fetch request, fetch response, execute,
and any data request/response occupy explicit states. PC and architectural state
remain stable under backpressure; register write-back occurs on completion.

## Register operation: `sub x3, x1, x2`

Decode selects both register operands and ALU subtraction. No memory control is
asserted. At the edge, the result is written to `x3` and PC advances by four.

## Immediate operation: `srai x4, x3, 31`

Decode validates the `0100000` upper bits. The ALU performs signed `>>>` using
only the low five shift bits, writes `x4`, and advances PC.

## Load: `lhu x5, 2(x6)`

The ALU adds the I immediate to `x6`. Memory returns the containing aligned
word; the load/store unit selects bits 31:16 and zero-extends them. An odd
address traps before write-back.

## Store: `sb x7, 3(x6)`

The low byte of `x7` is replicated across the write-data lanes and
`data_wstrb=1000`, so only offset 3 changes. No register is written.

## Branch: `blt x1, x2, loop`

The branch unit compares signed operands. A true result selects PC plus the B
immediate; false selects PC+4. A taken target not divisible by four traps.

## Upper immediate: `auipc x8, 0x12345`

The U immediate `0x12345000` is added to the current PC and written to `x8`.

## Jump: `jalr x1, 0(x5)`

PC+4 is the link value. The target is `x5` plus the I immediate with bit zero
cleared. A remaining set bit 1 traps and suppresses the link write.

## System: `ecall`

The core latches `trap_valid`, cause 11, and the faulting PC, then halts until
reset. The faulting instruction cannot update register or memory state.
