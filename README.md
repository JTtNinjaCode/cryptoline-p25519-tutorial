# Term project: 驗證 `gf_p25519_mul.s`

把作業 asm 用 cryptoline 工具翻成 `.cl`,以 Hoare logic 驗證正確性。

## 背景

`.s` 是 `gfp25519mul` (z = x*y mod (2^255 - 19)) 的 x86-64 實作。流程:

1. schoolbook 4x4 limb 乘法
2. reduction:利用 `2^256 ≡ 38 (mod p)`,把高 256 bits 乘 38 加到低 256 bits
3. 微調:r11 的 bit 255 跟 rcx 視為高於 2^255 的部分,利用 `2^255 ≡ 19 (mod p)` 折回低位

## 簡化步驟

先做 cleanup(0–1),之後跑 `cv -p` / `cv` 看錯誤訊息,**iteratively** 修。

0. `00_gf_p25519_mul.cl` — `to_zdsl.py` 原始草稿
1. cleanup:proc 多餘參數、prologue、epilogue
2. 修 `and r11 r11 0x402008` → 直接用常數值 `0x7fffffffffffffff`(0x402008 是 mask63 的 **address**,不是值)
3. `cv -p` 在 `shld` 卡住, 需要手寫 → 拆 `split r11_top r11_mid r11 63; shls bit_lost rcx_dbl rcx 1; adds add_co rcx rcx_dbl r11_top;`
4. `cv -p` 在 `imul` 卡住, 需要手寫 改 `mull dontcare_hi rcx 0x13@uint64 rcx;`
5. `cv -p` 可以通過, 寫 postcondition `{ eqmod (limbs z) (x*y) ((2**255)-19) && limbs z < (2**255+2**64)@256 }`
6. `cv` → algebraic spec FAIL,**schoolbook 部分** 4 row 每個 `adcs ... 0x0@uint64 carry;` 後面加 `assert true && carry = 0@uint1; assume carry = 0 && true;`(7 處:Row 0 + Row 1/2/3 各 partial 與 shifted-add)
7. `cv` 仍 FAIL → **reduction + fix-up** 加 6 個 assert+assume:38-fold 結尾 carry、add-chain 結尾 carry、final 4-limb chain 結尾 carry + shld 拆寫的 `bit_lost` 與 `add_co` + imul 換的 `dontcare_hi`
8. `cv` 仍 FAIL → reduction 前加 8-limb `assert + assume`(`limbs 64 [r8..rsi] = (limbs x) * (limbs y)`)讓 Singular 有 checkpoint;同時把 step 2 的 `and r11 r11 0x7fff...` 換成 `mov r11 r11_mid;`(用 step 3 split 結果)— `and` 是 bitwise,Singular 需 per-bit polynomial 推理,長鏈下會卡;`mov` 直接借代數等式 `r11 = r11_top × 2^63 + r11_mid`,polynomial 乾淨
9. `cv` → [OK]

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
