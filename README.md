# Term project: 驗證 `gf_p25519_mul.s`

`.s` 是 x86-64 實作, 包含兩個 function:
- `gfp25519mul`: z = x*y mod p, 輸出 loose form (`< 2^255 + 2^11`)
- `gfp25519reduce`: loose reduce, 把 `< 2^255 + 2^64` 再收窄到 `< 2^255`

`cl/` 下共有兩個資料夾, 包含 `cl/mul`, `cl/reduce`, 分別驗證 `gf_p25519_mul.s` 的兩個 function, 兩個資料夾內的檔案都從 00 開始編號, 每一版都只修改一點內容, 可使用 `diff` 檢查兩兩檔案之間的差別, 最後版本的檔案是最終板, 可用 `cv -v` 驗證

## `gfp25519mul` 簡化步驟

0. 使用 `trace.py` 抓到的 gas 透過 `to_zdsl.py` 轉出的原始草稿
1. cleanup: 刪 label, 多餘參數、prologue, epilogue, return(含 `mov rdi L0x..d610` 這是 asm epilogue 從 stack 撈回 z 指標, 因 mulx 強制用 rdx → y 指標被借到 rdi → z 指標暫存 stack, CL 無記憶體, itrace 已經把 `0(%rdi)` 解析成 `L0x..d660` 寫死, 故 rdi 在 CL 是 dead code)
2. 修 `and r11 r11 0x402008`, 改成常數值 `0x7fffffffffffffff`(0x402008 是 mask63 的 address)
3. 改 `shld $0x1, %r11, %rcx`, 轉成 `split r11_top r11_low_63 r11 63; shls bit_lost rcx_dbl rcx 1; adds add_co rcx rcx_dbl r11_top;`
4. 改 `imul $0x13, %rcx, %rcx`, 轉成 `mull dontcare_hi rcx 0x13@uint64 rcx;`
5. 寫 postcondition `{ eqmod (limbs z) (x*y) ((2**255)-19) && limbs z < (2**255+2**64)@256 }`
6. schoolbook 4 row 每個 carry chain 結尾加 `assert + assume carry = 0`(7 個)
7. reduction + fix-up 加 6 個 `assert + assume`: 38-fold carry, add-chain carry, final carry, `bit_lost`, `add_co`, `dontcare_hi`
8. `and r11 r11 0x7fff...` 保留, 後面加 `assert + assume r11 = r11_low_63` bridge (借 step 3 split 的 r11_low_63, 把 bitwise 結果橋給 Singular)

## `gfp25519reduce` 簡化步驟

precondition 用 mul 輸出 bound `< 2^255 + 2^64`(其實用 `2^255 + 2^11` 也可以), postcondition `eqmod (out) (in) p && out < 2^255`

reduce 只讀 z[0]/z[1]/z[3](跳過 z[2]), carry 只傳到 z[1], precondition 保證 bit 255 = 1 時 z[1] = z[2] = 0, carry 不會傳到 z[2], 因此跳過 z[2] 安全, 所以完全不讀 z[2]

0. 使用 `trace.py` 抓到的 gas 透過 `to_zdsl.py` 轉出的原始草稿
1. cleanup: 刪 label, 多餘參數、prologue, epilogue, return
2. `imul $0x13, %r11, %r11` → `mull dontcare_hi r11 0x13@uint64 r11;`;`and r10 r10 0x402008` 改成 mask63 常數值 `0x7fffffffffffffff`
3. 加 precondition `limbs < 2^255 + 2^64`, 定義 `z_in-*` 4 limbs 代表輸入的變數 z 的四個 limb, postcondition `eqmod && < 2^255`(reduce in-place 寫 z[0]/z[1]/z[3], snapshot 必要)
4. 加 `assert + assume r10 = r10_low_63`, 因為 r10_low_63 是 step 2 `split r11 r10_low_63 r11 0x3f` 的低位輸出 (= r10 低 63 bits)
	- `and r10 0x7fff...` 結果也是 r10 低 63 bits, 兩者相等
