#!/usr/bin/env bash
# fal-generate.sh — Submit a fal.ai job, poll until complete, download result
# Usage: fal-generate.sh <model-id> <json-payload> [output-dir] [filename-base]
#
# Examples:
#   fal-generate.sh fal-ai/nano-banana-2 '{"prompt":"A cat on a roof","resolution":"1K"}'
#   fal-generate.sh fal-ai/nano-banana-2 '{"prompt":"A cat","resolution":"1K"}' ./output
#   fal-generate.sh fal-ai/nano-banana-2 '{"prompt":"A cat","resolution":"1K"}' ./output 20260305_brand-hero_cat-on-roof_v001

set -euo pipefail

MODEL_ID="${1:?Usage: fal-generate.sh <model-id> <json-payload> [output-dir] [filename-base]}"
PAYLOAD="${2:?Usage: fal-generate.sh <model-id> <json-payload> [output-dir] [filename-base]}"
OUTPUT_DIR="${3:-$HOME/Downloads/fal-ai}"
FILENAME_BASE="${4:-}"

if [ -z "${FAL_KEY:-}" ]; then
  echo "ERROR: FAL_KEY environment variable not set" >&2
  echo "Add to ~/.zshrc: export FAL_KEY=\"your-key\"" >&2
  exit 1
fi

QUEUE_URL="https://queue.fal.run/${MODEL_ID}"
AUTH_HEADER="Authorization: Key ${FAL_KEY}"

# Step 1: Submit to queue
echo "Submitting to ${MODEL_ID}..."
SUBMIT_RESPONSE=$(curl -s --request POST \
  --url "${QUEUE_URL}" \
  --header "${AUTH_HEADER}" \
  --header "Content-Type: application/json" \
  --data "${PAYLOAD}")

REQUEST_ID=$(echo "${SUBMIT_RESPONSE}" | python3 -c "import sys,json; print(json.load(sys.stdin).get('request_id',''))" 2>/dev/null)

if [ -z "${REQUEST_ID}" ]; then
  echo "ERROR: Failed to submit job" >&2
  echo "${SUBMIT_RESPONSE}" >&2
  exit 1
fi

echo "Request ID: ${REQUEST_ID}"
RESPONSE_URL=$(echo "${SUBMIT_RESPONSE}" | python3 -c "import sys,json; print(json.load(sys.stdin).get('response_url',''))" 2>/dev/null)
STATUS_URL=$(echo "${SUBMIT_RESPONSE}" | python3 -c "import sys,json; print(json.load(sys.stdin).get('status_url',''))" 2>/dev/null)

# Fallback to constructed URLs if response didn't include them
if [ -z "${RESPONSE_URL}" ]; then
  RESPONSE_URL="${QUEUE_URL}/requests/${REQUEST_ID}"
fi
if [ -z "${STATUS_URL}" ]; then
  STATUS_URL="${RESPONSE_URL}/status"
fi

# Step 2: Poll until complete
MAX_WAIT=300  # 5 minutes max
ELAPSED=0
INTERVAL=3

while [ ${ELAPSED} -lt ${MAX_WAIT} ]; do
  STATUS_RESPONSE=$(curl -s "${STATUS_URL}" --header "${AUTH_HEADER}")
  STATUS=$(echo "${STATUS_RESPONSE}" | python3 -c "import sys,json; print(json.load(sys.stdin).get('status','UNKNOWN'))" 2>/dev/null)

  case "${STATUS}" in
    COMPLETED)
      echo "Complete!"
      break
      ;;
    FAILED)
      echo "ERROR: Job failed" >&2
      echo "${STATUS_RESPONSE}" >&2
      exit 1
      ;;
    IN_QUEUE|IN_PROGRESS)
      echo "Status: ${STATUS} (${ELAPSED}s elapsed)..."
      sleep ${INTERVAL}
      ELAPSED=$((ELAPSED + INTERVAL))
      ;;
    *)
      echo "Status: ${STATUS} (${ELAPSED}s elapsed)..."
      sleep ${INTERVAL}
      ELAPSED=$((ELAPSED + INTERVAL))
      ;;
  esac
done

if [ ${ELAPSED} -ge ${MAX_WAIT} ]; then
  echo "ERROR: Timed out after ${MAX_WAIT}s" >&2
  exit 1
fi

# Step 3: Fetch result
RESULT=$(curl -s "${RESPONSE_URL}" --header "${AUTH_HEADER}")
echo ""
echo "=== RESULT JSON ==="
echo "${RESULT}" | python3 -m json.tool

