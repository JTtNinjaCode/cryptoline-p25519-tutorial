proc main (uint64 L0x7fffffffd620, uint64 L0x7fffffffd628, uint64 L0x7fffffffd630, uint64 L0x7fffffffd638, uint64 L0x7fffffffd640, uint64 L0x7fffffffd648, uint64 L0x7fffffffd650, uint64 L0x7fffffffd658) =
{
  true
  &&
  true
}

(* mov    (%rdi),%rdx                              #! EA = L0x7fffffffd640; Value = 0x0123456789abcdef; PC = 0x4012f1 *)
mov rdx L0x7fffffffd640;
(* mulx   (%rsi),%r8,%r9                           #! EA = L0x7fffffffd620; Value = 0xdeadbeefcafebabe; PC = 0x4012f4 *)
mull r9 r8 rdx L0x7fffffffd620;
(* mulx   0x8(%rsi),%rcx,%r10                      #! EA = L0x7fffffffd628; Value = 0x1234567890abcdef; PC = 0x4012f9 *)
mull r10 rcx rdx L0x7fffffffd628;
(* add    %rcx,%r9                                 #! PC = 0x4012ff *)
adds carry r9 r9 rcx;
(* mulx   0x10(%rsi),%rcx,%r11                     #! EA = L0x7fffffffd630; Value = 0xfedcba9876543210; PC = 0x401302 *)
mull r11 rcx rdx L0x7fffffffd630;
(* adc    %rcx,%r10                                #! PC = 0x401308 *)
adcs carry r10 r10 rcx carry;
(* mulx   0x18(%rsi),%rcx,%r12                     #! EA = L0x7fffffffd638; Value = 0x0fedcba987654321; PC = 0x40130b *)
mull r12 rcx rdx L0x7fffffffd638;
(* adc    %rcx,%r11                                #! PC = 0x401311 *)
adcs carry r11 r11 rcx carry;
(* adc    $0x0,%r12                                #! PC = 0x401314 *)
adcs carry r12 r12 0x0@uint64 carry;
assert true && carry = 0@uint1; assume carry = 0 && true;
(* mov    0x8(%rdi),%rdx                           #! EA = L0x7fffffffd648; Value = 0xfedcba9876543210; PC = 0x401318 *)
mov rdx L0x7fffffffd648;
(* mulx   (%rsi),%rax,%rbx                         #! EA = L0x7fffffffd620; Value = 0xdeadbeefcafebabe; PC = 0x40131c *)
mull rbx rax rdx L0x7fffffffd620;
(* mulx   0x8(%rsi),%rcx,%rbp                      #! EA = L0x7fffffffd628; Value = 0x1234567890abcdef; PC = 0x401321 *)
mull rbp rcx rdx L0x7fffffffd628;
(* add    %rcx,%rbx                                #! PC = 0x401327 *)
adds carry rbx rbx rcx;
(* mulx   0x10(%rsi),%rcx,%r15                     #! EA = L0x7fffffffd630; Value = 0xfedcba9876543210; PC = 0x40132a *)
mull r15 rcx rdx L0x7fffffffd630;
(* adc    %rcx,%rbp                                #! PC = 0x401330 *)
adcs carry rbp rbp rcx carry;
(* mulx   0x18(%rsi),%rcx,%r13                     #! EA = L0x7fffffffd638; Value = 0x0fedcba987654321; PC = 0x401333 *)
mull r13 rcx rdx L0x7fffffffd638;
(* adc    %rcx,%r15                                #! PC = 0x401339 *)
adcs carry r15 r15 rcx carry;
(* adc    $0x0,%r13                                #! PC = 0x40133c *)
adcs carry r13 r13 0x0@uint64 carry;
assert true && carry = 0@uint1; assume carry = 0 && true;
(* add    %rax,%r9                                 #! PC = 0x401340 *)
adds carry r9 r9 rax;
(* adc    %rbx,%r10                                #! PC = 0x401343 *)
adcs carry r10 r10 rbx carry;
(* adc    %rbp,%r11                                #! PC = 0x401346 *)
adcs carry r11 r11 rbp carry;
(* adc    %r15,%r12                                #! PC = 0x401349 *)
adcs carry r12 r12 r15 carry;
(* adc    $0x0,%r13                                #! PC = 0x40134c *)
adcs carry r13 r13 0x0@uint64 carry;
assert true && carry = 0@uint1; assume carry = 0 && true;
(* mov    0x10(%rdi),%rdx                          #! EA = L0x7fffffffd650; Value = 0x5555555555555555; PC = 0x401350 *)
mov rdx L0x7fffffffd650;
(* mulx   (%rsi),%rax,%rbx                         #! EA = L0x7fffffffd620; Value = 0xdeadbeefcafebabe; PC = 0x401354 *)
mull rbx rax rdx L0x7fffffffd620;
(* mulx   0x8(%rsi),%rcx,%rbp                      #! EA = L0x7fffffffd628; Value = 0x1234567890abcdef; PC = 0x401359 *)
mull rbp rcx rdx L0x7fffffffd628;
(* add    %rcx,%rbx                                #! PC = 0x40135f *)
adds carry rbx rbx rcx;
(* mulx   0x10(%rsi),%rcx,%r15                     #! EA = L0x7fffffffd630; Value = 0xfedcba9876543210; PC = 0x401362 *)
mull r15 rcx rdx L0x7fffffffd630;
(* adc    %rcx,%rbp                                #! PC = 0x401368 *)
adcs carry rbp rbp rcx carry;
(* mulx   0x18(%rsi),%rcx,%r14                     #! EA = L0x7fffffffd638; Value = 0x0fedcba987654321; PC = 0x40136b *)
mull r14 rcx rdx L0x7fffffffd638;
(* adc    %rcx,%r15                                #! PC = 0x401371 *)
adcs carry r15 r15 rcx carry;
(* adc    $0x0,%r14                                #! PC = 0x401374 *)
adcs carry r14 r14 0x0@uint64 carry;
assert true && carry = 0@uint1; assume carry = 0 && true;
(* add    %rax,%r10                                #! PC = 0x401378 *)
adds carry r10 r10 rax;
(* adc    %rbx,%r11                                #! PC = 0x40137b *)
adcs carry r11 r11 rbx carry;
(* adc    %rbp,%r12                                #! PC = 0x40137e *)
adcs carry r12 r12 rbp carry;
(* adc    %r15,%r13                                #! PC = 0x401381 *)
adcs carry r13 r13 r15 carry;
(* adc    $0x0,%r14                                #! PC = 0x401384 *)
adcs carry r14 r14 0x0@uint64 carry;
assert true && carry = 0@uint1; assume carry = 0 && true;
(* mov    0x18(%rdi),%rdx                          #! EA = L0x7fffffffd658; Value = 0x6666666666666666; PC = 0x401388 *)
mov rdx L0x7fffffffd658;
(* mulx   (%rsi),%rax,%rbx                         #! EA = L0x7fffffffd620; Value = 0xdeadbeefcafebabe; PC = 0x40138c *)
mull rbx rax rdx L0x7fffffffd620;
(* mulx   0x8(%rsi),%rcx,%rbp                      #! EA = L0x7fffffffd628; Value = 0x1234567890abcdef; PC = 0x401391 *)
mull rbp rcx rdx L0x7fffffffd628;
(* add    %rcx,%rbx                                #! PC = 0x401397 *)
adds carry rbx rbx rcx;
(* mulx   0x10(%rsi),%rcx,%r15                     #! EA = L0x7fffffffd630; Value = 0xfedcba9876543210; PC = 0x40139a *)
mull r15 rcx rdx L0x7fffffffd630;
(* adc    %rcx,%rbp                                #! PC = 0x4013a0 *)
adcs carry rbp rbp rcx carry;
(* mulx   0x18(%rsi),%rcx,%rsi                     #! EA = L0x7fffffffd638; Value = 0x0fedcba987654321; PC = 0x4013a3 *)
mull rsi rcx rdx L0x7fffffffd638;
(* adc    %rcx,%r15                                #! PC = 0x4013a9 *)
adcs carry r15 r15 rcx carry;
(* adc    $0x0,%rsi                                #! PC = 0x4013ac *)
adcs carry rsi rsi 0x0@uint64 carry;
assert true && carry = 0@uint1; assume carry = 0 && true;
(* add    %rax,%r11                                #! PC = 0x4013b0 *)
adds carry r11 r11 rax;
(* adc    %rbx,%r12                                #! PC = 0x4013b3 *)
adcs carry r12 r12 rbx carry;
(* adc    %rbp,%r13                                #! PC = 0x4013b6 *)
adcs carry r13 r13 rbp carry;
(* adc    %r15,%r14                                #! PC = 0x4013b9 *)
adcs carry r14 r14 r15 carry;
(* adc    $0x0,%rsi                                #! PC = 0x4013bc *)
adcs carry rsi rsi 0x0@uint64 carry;
assert true && carry = 0@uint1; assume carry = 0 && true;
(* mov    $0x26,%rdx                               #! PC = 0x4013c0 *)
mov rdx 0x26@uint64;
(* mulx   %r12,%r12,%rbx                           #! PC = 0x4013c7 *)
mull rbx r12 rdx r12;
(* mulx   %r13,%r13,%rcx                           #! PC = 0x4013cc *)
mull rcx r13 rdx r13;
(* add    %rbx,%r13                                #! PC = 0x4013d1 *)
adds carry r13 r13 rbx;
(* mulx   %r14,%r14,%rbx                           #! PC = 0x4013d4 *)
mull rbx r14 rdx r14;
(* adc    %rcx,%r14                                #! PC = 0x4013d9 *)
adcs carry r14 r14 rcx carry;
(* mulx   %rsi,%r15,%rcx                           #! PC = 0x4013dc *)
mull rcx r15 rdx rsi;
(* adc    %rbx,%r15                                #! PC = 0x4013e1 *)
adcs carry r15 r15 rbx carry;
(* adc    $0x0,%rcx                                #! PC = 0x4013e4 *)
adcs carry rcx rcx 0x0@uint64 carry;
(* add    %r12,%r8                                 #! PC = 0x4013e8 *)
adds carry r8 r8 r12;
(* adc    %r13,%r9                                 #! PC = 0x4013eb *)
adcs carry r9 r9 r13 carry;
(* adc    %r14,%r10                                #! PC = 0x4013ee *)
adcs carry r10 r10 r14 carry;
(* adc    %r15,%r11                                #! PC = 0x4013f1 *)
adcs carry r11 r11 r15 carry;
(* adc    $0x0,%rcx                                #! PC = 0x4013f4 *)
adcs carry rcx rcx 0x0@uint64 carry;
(* shld   $0x1,%r11,%rcx — spelled out *)
split r11_top r11_low_63 r11 63;
shls bit_lost rcx_dbl rcx 1;
adds add_co rcx rcx_dbl r11_top;
(* and    0x402008,%r11                            #! PC = 0x4013fd *)
and r11@uint64 r11 0x7fffffffffffffff@uint64;
(* imul   $0x13,%rcx,%rcx                          #! PC = 0x401405 *)
mull dontcare_hi rcx 0x13@uint64 rcx;
(* add    %rcx,%r8                                 #! PC = 0x401409 *)
adds carry r8 r8 rcx;
(* adc    $0x0,%r9                                 #! PC = 0x40140c *)
adcs carry r9 r9 0x0@uint64 carry;
(* adc    $0x0,%r10                                #! PC = 0x401410 *)
adcs carry r10 r10 0x0@uint64 carry;
(* adc    $0x0,%r11                                #! PC = 0x401414 *)
adcs carry r11 r11 0x0@uint64 carry;
(* mov    %r8,(%rdi)                               #! EA = L0x7fffffffd660; PC = 0x40141d *)
mov L0x7fffffffd660 r8;
(* mov    %r9,0x8(%rdi)                            #! EA = L0x7fffffffd668; PC = 0x401420 *)
mov L0x7fffffffd668 r9;
(* mov    %r10,0x10(%rdi)                          #! EA = L0x7fffffffd670; PC = 0x401424 *)
mov L0x7fffffffd670 r10;
(* mov    %r11,0x18(%rdi)                          #! EA = L0x7fffffffd678; PC = 0x401428 *)
mov L0x7fffffffd678 r11;

{
  eqmod (limbs 64 [L0x7fffffffd660, L0x7fffffffd668, L0x7fffffffd670, L0x7fffffffd678])
        ((limbs 64 [L0x7fffffffd620, L0x7fffffffd628, L0x7fffffffd630, L0x7fffffffd638]) *
         (limbs 64 [L0x7fffffffd640, L0x7fffffffd648, L0x7fffffffd650, L0x7fffffffd658]))
        ((2**255) - 19)
  &&
  limbs 64 [L0x7fffffffd660, L0x7fffffffd668, L0x7fffffffd670, L0x7fffffffd678] < (2**255 + 2**64)@256
}

