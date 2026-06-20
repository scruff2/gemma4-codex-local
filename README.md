# Gemma 4 with Codex

Run a local Gemma 4 GGUF model as an OpenAI-compatible `llama.cpp` server, then connect Codex to it with a Codex profile.

This starter was tested on Windows with:

- Codex CLI `0.141.0`
- `llama-server` from `llama.cpp`
- `google/gemma-4-E4B-it-qat-q4_0-gguf`
- Codex `wire_api = "responses"`

## What This Solves

Codex can use custom model providers, but a local model must be served through an API Codex understands. This project starts Gemma 4 with `llama-server` and configures Codex to use the Responses API at:

```text
http://127.0.0.1:18080/v1
```

Use `codex` for normal OpenAI models. Use `codex -p gemma4` for the local Gemma 4 provider.

## Prerequisites

Install or download:

- Codex CLI
- `llama.cpp` with `llama-server`
- A Gemma 4 GGUF model file, such as `gemma-4-E4B_q4_0-it.gguf`
- Optional multimodal projector, such as `gemma-4-E4B-it-mmproj.gguf`

Recommended local layout:

```text
gemma4-codex-local/
  llama-cpp/
    llama-server.exe
  models/
    gemma-4-E4B_q4_0-it.gguf
    gemma-4-E4B-it-mmproj.gguf
```

You can also keep files anywhere and set environment variables before launching:

```cmd
set GEMMA4_LLAMA_SERVER=C:\path\to\llama-server.exe
set GEMMA4_MODEL=C:\path\to\gemma-4-E4B_q4_0-it.gguf
set GEMMA4_MMPROJ=C:\path\to\gemma-4-E4B-it-mmproj.gguf
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
model_context_window = 16384
```

The `16384` context matters. Codex's own startup prompt can exceed 4096 tokens before your first user message reaches the model.

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

In testing, the local model identified itself as Gemma 4.

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

Start `llama-server` with a larger context. This project defaults to `GEMMA4_CTX_SIZE=16384`.

`gemma4-codex is not listed by /v1/models`

Make sure the server terminal is still open and the model alias is the same in both the server and Codex config. The default alias is `gemma4-codex`.

`/model does not show Gemma 4`

This is expected in normal Codex sessions. `/model` switches models within the active provider. Use `codex -p gemma4` to launch with the local provider.
