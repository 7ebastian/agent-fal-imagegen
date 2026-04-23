# Virtual Try-On

Dress a person in new clothes from reference photos. Uses FLUX.2 Klein 9B Edit with a virtual try-on LoRA.

## Model
- **Endpoint:** `fal-ai/flux-2/klein/9b/base/edit/lora`
- **LoRA:** `fal/flux-klein-9b-virtual-tryon-lora` (HuggingFace, open source)
- **Cost:** ~$0.04 per generation ($0.02/MP input + output)
- **Playground:** https://fal.ai/models/fal-ai/flux-2/klein/9b/base/edit/lora
- **Workflow with auto-prompting:** https://fal.ai/workflows/lovis/workflow-flux-klein-9b-virtual-tryon?view=playground

## Inputs needed
1. **Person photo** — full body, neutral background works best
2. **Top garment** — flat lay or on hanger, clear view
3. **Bottom garment** — flat lay or on hanger, clear view

All 3 images must be public URLs. Upload local files first with `fal-upload.sh`.

## Steps

### 1. Upload images (if local)
```bash
fal-upload.sh /path/to/person.jpg
fal-upload.sh /path/to/top.jpg
fal-upload.sh /path/to/bottom.jpg
```
Each returns a public URL.

### 2. Draft prompt
Describe the person wearing the garments. Example:
> "A young man with curly blonde hair wearing a black NASA t-shirt and dark jogger pants, standing in a neutral studio, full body shot"

Show prompt to user for approval before generating.

### 3. Generate
```bash
fal-generate.sh "fal-ai/flux-2/klein/9b/base/edit/lora" \
  '{
    "prompt": "<approved prompt>",
    "image_urls": ["<person_url>", "<top_url>", "<bottom_url>"],
    "loras": [{"path": "fal/flux-klein-9b-virtual-tryon-lora", "scale": 1.0}],
    "image_size": "portrait_4_3",
    "output_format": "png"
  }' \
  ./output \
  "20260305_tryon_descriptor_v001"
```

**Image order matters:** person first, top second, bottom third.

### 4. Review
Open result for user review. If clothing placement is off:
- Adjust prompt to be more specific about garment details
- Try different `guidance_scale` (default 5, try 3-7)
- Try a cleaner input photo

## Tips
- Full body shots work much better than cropped
- Flat-lay garment photos on white/neutral backgrounds give best results
- The LoRA handles the spatial reasoning — the prompt should focus on describing the look, not the mechanics
- Input images are resized to 1MP automatically
