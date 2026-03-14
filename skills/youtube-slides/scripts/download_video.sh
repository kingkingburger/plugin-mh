#!/bin/bash
# YouTube 영상 다운로드 (캡쳐용 최적 해상도)
# Usage: ./download_video.sh <URL> [output_dir]

URL="$1"
OUTPUT_DIR="${2:-.}"

if [ -z "$URL" ]; then
  echo "Usage: $0 <YouTube URL> [output_dir]"
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

# 720p 이하 MP4로 다운로드 (캡쳐용이므로 고해상도 불필요)
yt-dlp -f "bestvideo[height<=720]+bestaudio/best[height<=720]" \
  --merge-output-format mp4 \
  -o "$OUTPUT_DIR/%(id)s.%(ext)s" "$URL"
