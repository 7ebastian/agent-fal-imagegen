# Model Catalog

> **Last updated:** 2026-04-23
> **Refresh policy:** if the date above is older than 30 days, or if the user mentions a model not in this catalog, WebFetch `https://fal.ai/models` and `https://docs.fal.ai/models` to find current models + pricing, then propose a diff against this file. Do not rewrite without showing the user the proposed changes first.

The script works with **any fal.ai model** — just pass the model ID. The tables below are a quick reference for popular ones. The model-hosting landscape moves weekly, so treat this as a living index, not an authoritative list.

## Image Generation

| Model | ID | Cost | Notes |
|-------|----|------|-------|
| Z-Image Turbo | `fal-ai/z-image/turbo` | ~$0.005/MP | Ultra cheap & fast (Alibaba Tongyi) |
| Flux Schnell | `fal-ai/flux/schnell` | $0.03 | Fast, good quality |
| Seedream 4.5 | `fal-ai/bytedance/seedream/v4.5/text-to-image` | $0.04 | ByteDance, uses `image_size` param |
| Seedream 5.0 Lite | `fal-ai/bytedance/seedream/v5/lite/text-to-image` | TBD | ByteDance latest, uses `image_size` param |
| Qwen-Image 2.0 | `qwen-image-2/text-to-image` | ~$0.02/MP | Alibaba, cheap, good realism + typography |
| Qwen-Image 2.0 Pro | `qwen-image-2/pro/text-to-image` | ~$0.02/MP | Alibaba, best quality variant |
| Nano Banana 2 | `fal-ai/nano-banana-2` | $0.08 | Google, good default |
| Nano Banana Pro | `fal-ai/nano-banana-pro` | $0.10 | Google, reasoning model, best realism |
| Recraft v4 | `fal-ai/recraft/v4/pro/text-to-image` | $0.12 | Design/illustration work |
| GPT-Image-2 | `openai/gpt-image-2` | $0.01–$0.41 | OpenAI, best-in-class text (Latin + CJK). `quality` = low/medium/high (default high). Uses `image_size`. Released 2026-04-22 |
| Grok Imagine | `xai/grok-imagine-image` | $0.02 | xAI. Same price via fal.ai or direct API |
| Grok Imagine Pro | `grok-imagine-image-pro` (xAI API only) | $0.07 | xAI pro quality — **NOT on fal.ai** (404). Use xAI direct API — see SKILL.md xAI section |

## Image Editing

| Model | ID | Notes |
|-------|----|-------|
| Nano Banana 2 Edit | `fal-ai/nano-banana-2/edit` | Google, fast edits. Uses `image_urls` (array) |
| GPT-Image-2 Edit | `openai/gpt-image-2/edit` | OpenAI. Takes `image_urls` (array) + optional `mask_image_url` (white=editable, black=preserve). Same price matrix as text-to-image ($0.01–$0.41). Default `image_size=auto`. Streaming supported. Released 2026-04-22 |
| Seedream 4.5 Edit | `fal-ai/bytedance/seedream/v4.5/edit` | ByteDance |
| Qwen-Image 2.0 Edit | `qwen-image-2/edit` | Alibaba |
| Qwen-Image 2.0 Pro Edit | `qwen-image-2/pro/edit` | Alibaba, best quality |
| Kontext | `fal-ai/flux-pro/kontext` | Precise local edits |
| OneReward | `fal-ai/onereward` | Mask-guided inpainting/outpainting, object removal, text rendering. Requires `image_url` + `mask_url`. $0.035/MP |
| Grok Imagine Edit | `xai/grok-imagine-image/edit` | xAI via fal.ai. $0.022/img ($0.02 output + $0.002 input). Handles multi-image reference. Same endpoint as direct API |

## Video Generation

