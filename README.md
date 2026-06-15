# Term project: 驗證 `gf_p25519_mul.s`

把作業 asm 用 cryptoline 工具翻成 `.cl`,以 Hoare logic 驗證正確性。

## 背景

`.s` 是 `gfp25519mul` (z = x*y mod (2^255 - 19)) 的 x86-64 實作。流程:

1. schoolbook 4x4 limb 乘法
2. reduction:利用 `2^256 ≡ 38 (mod p)`,把高 256 bits 乘 38 加到低 256 bits
3. 微調:r11 的 bit 255 跟 rcx 視為高於 2^255 的部分,利用 `2^255 ≡ 19 (mod p)` 折回低位

## `gfp25519mul` 簡化步驟(`cl/mul/`)

每個編號對應 `cl/mul/NN_gf_p25519_mul.cl`。最終驗證:`cv -v cl/mul/08_gf_p25519_mul.cl`。

0. `to_zdsl.py` 原始草稿
1. cleanup:刪 proc 多餘參數、prologue、epilogue
2. 修 `and r11 r11 0x402008` → 常數值 `0x7fffffffffffffff`(0x402008 是 mask63 的 address)
3. 拆 `shld $0x1, %r11, %rcx` → `split r11_top r11_mid r11 63; shls bit_lost rcx_dbl rcx 1; adds add_co rcx rcx_dbl r11_top;`
4. 改 `imul $0x13, %rcx, %rcx` → `mull dontcare_hi rcx 0x13@uint64 rcx;`
5. 寫 postcondition `{ eqmod (limbs z) (x*y) ((2**255)-19) && limbs z < (2**255+2**64)@256 }`
6. schoolbook 4 row 每個 carry chain 結尾加 `assert + assume carry = 0`(7 處)
7. reduction + fix-up 加 6 個 `assert + assume`:38-fold carry、add-chain carry、final carry、`bit_lost`、`add_co`、`dontcare_hi`
8. reduction 前加 8-limb `assert + assume`(`limbs 64 [r8..rsi] = X*Y`)當 Singular checkpoint;`and r11 r11 0x7fff...` 換成 `mov r11 r11_mid`(借 step 3 split 結果,避開 bitwise)

## `gfp25519reduce` 簡化步驟(`cl/reduce/`)

precondition 用 mul 輸出 bound `< 2^255 + 2^64`,postcondition `eqmod (out) (in) p && out < 2^255`。
reduce 只讀 z[0]/z[1]/z[3](跳過 z[2]),carry 只傳到 z[1]。precondition 保證 bit 255 = 1 時 z[1] = z[2] = 0,carry 不會傳到 z[2] → 跳過 z[2] 安全。

每個編號對應 `cl/reduce/NN_gf_p25519_reduce.cl`。最終驗證:`cv -v cl/reduce/05_gf_p25519_reduce.cl`。

0. `to_zdsl.py` 原始草稿
1. cleanup:label、SP markers、`#ret`(reduce 無 prologue/epilogue)
2. `imul $0x13, %r11, %r11` → `mull dontcare_hi r11 0x13@uint64 r11;`;`and r10 r10 0x402008` → 常數值 `0x7fffffffffffffff`
3. 加 precondition `limbs < 2^255 + 2^64`、snapshot 4 limbs `z_in_*`、postcondition `eqmod && < 2^255`(reduce in-place 寫 z[0]/z[1]/z[3],snapshot 必要)
4. 加 `assert + assume`:`dontcare_hi = 0`、carry chain 末 `carry = 0`
5. `and r10 r10 0x7fff...` 換成 `mov r10 dc`(借 step 2 already-existing 的 `split r11 dc r11 0x3f` 輸出,避開 bitwise)

## 真實 tight bound:`< 2^255 + 2^11`

postcondition 寫 `< (2**255 + 2**64)@256` 是業界慣例(對齊 `pmp_farith` 等 examples),
實際真實上界更緊 — 實測:

| bound | cv 結果 |
|---|---|
| `< 2**255 + 2**11` | [OK] |
| `< 2**255 + 2**10` | [FAILED] |

推導:reduction 後 `rcx ≤ 38`,shld 後 `rcx_new ≤ 77`,× 19 後 `rcx_19 ≤ 1463`。
final adcs 鏈在 worst case 把 1463 加到 r8 並 carry 傳到 r11_masked(< 2^63),
最終 4-limb 上界 ≈ `2^255 + 1463 < 2^255 + 2^11 = 2^255 + 2048`。

