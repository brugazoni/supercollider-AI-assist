# X-Append Lean Prompt Stress Test Report (20 Rounds + 2-Round Auto-Fix)

- **Model**: `openrouter:google/gemini-3.8-flash`
- **Seed**: `42`
- **Total Rounds**: `20` (4 modes × 5 rounds)
- **Max Auto-Fix Attempts / Round**: `2`
- **Total Battery Wall Time**: `620.09s`
- **Initial 1st-Try Pass Rate**: `18/20` (`90.0%`)
- **Post-Auto-Fix Pass Rate**: `20/20` (`100.0%`)
- **Auto-Fix Calls**: `3` across `2` round(s) (Attempt 1 recoveries: `1`, Attempt 2 recoveries: `1`, Fallbacks: `0`)
- **Design Synthesizer Cleanups Applied**: `4/4` subsequent design round(s)

## Per-Mode Timing & Behavior

| Mode | Rounds | Mean Lean Time (s) | Median (s) | Min (s) | Max (s) | 1st-Try Pass | Auto-Fix Triggered | Fix #1 OK | Fix #2 OK | Fallback | Design Cleanups |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| `append` | 5 | 10.32s | 10.90s | 8.13s | 11.86s | 5/5 | 0 (0 calls) | 0 | 0 | 0 | 0 |
| `compose` | 5 | 26.20s | 24.10s | 19.91s | 34.00s | 4/5 | 1 (1 calls) | 1 | 0 | 0 | 0 |
| `design` | 5 | 51.84s | 53.60s | 46.32s | 54.98s | 4/5 | 1 (2 calls) | 0 | 1 | 0 | 4 |
| `generate` | 5 | 18.78s | 16.60s | 11.89s | 31.41s | 5/5 | 0 (0 calls) | 0 | 0 | 0 | 0 |

## Round-by-Round Execution Log

| Round | Mode | Frag # | Category | Lean (s) | 1st Val | Auto-Fix Used | Resolution | Design Cleanup | Chars |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 01 | `compose` (#1) | #15 | `wikipedia` | 23.70s | FAIL | 1 | Auto-Fix #1 | No | 5915 |
| 02 | `append` (#1) | #4 | `wikipedia` | 8.13s | PASS | 0 | 1st Try OK | No | 1577 |
| 03 | `design` (#1) | #36 | `poema` | 50.59s | PASS | 0 | 1st Try OK | No | 16088 |
| 04 | `generate` (#1) | #32 | `poema` | 15.36s | PASS | 0 | 1st Try OK | No | 4229 |
| 05 | `generate` (#2) | #29 | `poema` | 31.41s | PASS | 0 | 1st Try OK | No | 4462 |
| 06 | `generate` (#3) | #18 | `wikipedia` | 11.89s | PASS | 0 | 1st Try OK | No | 4771 |
| 07 | `append` (#2) | #14 | `wikipedia` | 11.84s | PASS | 0 | 1st Try OK | No | 3312 |
| 08 | `design` (#2) | #70 | `descricao_imagem` | 53.72s | PASS | 0 | 1st Try OK | Yes | 26419 |
| 09 | `append` (#3) | #12 | `wikipedia` | 8.86s | PASS | 0 | 1st Try OK | No | 2186 |
| 10 | `compose` (#2) | #55 | `conto_cronica` | 29.30s | PASS | 0 | 1st Try OK | No | 7932 |
| 11 | `compose` (#3) | #5 | `wikipedia` | 24.10s | PASS | 0 | 1st Try OK | No | 8728 |
| 12 | `append` (#4) | #79 | `descricao_imagem` | 10.90s | PASS | 0 | 1st Try OK | No | 2764 |
| 13 | `append` (#5) | #72 | `descricao_imagem` | 11.86s | PASS | 0 | 1st Try OK | No | 2757 |
| 14 | `generate` (#4) | #28 | `poema` | 18.63s | PASS | 0 | 1st Try OK | No | 5719 |
| 15 | `design` (#3) | #30 | `poema` | 46.32s | FAIL | 2 | Auto-Fix #2 | Yes | 22726 |
| 16 | `compose` (#4) | #65 | `descricao_imagem` | 34.00s | PASS | 0 | 1st Try OK | No | 10257 |
| 17 | `design` (#4) | #69 | `descricao_imagem` | 53.60s | PASS | 0 | 1st Try OK | Yes | 26400 |
| 18 | `compose` (#5) | #78 | `descricao_imagem` | 19.90s | PASS | 0 | 1st Try OK | No | 7165 |
| 19 | `design` (#5) | #13 | `wikipedia` | 54.98s | PASS | 0 | 1st Try OK | Yes | 24367 |
| 20 | `generate` (#5) | #46 | `conto_cronica` | 16.60s | PASS | 0 | 1st Try OK | No | 4629 |