| Model | ID | Cost | Notes |
|-------|----|------|-------|
| Grok Imagine (i2v) | `xai/grok-imagine-video/image-to-video` | $0.05/s (480p), $0.07/s (720p) | xAI, +$0.002 flat input fee |
| Grok Imagine (t2v) | `xai/grok-imagine-video/text-to-video` | $0.05/s (480p), $0.07/s (720p) | xAI text-to-video |
| Grok Imagine (ref-to-v) | `xai/grok-imagine-video/reference-to-video` | $0.05/s (480p), $0.07/s (720p) | xAI. Multi-reference-image video. +$0.002 per image input. 24fps, 16:9 |
| Grok Imagine Edit Video | `xai/grok-imagine-video/edit-video` | $0.06/s (480p), $0.08/s (720p) | xAI video edit. +$0.01/s input = $0.06/$0.08 effective |
| Grok Imagine Extend Video | `xai/grok-imagine-video/extend-video` | $0.05/s (480p) + $0.01/s input, $0.07/s (720p) + $0.01/s input | xAI. Continues source video from last frame. Takes `video_url` (mp4/mov/webm/m4v/gif) |
| Veo 3.1 | `fal-ai/veo3.1` | $0.20-0.60/s | Google, best quality. 4/6/8s. 720p-4K |
| Veo 3.1 Fast | `fal-ai/veo3.1/fast/text-to-video` | — | Faster, lower quality |
| Kling O3 | `fal-ai/kling-video/o3/standard/image-to-video` | $0.17-0.22/s | Start+end frame animation |
| Kling v3 Pro | `fal-ai/kling-video/v3/pro/image-to-video` | $0.22-0.39/s | Cinematic, native audio |
| Seedance 2.0 (t2v) | `bytedance/seedance-2.0/text-to-video` | $0.3034/s | ByteDance. 720p/480p, 4–15s, native sync audio, 6 aspect ratios. B2B needs `end_user_id` |
| Seedance 2.0 (i2v) | `bytedance/seedance-2.0/image-to-video` | $0.3024/s | ByteDance. `image_url` + optional `end_image_url` for start/end frame control |
| Seedance 2.0 (ref-to-v) | `bytedance/seedance-2.0/reference-to-video` | $0.3024/s / $0.1814/s w/video ref | ByteDance. Up to 9 images + 3 videos + 3 audio refs. **−40% price when video refs supplied** |
| Seedance 2.0 Fast (t2v) | `bytedance/seedance-2.0/fast/text-to-video` | $0.2419/s | Fast variant, ~20% cheaper than Pro, lower latency. Same feature set |
| Seedance 2.0 Fast (i2v) | `bytedance/seedance-2.0/fast/image-to-video` | $0.2419/s | Fast variant of image-to-video |
| Seedance 2.0 Fast (ref-to-v) | `bytedance/seedance-2.0/fast/reference-to-video` | $0.2419/s / $0.14515/s w/video ref | Fast variant of reference-to-video |
| LTX 2.3 Fast | `fal-ai/ltx-2.3/image-to-video/fast` | TBD | Fast variant, image-to-video |
| LTX 2.3 Pro | `fal-ai/ltx-2.3/retake-video` | $0.10/s | Retake/edit video, text/image/audio-to-video |
| LTX 2.0 Pro | `fal-ai/ltx-2/image-to-video` | $0.06-0.24/s | 4K, native audio sync, 6/8/10s |
| LTX 2.0 Fast | `fal-ai/ltx-2/image-to-video/fast` | $0.04/s | 1080p, 30x faster. Min duration: 6s |
| LTX 2.0 19B | `fal-ai/ltx-2-19b/distilled/image-to-video/lora` | TBD | Largest model, LoRA support |
| Wan Motion | `fal-ai/wan-motion` | $0.06/s | Transfer motion from driving video onto character |
| Wan 2.5 | `fal-ai/wan-25-preview/image-to-video` | TBD | Latest Wan, image-to-video |
| Wan Turbo | `fal-ai/wan/turbo/image-to-video` | TBD | Fast, open source — note: omits v2.2-a14b from path |
| Wan 2.2 | `fal-ai/wan/v2.2-a14b/image-to-video` | TBD | Open source, LoRA support |
| Wan 2.2 + LoRA | `fal-ai/wan/v2.2-a14b/image-to-video/lora` | TBD | Custom LoRA models |

## Audio & Voice

| Model | ID | Cost | Notes |
|-------|----|------|-------|
| ElevenLabs Turbo v2.5 | `fal-ai/elevenlabs/tts/turbo-v2.5` | — | Low-latency TTS, 32 languages (ElevenLabs) |
| Chatterbox TTS | `chatterbox/text-to-speech` | — | Text-to-speech (Resemble AI) |
| MiniMax Speech-02 HD | `minimax/speech-02-hd` | — | Multi-voice TTS, high quality |
| Dia TTS Voice Clone | `dia-tts/voice-clone` | — | Clone voice from sample, generate dialog |
| Beatoven Music | `beatoven/music-generation` | — | Royalty-free instrumental from text prompt |
| Beatoven SFX | `beatoven/sound-effect-generation` | — | Sound effects from text descriptions |
| Lava SR | `lava-sr` | — | Upscale muffled 16kHz speech → 48kHz |

## Video Post-Production

| Model | ID | Cost | Notes |
|-------|----|------|-------|
| Mirelo SFX (v2v) | `mirelo-ai/sfx-v1/video-to-video` | — | Auto-generate synced sound for silent video |
| Mirelo SFX (audio) | `mirelo-ai/sfx-v1/video-to-audio` | — | Returns just the audio track |
| Sync Lipsync v2 | `sync-lipsync/v2` | — | Lip-sync animation from audio |
| OmniHuman 1.5 | `bytedance/omnihuman/v1.5` | — | Animate character from photo + audio (ByteDance) |
| Creatify Aurora | `creatify/aurora` | — | Studio-quality avatar speaking/singing videos |
| HeyGen Avatar 4 | `heygen/avatar4/image-to-video` | — | Photo → hyper-realistic talking avatar |
| HeyGen Digital Twin v4 | `heygen/avatar4/digital-twin` | — | Studio-grade avatar from text |
| HeyGen Digital Twin v3 | `heygen/avatar3/digital-twin` | — | Previous gen digital twin |
| HeyGen Translate Speed | `heygen/v2/translate/speed` | — | Video translation + lip sync + voice clone (fast) |
| HeyGen Translate Precision | `heygen/v2/translate/precision` | — | Video translation + lip sync + voice clone (quality) |
| Topaz Video Upscale | `topaz/upscale/video` | — | AI video upscaling |

## Utility & Tools

| Model | ID | Cost | Notes |
|-------|----|------|-------|
| Topaz Image Upscale | `topaz/upscale/image` | — | AI image upscaling |
| Bria BG Remove | `bria/background/remove` | — | Background removal (images) |
| Bria Video BG Remove | `bria/video/background-removal` | — | Background removal (video) |
| Bria Embed-Product | `bria/embed-product` | — | Place products into scenes |
| Trellis 2 | `trellis-2/retexture` | — | Image → 3D model |
| Depth Anything Video | `depth-anything-video` | — | Depth map estimation from video |

*Pricing marked — not published on fal.ai. Check model page or run a test job.*