# Extract prompt and seed from result/payload
PROMPT=$(echo "${PAYLOAD}" | python3 -c "import sys,json; print(json.load(sys.stdin).get('prompt',''))" 2>/dev/null)
SEED=$(echo "${RESULT}" | python3 -c "import sys,json; print(json.load(sys.stdin).get('seed',''))" 2>/dev/null)
TODAY=$(date +%Y-%m-%d)

# Step 4: Download media files
mkdir -p "${OUTPUT_DIR}"

# Download images and videos — handles both singular and array response formats
URLS=$(echo "${RESULT}" | python3 -c "
import sys, json
data = json.load(sys.stdin)
# Images: array format (most models) or singular format (Bria, etc.)
for img in data.get('images', []):
    print(img.get('url', ''))
if 'image' in data and isinstance(data['image'], dict):
    print(data['image'].get('url', ''))
# Videos: array or singular format
vids = data.get('video', data.get('videos', []))
if isinstance(vids, list):
    for vid in vids:
        if isinstance(vid, dict):
            print(vid.get('url', ''))
        elif isinstance(vid, str):
            print(vid)
elif isinstance(vids, dict):
    print(vids.get('url', ''))
# Audio
if 'audio' in data and isinstance(data['audio'], dict):
    print(data['audio'].get('url', ''))
for aud in data.get('audios', []):
    print(aud.get('url', ''))
" 2>/dev/null)

if [ -n "${URLS}" ]; then
  INDEX=0
  while IFS= read -r URL; do
    [ -z "${URL}" ] && continue
    # Extract extension from URL
    EXT=$(echo "${URL}" | python3 -c "import sys; u=sys.stdin.read().strip(); print(u.split('.')[-1].split('?')[0][:4])" 2>/dev/null || echo "png")
    if [ -n "${FILENAME_BASE}" ]; then
      if [ ${INDEX} -eq 0 ]; then
        FILENAME="${OUTPUT_DIR}/${FILENAME_BASE}.${EXT}"
      else
        # Multiple outputs: append -02, -03 etc.
        FILENAME="${OUTPUT_DIR}/${FILENAME_BASE}-$(printf '%02d' $((INDEX + 1))).${EXT}"
      fi
    else
      FILENAME="${OUTPUT_DIR}/fal-output-${INDEX}.${EXT}"
    fi
    echo "Downloading: ${FILENAME}"
    curl -s -o "${FILENAME}" "${URL}"

    # Step 5: Embed metadata into PNG files
    if [[ "${EXT}" == "png" ]]; then
      python3 - "${FILENAME}" "${PROMPT}" "${MODEL_ID}" "${PAYLOAD}" "${SEED}" "${TODAY}" << 'PYEOF'
import sys
from PIL import PngImagePlugin, Image

filepath, prompt, model, payload, seed, date = sys.argv[1:7]
try:
    img = Image.open(filepath)
    meta = PngImagePlugin.PngInfo()
    meta.add_text("prompt", prompt)
    meta.add_text("model", model)
    meta.add_text("parameters", payload)
    meta.add_text("seed", str(seed))
    meta.add_text("date", date)
    meta.add_text("generator", "fal-generate.sh")
    img.save(filepath, pnginfo=meta)
    print(f"  Metadata embedded in {filepath}")
except Exception as e:
    print(f"  Warning: could not embed metadata: {e}", file=sys.stderr)
PYEOF
    fi

    # Step 6: Append to generation log
    LOG_FILE="${OUTPUT_DIR}/_generation-log.md"
    BASENAME=$(basename "${FILENAME}")
    if [ ! -f "${LOG_FILE}" ]; then
      echo "# Generation Log" > "${LOG_FILE}"
      echo "" >> "${LOG_FILE}"
    fi
    cat >> "${LOG_FILE}" << LOGEOF

### ${BASENAME}
- **Model:** \`${MODEL_ID}\`
- **Prompt:** \`${PROMPT}\`
- **Settings:** \`$(echo "${PAYLOAD}" | python3 -c "import sys,json; d=json.load(sys.stdin); parts=[f'{k}={v}' for k,v in d.items() if k!='prompt']; print(', '.join(parts))" 2>/dev/null)\`
- **Seed:** ${SEED}
- **Date:** ${TODAY}
LOGEOF
    echo "  Log updated: ${LOG_FILE}"

    INDEX=$((INDEX + 1))
  done <<< "${URLS}"
  echo ""
  echo "Files saved to: ${OUTPUT_DIR}/"
fi
