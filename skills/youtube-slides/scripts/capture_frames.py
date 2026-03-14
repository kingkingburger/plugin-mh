"""
YouTube 자막 구간별 프레임 캡쳐
Usage: python capture_frames.py <video_path> <json3_subtitle_path> <output_dir> [--min-interval N]
"""

import json
import subprocess
import sys
import os
import argparse


def parse_json3_subtitles(json3_path):
    """JSON3 자막 파일을 파싱하여 타임스탬프+텍스트 세그먼트 추출."""
    with open(json3_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    segments = []
    for event in data.get("events", []):
        if "segs" not in event:
            continue
        start_ms = event.get("tStartMs", 0)
        duration_ms = event.get("dDurationMs", 0)
        text = "".join(seg.get("utf8", "") for seg in event["segs"]).strip()
        if text and text != "\n":
            segments.append(
                {
                    "start_ms": start_ms,
                    "start_sec": start_ms / 1000.0,
                    "duration_ms": duration_ms,
                    "text": text,
                }
            )
    return segments


def deduplicate_segments(segments, min_interval_sec=3.0):
    """너무 가까운 세그먼트를 병합."""
    if not segments:
        return []

    merged = [segments[0]]
    for seg in segments[1:]:
        if seg["start_sec"] - merged[-1]["start_sec"] < min_interval_sec:
            merged[-1]["text"] += " " + seg["text"]
        else:
            merged.append(seg)
    return merged


def capture_frame(video_path, timestamp_sec, output_path):
    """주어진 타임스탬프에서 프레임 1장 캡쳐."""
    cmd = [
        "ffmpeg",
        "-ss",
        str(timestamp_sec),
        "-i",
        video_path,
        "-frames:v",
        "1",
        "-q:v",
        "2",
        "-y",
        output_path,
    ]
    subprocess.run(cmd, capture_output=True, check=True)


def format_timestamp(seconds):
    """초를 HH:MM:SS 또는 MM:SS 형식으로 변환."""
    h = int(seconds // 3600)
    m = int((seconds % 3600) // 60)
    s = int(seconds % 60)
    if h > 0:
        return f"{h:02d}:{m:02d}:{s:02d}"
    return f"{m:02d}:{s:02d}"


def main():
    parser = argparse.ArgumentParser(description="YouTube 자막 구간별 프레임 캡쳐")
    parser.add_argument("video_path", help="영상 파일 경로")
    parser.add_argument("subtitle_path", help="JSON3 자막 파일 경로")
    parser.add_argument("output_dir", help="출력 디렉토리")
    parser.add_argument(
        "--min-interval",
        type=float,
        default=3.0,
        help="최소 캡쳐 간격 (초, 기본: 3.0)",
    )
    args = parser.parse_args()

    images_dir = os.path.join(args.output_dir, "images")
    os.makedirs(images_dir, exist_ok=True)

    # 자막 파싱 및 병합
    segments = parse_json3_subtitles(args.subtitle_path)
    segments = deduplicate_segments(segments, args.min_interval)

    print(f"총 {len(segments)}개 세그먼트에서 프레임 캡쳐 시작...")

    results = []
    for i, seg in enumerate(segments):
        timestamp = format_timestamp(seg["start_sec"])
        image_filename = f"frame_{i:04d}_{timestamp.replace(':', '-')}.jpg"
        image_path = os.path.join(images_dir, image_filename)

        try:
            capture_frame(args.video_path, seg["start_sec"], image_path)
            results.append(
                {
                    "index": i,
                    "timestamp": timestamp,
                    "timestamp_sec": seg["start_sec"],
                    "text": seg["text"],
                    "image": image_filename,
                }
            )
            print(f"  [{i + 1}/{len(segments)}] {timestamp} - captured")
        except subprocess.CalledProcessError as e:
            print(f"  [{i + 1}/{len(segments)}] {timestamp} - FAILED: {e}")

    # 매핑 파일 저장
    mapping_path = os.path.join(args.output_dir, "segments.json")
    with open(mapping_path, "w", encoding="utf-8") as f:
        json.dump(results, f, ensure_ascii=False, indent=2)

    print(f"\n완료: {len(results)}/{len(segments)} 프레임 캡쳐됨")
    print(f"매핑 파일: {mapping_path}")


if __name__ == "__main__":
    main()