寫 `+ 2^64` 鬆 `2^53` 倍,給「未來改動 reduction 步驟仍安全」的彈性。

## 為什麼 solver 不能自動判斷 `carry = 0`

Singular 看 polynomial(整數環),`carry` 是自由變數 ∈ {0,1},單從多項式結構不夠決定。Boolector 看 bit-vector 才推得出「rcx < 2^7 所以加 0 不溢位 → carry = 0」這類事實,但兩個 solver **不共享中間結論**。所以要 `assert`(Boolector 證) + `assume`(注入 Singular)手動橋接。

## 關於 `shld`

x86 `shld dst, src, n`:**Shift Left Double-precision** — `dst` 左移 `n` 位,
騰出的低位**從 `src` 高位填入**,`src` 不變。

```
shld $1, %r11, %rcx
  rcx_new = (rcx << 1) | (r11 >> 63)
  r11 不變
```

對應 reduction 用途:把「跨 bit 254/255 邊界」的兩 bit(r11 最高位 + rcx)
**整合成 rcx**,之後乘 19 摺回低位。

CL 沒對應指令,拆三步等價:

| asm | CL |
|---|---|
| `shld $1, %r11, %rcx` | `split r11_top r11_mid r11 63;` 抓 r11 最高 bit |
| | `shls bit_lost rcx_dbl rcx 1;` rcx 左移 1,溢出存 bit_lost |
| | `adds add_co rcx rcx_dbl r11_top;` 把 r11_top 拼進 rcx |

`bit_lost = 0` 跟 `add_co = 0` 之後 assert + assume(rcx 已知很小,左移不溢位)。

## 關於 `imul` 3-operand

x86 `imul $imm, %src, %dst`(3-operand 形式):`dst = src * imm`,**只取低 64 位**。

CryptoLine 的 `x86_64.rules` 只有 2-operand `imul` 規則,3-operand 沒對應。用 `mull` 全寬乘代替:

| asm | CL |
|---|---|
| `imul $0x13, %rcx, %rcx` | `mull dontcare_hi rcx 0x13@uint64 rcx;` |

`mull h l a b` 算 `h * 2^64 + l = a * b`,把高 64 位放 `dontcare_hi`、低 64 位放 `rcx`。
之後 `assert + assume dontcare_hi = 0`(rcx < 2^60,所以 `19 * rcx < 2^64`,高位必為 0)。

這樣 algebraic solver 看到的等式跟 `imul` 一致(只取低 64)。

## 驗證

```bash
cv -v cl/09_gf_p25519_mul.cl
```

### 編譯 + 執行

```bash
cd test
gcc -no-pie -o top top.c ../gas/gf_p25519_mul.s
./top
```

`-no-pie` 因為 asm 直接引用全域 symbol `mask63`(非 PIE-safe relocation)。

### `gfp25519reduce` 失效範圍

mul 保證輸出 `< 2^255 + 2^64`,因此只有第一列實際可達:

| 輸入範圍 | bit 255 | reduce 動作 | 輸出 | canonical? |
|---|---|---|---|---|
| `[p, 2^255)`(19 個值) | 0 | 不動 | 同 input,仍 >= p | ✗ |
| `[2^255, 2p)` | 1 | fold(-p) | input - p ∈ `[19, p)` | ✓ |

### Production 慣例:constant-time canonical

實際使用 `mul` 後通常接 `reduce` + constant-time canonical step(避免 timing leak)。openssl x25519 範例:

```asm
sbb    %rax,%rax     ; mask = 0xFF..FF if carry else 0
and    $0x26,%rax    ; mask &= 38
add    %rax,%r8      ; 永遠 add(加 0 = no-op)
```

固定指令流、無 branch,把「conditional subtract p」轉成 mask + 無條件 add。

### 為什麼 +38

`p = 2^255 - 19`,所以 `2^256 = 2(p+19) = 2p + 38 ≡ 38 (mod p)`。

前段運算若 carry = 1,真實值 = `(低 256 bits) + 1 × 2^256`。
把 carry 摺回:加 `1 × 38` 到低 256 → 同餘 mod p。
4-limb 內的 add 若 wrap,carry 經 `adc` chain 往上傳,結果仍 fits 4-limb 且同餘。
