# Gemma 4 with Codex

Run a local Gemma 4 GGUF model as an OpenAI-compatible `llama.cpp` server, then connect Codex to it with a Codex profile.

This setup starts Gemma 4 with `llama-server` and configures Codex to use the Responses API at:

```text
http://127.0.0.1:18080/v1
```

Use `codex` for normal OpenAI models. Use `codex -p gemma4` for the local Gemma 4 provider.

## Prerequisites

Install or download:

- Codex CLI
- `llama.cpp` with `llama-server`
- A Gemma 4 GGUF model file, such as `gemma4-v2-Q4_K_M.gguf`
- Optional multimodal projector, if you choose a multimodal model

Recommended local layout:

```text
Gemma4-Experiments/
  llama-cpp/
    llama-server.exe
    ggml-cuda.dll
    cudart64_12.dll
  models/
    gemma4-v2-Q4_K_M.gguf
```

For this Windows workstation, use the CUDA llama.cpp build rather than the CPU build:

```text
llama-b9739-bin-win-cuda-12.4-x64.zip
cudart-llama-bin-win-cuda-12.4-x64.zip
```

The second package provides the CUDA runtime DLLs, including `cudart64_12.dll`. Verify GPU detection with:

```cmd
llama-cpp\llama-server.exe --list-devices
```

Expected on this machine:

```text
CUDA0: NVIDIA GeForce RTX 3070
```

If `GEMMA4_MODEL` is not set and the local `models/` file is not present, the launcher downloads and starts the recommended local coding model from Hugging Face:

```text
yuxinlu1/gemma-4-12B-agentic-fable5-composer2.5-v2-3.5x-tau2-GGUF
gemma4-v2-Q4_K_M.gguf
```

If llama.cpp cannot download from Hugging Face because of local SSL or certificate handling, download the GGUF with a browser, `huggingface-cli`, or PowerShell, then place it at:

```text
models/gemma4-v2-Q4_K_M.gguf
```

You can also keep files anywhere and set environment variables before launching:

```cmd
set GEMMA4_LLAMA_SERVER=C:\path\to\llama-server.exe
set GEMMA4_MODEL=C:\path\to\gemma4-v2-Q4_K_M.gguf
```

On a computer with substantially more RAM and VRAM, you can try a larger model:

```cmd
set GEMMA4_HF_REPO=unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF
set GEMMA4_HF_FILE=Qwen3-Coder-30B-A3B-Instruct-Q4_K_M.gguf
start-gemma4-codex-server.cmd
```

## Configure Codex

Add the provider block from `config.example.toml` to your existing Codex config:

```text
C:\Users\YOUR_NAME\.codex\config.toml
```

Create a profile file from `gemma4.config.example.toml`:

```text
C:\Users\YOUR_NAME\.codex\gemma4.config.toml
```

The profile uses:

```toml
model = "gemma4-codex"
model_provider = "local_gemma4"
model_reasoning_effort = "none"
model_context_window = 32768
```

The Codex profile and server launcher both default to `32768` context on this workstation. Keep `model_context_window` and `GEMMA4_CTX_SIZE` aligned so Codex does not send prompts larger than the local server can accept. Gemma does not understand Codex's hosted-model reasoning controls, so the Gemma profile disables inherited reasoning effort.

## Reasoning Settings

The Gemma4-12B Agentic v2 model itself supports Gemma's native thinking behavior. The model card describes it as a coding, reasoning, tool-use, and agentic model, and notes that v2 thinks in Gemma's native thought channel before answering.

This Codex setup currently keeps reasoning disabled at the integration layer:

```toml
model_reasoning_effort = "none"
```

```cmd
--reasoning off
```

That is deliberate. Codex hosted-model reasoning controls do not map cleanly to a local llama.cpp Gemma model, and exposing raw thought-channel output may not behave like OpenAI-hosted reasoning summaries.

Future experiment: change the llama.cpp launcher from `--reasoning off` to `--reasoning auto` while keeping `model_reasoning_effort = "none"` in the Codex profile. That would let the Gemma chat template decide whether to use native thinking behavior without pretending Codex has OpenAI-style reasoning-effort support for this local model.

