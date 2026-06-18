proc main (uint64 L0x7fffffffd5e0, uint64 L0x7fffffffd5e8, uint64 L0x7fffffffd5f8) =
{
  true
  &&
  true
}

(* gfp25519reduce: *)
gfp25519reduce:;
(* #! -> SP = 0x7fffffffd5b8 *)
#! 0x7fffffffd5b8 = 0x7fffffffd5b8;
(* mov    (%rdi),%r8                               #! EA = L0x7fffffffd5e0; Value = 0x2ae93f0b859c50f4; PC = 0x4015e0 *)
mov r8 L0x7fffffffd5e0;
(* mov    0x8(%rdi),%r9                            #! EA = L0x7fffffffd5e8; Value = 0x8ddd260caac8df0d; PC = 0x4015e3 *)
mov r9 L0x7fffffffd5e8;
(* mov    0x18(%rdi),%r10                          #! EA = L0x7fffffffd5f8; Value = 0x57ec84ab2e15c4b7; PC = 0x4015e7 *)
mov r10 L0x7fffffffd5f8;
(* mov    %r10,%r11                                #! PC = 0x4015eb *)
mov r11 r10;
(* shr    $0x3f,%r11                               #! PC = 0x4015ee *)
split r11 r10_low_63 r11 0x3f;
(* and    0x402008,%r10                            #! PC = 0x4015f2 *)
and r10@uint64 r10 0x402008@uint64;
(* imul   $0x13,%r11,%r11                          #! PC = 0x4015fa *)
imul   $0x13,%%r11,%%r11                          #! 0x4015fa = 0x4015fa;
(* add    %r11,%r8                                 #! PC = 0x4015fe *)
adds carry r8 r8 r11;
(* adc    $0x0,%r9                                 #! PC = 0x401601 *)
adcs carry r9 r9 0x0@uint64 carry;
(* mov    %r8,(%rdi)                               #! EA = L0x7fffffffd5e0; PC = 0x401605 *)
mov L0x7fffffffd5e0 r8;
(* mov    %r9,0x8(%rdi)                            #! EA = L0x7fffffffd5e8; PC = 0x401608 *)
mov L0x7fffffffd5e8 r9;
(* mov    %r10,0x18(%rdi)                          #! EA = L0x7fffffffd5f8; PC = 0x40160c *)
mov L0x7fffffffd5f8 r10;
(* #! <- SP = 0x7fffffffd5b8 *)
#! 0x7fffffffd5b8 = 0x7fffffffd5b8;
(* #ret                                            #! PC = 0x401610 *)
#ret                                            #! 0x401610 = 0x401610;

{
  true
  &&
  true
}

