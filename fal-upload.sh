#!/usr/bin/env bash
# fal-upload.sh — Upload a local file to fal.ai storage, return public URL
# Usage: fal-upload.sh <local-file-path>
#
# Uses the 2-step signed URL flow:
#   1. POST rest.fal.ai/storage/upload/initiate → get signed upload URL + file URL
#   2. PUT file content to signed URL
#
# Returns the public file URL on stdout (last line). Status output goes to stderr.
#
# Examples:
#   fal-upload.sh ./photo.jpg
#   URL=$(fal-upload.sh ~/Downloads/shirt.png)

set -euo pipefail

FILE_PATH="${1:?Usage: fal-upload.sh <local-file-path>}"

if [ ! -f "${FILE_PATH}" ]; then
  echo "ERROR: File not found: ${FILE_PATH}" >&2
  exit 1
fi

if [ -z "${FAL_KEY:-}" ]; then
  echo "ERROR: FAL_KEY environment variable not set" >&2
  exit 1
fi

# Detect content type from extension
EXT=$(echo "${FILE_PATH##*.}" | tr '[:upper:]' '[:lower:]')
case "${EXT}" in
  jpg|jpeg) CONTENT_TYPE="image/jpeg" ;;
  png)      CONTENT_TYPE="image/png" ;;
  webp)     CONTENT_TYPE="image/webp" ;;
  gif)      CONTENT_TYPE="image/gif" ;;
  mp4)      CONTENT_TYPE="video/mp4" ;;
  mp3)      CONTENT_TYPE="audio/mpeg" ;;
  wav)      CONTENT_TYPE="audio/wav" ;;
  *)        CONTENT_TYPE="application/octet-stream" ;;
esac

FILENAME=$(basename "${FILE_PATH}")
echo "Uploading: ${FILENAME} (${CONTENT_TYPE})..." >&2

# Step 1: Initiate upload — get signed URL with proper file extension
INIT_RESPONSE=$(curl -s -X POST "https://rest.fal.ai/storage/upload/initiate" \
  -H "Authorization: Key ${FAL_KEY}" \
  -H "Content-Type: application/json" \
  -d "{\"file_name\":\"${FILENAME}\",\"content_type\":\"${CONTENT_TYPE}\"}")

FILE_URL=$(echo "${INIT_RESPONSE}" | python3 -c "import sys,json; print(json.load(sys.stdin).get('file_url',''))" 2>/dev/null)
UPLOAD_URL=$(echo "${INIT_RESPONSE}" | python3 -c "import sys,json; print(json.load(sys.stdin).get('upload_url',''))" 2>/dev/null)

if [ -z "${FILE_URL}" ] || [ -z "${UPLOAD_URL}" ]; then
  echo "ERROR: Failed to initiate upload" >&2
  echo "${INIT_RESPONSE}" >&2
  exit 1
fi

# Step 2: PUT file content to signed URL
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X PUT "${UPLOAD_URL}" \
  -H "Content-Type: ${CONTENT_TYPE}" \
  -T "${FILE_PATH}")

if [ "${HTTP_STATUS}" != "200" ]; then
  echo "ERROR: Upload failed with HTTP ${HTTP_STATUS}" >&2
  exit 1
fi

echo "Uploaded: ${FILE_URL}" >&2
echo "${FILE_URL}"