5. 加 `assert + assume`:
	- `dontcare_hi = 0`: r11 來自 split bit 63 ∈ {0, 1}, `19 * r11 ∈ {0, 19} < 2^64`
	- carry chain 最後 `carry = 0`:
		- bit 63 = 0: r11 = 0, 整條無 carry
		- bit 63 = 1: precondition `< 2^255 + 2^64` 強制 z[1] = 0, `r9 + carry ≤ 1 < 2^64`

# 補充
## mul 為什麼要 assert + assume
裡面出現了很多像是 `assert true && carry = 0@uint1; assume carry = 0 && true;` 這樣 assert + assume 的組合, 這是為了將 bit vector 驗證沒有 overflow 的資訊傳遞到 singular

## mul 的 tight bound:`< 2^255 + 2^11`
如果將檔案 08 修改 postcondition:

| bound | cv 結果 |
|---|---|
| `< 2**255 + 2**11` | [OK] |
| `< 2**255 + 2**10` | [FAILED] |

推導: reduction 後 `rcx ≤ 38`, shld 後 `≤ 77`, 再乘上 19 後 `1463`, 因為 `1464 ≤ 2048`, 因此是 `2^11`

## `shld` 的轉換

x86 `shld dst, src, n`: Shift Left Double-precision, `dst` 代表被左移 `n` 位後的數值, 騰出的低位從 `src` 高位填入,`src` 不變

```
shld $1, %r11, %rcx
  rcx_new = (rcx << 1) | (r11 >> 63)
r11 不變
```

對應 reduction 用途: 把跨 bit 254/255 邊界的兩 bit(r11 最高位 + rcx)
**整合成 rcx**,之後乘 19 摺回低位。

CL 沒對應指令,拆三步等價:
| asm | CL |
|---|---|
| `shld $1, %r11, %rcx` | `split r11_top r11_low_63 r11 63;` 抓 r11 最高 bit |
| | `shls bit_lost rcx_dbl rcx 1;` rcx 左移 1,溢出存 bit_lost |
| | `adds add_co rcx rcx_dbl r11_top;` 把 r11_top 拼進 rcx |

`bit_lost = 0` 跟 `add_co = 0` 之後 assert + assume(rcx 已知很小, 左移不 overflow)

## `imul` 的轉換

x86 `imul $imm, %src, %dst`(3-operand 形式):`dst = src * imm`, 只取低 64 位

CryptoLine 的 `x86_64.rules` 只有 2-operand `imul` 規則, 3-operand 沒對應, 因此用 `mull` 全寬乘代替:

| asm | CL |
|---|---|
| `imul $0x13, %rcx, %rcx` | `mull dontcare_hi rcx 0x13@uint64 rcx;` |

`mull h l a b` 算 `h * 2^64 + l = a * b`, 把高 64 位放 `dontcare_hi`、低 64 位放 `rcx`。
之後 `assert + assume dontcare_hi = 0`(rcx < 2^60, 所以 `19 * rcx < 2^64`, 高位必為 0)。

## 2^256 mod p 為什麼等於 38

`p = 2^255 - 19`,所以 `2^256 = 2(p+19) = 2p + 38 ≡ 38 (mod p)`。

前段運算若 carry = 1, 真實值 = `(低 256 bits) + 1 × 2^256`, 因此要把 carry 摺回: 加 `1 × 38` 到低 256, 這同餘 mod p。

## loose vs canonical form

我不太清楚密碼學在這相關的問題, 因此這部份參考 AI:

- **canonical**: 範圍嚴格介於 `[0, p)` 之間, 是唯一表示
- **loose**: 將 `[0, p)` 範圍擴充到 `[0, 2^256)`

雖然 loose 範圍更大, 但保證同餘, 這樣做是為了性能, 只需要把數值都規定在 `[0, 2^256)` 之間, 最後全部計算完畢以後再把數值範圍從 `[0, 2^256)` 壓回 `[0, p)`

example:
| 64-bit 值 | mod p 值 | canonical? |
|---|---|---|
| `0` | 0 | ✓ |
| `p` | 0 | ✗ |
| `p + 1` | 1 | ✗ |
| `2^256 - 1` | 37 | ✗ |