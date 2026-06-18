proc main (uint64 L0x7fffffffd5e0, uint64 L0x7fffffffd5e8, uint64 L0x7fffffffd5f0, uint64 L0x7fffffffd5f8) =
{
  true
  &&
  limbs 64 [L0x7fffffffd5e0, L0x7fffffffd5e8, L0x7fffffffd5f0, L0x7fffffffd5f8] < (2**255 + 2**64)@256
}

(* snapshot input limbs (reduce overwrites z[0]/z[1]/z[3] in-place) *)
mov z_in_0 L0x7fffffffd5e0;
mov z_in_1 L0x7fffffffd5e8;
mov z_in_2 L0x7fffffffd5f0;
mov z_in_3 L0x7fffffffd5f8;

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
and r10@uint64 r10 0x7fffffffffffffff@uint64;
assert true && r10 = r10_low_63; assume r10 = r10_low_63 && true;
(* imul   $0x13,%r11,%r11                          #! PC = 0x4015fa *)
mull dontcare_hi r11 0x13@uint64 r11;
assert true && dontcare_hi = 0@uint64; assume dontcare_hi = 0 && true;
(* add    %r11,%r8                                 #! PC = 0x4015fe *)
adds carry r8 r8 r11;
(* adc    $0x0,%r9                                 #! PC = 0x401601 *)
adcs carry r9 r9 0x0@uint64 carry;
assert true && carry = 0@uint1; assume carry = 0 && true;
(* mov    %r8,(%rdi)                               #! EA = L0x7fffffffd5e0; PC = 0x401605 *)
mov L0x7fffffffd5e0 r8;
(* mov    %r9,0x8(%rdi)                            #! EA = L0x7fffffffd5e8; PC = 0x401608 *)
mov L0x7fffffffd5e8 r9;
(* mov    %r10,0x18(%rdi)                          #! EA = L0x7fffffffd5f8; PC = 0x40160c *)
mov L0x7fffffffd5f8 r10;

{
  eqmod (limbs 64 [L0x7fffffffd5e0, L0x7fffffffd5e8, L0x7fffffffd5f0, L0x7fffffffd5f8])
        (limbs 64 [z_in_0, z_in_1, z_in_2, z_in_3])
        ((2**255) - 19)
  &&
  limbs 64 [L0x7fffffffd5e0, L0x7fffffffd5e8, L0x7fffffffd5f0, L0x7fffffffd5f8] < (2**255)@256
}