## Machine Notes

This setup was sized for:

- CPU: Intel Core i7-11700K, 8 cores / 16 threads
- RAM: 128 GB
- GPU: NVIDIA GeForce RTX 3070, 8 GB VRAM
- Driver: NVIDIA 591.74

The large system RAM means bigger GGUF models can load, but the 8 GB GPU is still the main performance constraint. For daily Codex software development, prefer a model that mostly fits GPU memory and only spills lightly to RAM. The default `gemma4-v2-Q4_K_M.gguf` is the practical daily-driver choice for this machine.

The launcher is tuned for a single local Codex session: one server slot, Q4 KV cache, Flash Attention, automatic GPU-layer fitting, and a 512 MiB fitting margin. This avoids reserving KV memory for four parallel 32K sessions and gives llama.cpp more room to offload model layers to the RTX 3070. Override `GEMMA4_PARALLEL`, `GEMMA4_CACHE_TYPE_K`, `GEMMA4_CACHE_TYPE_V`, `GEMMA4_FLASH_ATTN`, or `GEMMA4_FIT_TARGET` when testing other trade-offs.

The recommended larger-model experiment is Qwen3-Coder-30B-A3B in a 4-bit GGUF. It should load with 128 GB RAM, but it will spill beyond the RTX 3070's VRAM and run slower. Very large GGUFs, such as Qwen3-Coder-Next Q4_K_M, are loadable in RAM but likely too slow for normal Codex iteration on this GPU.

## Start Gemma 4

Open a terminal in this folder:

```cmd
start-gemma4-codex-server.cmd
```

Keep that terminal open while Codex is using Gemma 4.

## Check The Server

In another terminal:

```cmd
check-gemma4-codex-server.cmd
```

Expected output includes:

```text
Models endpoint is reachable.
gemma4-codex is listed.
Responses endpoint returned: ready
```

## Launch Codex With Gemma 4

```cmd
codex -p gemma4
```

Ask:

```text
What model are you?
```

## Use OpenAI Models Normally

Launch Codex without the profile:

```cmd
codex
```

This keeps the normal OpenAI provider active. The `/model` command shows models for the active provider only, so Gemma 4 will not appear in `/model` from a normal OpenAI-backed session. Use `codex -p gemma4` to switch to the local provider.

## Stop The Server

Press `Ctrl+C` in the server terminal, or run:

```cmd
stop-gemma4-codex-server.cmd
```

## Troubleshooting

`Model metadata for gemma4-codex not found`

This warning is nonfatal. Codex does not have a built-in catalog entry for the custom local model, so it uses fallback metadata.

`request exceeds the available context size`

Start `llama-server` with a larger context and update `model_context_window` in `gemma4.config.toml` to match. This project defaults to `GEMMA4_CTX_SIZE=32768`. Larger context windows need more memory, especially on 12B and larger models.

`llama-server` starts but does not use the GPU

Make sure the CUDA llama.cpp package and the CUDA runtime package were both extracted into `llama-cpp/`. Confirm `ggml-cuda.dll` and `cudart64_12.dll` are present, then run:

```cmd
llama-cpp\llama-server.exe --list-devices
```

`Expand-Archive` fails on a downloaded CUDA zip

An interrupted GitHub release download can leave a corrupt zip. Delete the partial zip and download it again before extracting.

`failed to download model from Hugging Face` with `SSL server verification failed`

The llama.cpp built-in Hugging Face downloader may fail certificate verification on this Windows setup. Download `gemma4-v2-Q4_K_M.gguf` separately and place it in `models/`, or set `GEMMA4_MODEL` to the downloaded file path before running the launcher.

`codex -p gemma4 debug models` fails

That debug command does not accept `--profile` in this Codex CLI build. Use this non-generating config-load check instead:

```cmd
codex -p gemma4 debug prompt-input "ping"
```

`gemma4-codex is not listed by /v1/models`

Make sure the server terminal is still open and the model alias is the same in both the server and Codex config. The default alias is `gemma4-codex`.

`/model does not show Gemma 4`

This is expected in normal Codex sessions. `/model` switches models within the active provider. Use `codex -p gemma4` to launch with the local provider.
