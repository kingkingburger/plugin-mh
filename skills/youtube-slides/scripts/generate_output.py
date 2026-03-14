"""
캡쳐된 프레임 + 자막으로 마크다운/HTML 출력물 생성
Usage: python generate_output.py <output_dir> --title TITLE --url URL [--channel CH] [--date DATE] [--duration DUR]
"""

import json
import sys
import os
import argparse
from html import escape


def generate_markdown(segments, metadata, output_path):
    """타임스탬프 + 스크립트 + 이미지 경로가 포함된 마크다운 생성."""
    lines = [
        "---",
        f"title: \"{metadata.get('title', 'Unknown')}\"",
        f"url: {metadata.get('url', '')}",
        f"channel: {metadata.get('channel', '')}",
        f"date: {metadata.get('date', '')}",
        f"duration: {metadata.get('duration', '')}",
        "---",
        "",
        f"# {metadata.get('title', 'YouTube Slides')}",
        "",
    ]

    for seg in segments:
        lines.extend(
            [
                f"## [{seg['timestamp']}]",
                "",
                f"![{seg['timestamp']}](images/{seg['image']})",
                "",
                f"> {seg['text']}",
                "",
            ]
        )

    with open(output_path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))


def generate_html(segments, metadata, output_path):
    """시각적 슬라이드 뷰 HTML 페이지 생성."""
    title = escape(metadata.get("title", "YouTube Slides"))
    url = escape(metadata.get("url", ""))
    channel = escape(metadata.get("channel", ""))
    date = escape(metadata.get("date", ""))
    duration = escape(metadata.get("duration", ""))

    html_segments = []
    for seg in segments:
        text = escape(seg["text"])
        ts = escape(seg["timestamp"])
        img = escape(seg["image"])
        html_segments.append(
            f"""        <div class="slide" id="slide-{seg['index']}">
            <div class="slide-image">
                <img src="images/{img}" alt="{ts}" loading="lazy">
                <span class="timestamp">{ts}</span>
            </div>
            <div class="slide-text">
                <p>{text}</p>
            </div>
        </div>"""
        )

    meta_info = " | ".join(filter(None, [channel, date, duration]))

    html = f"""<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{title}</title>
    <style>
        * {{ margin: 0; padding: 0; box-sizing: border-box; }}
        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Noto Sans KR', sans-serif;
            background: #0f0f0f;
            color: #e1e1e1;
        }}
        .header {{
            background: #1a1a2e;
            padding: 2rem 1rem;
            text-align: center;
            border-bottom: 2px solid #7c83ff;
        }}
        .header h1 {{
            font-size: 1.4rem;
            margin-bottom: 0.5rem;
            color: #fff;
        }}
        .header .meta {{
            font-size: 0.85rem;
            color: #aaa;
            margin-bottom: 0.5rem;
        }}
        .header a {{
            color: #7c83ff;
            text-decoration: none;
            font-size: 0.9rem;
        }}
        .header a:hover {{ text-decoration: underline; }}
        .container {{
            max-width: 960px;
            margin: 2rem auto;
            padding: 0 1rem;
        }}
        .slide {{
            background: #1e1e1e;
            border-radius: 12px;
            margin-bottom: 1.5rem;
            overflow: hidden;
            box-shadow: 0 2px 12px rgba(0,0,0,0.4);
            transition: transform 0.2s;
        }}
        .slide:hover {{
            transform: translateY(-2px);
            box-shadow: 0 4px 20px rgba(124, 131, 255, 0.15);
        }}
        .slide-image {{
            position: relative;
            background: #000;
        }}
        .slide-image img {{
            width: 100%;
            display: block;
        }}
        .timestamp {{
            position: absolute;
            top: 12px;
            left: 12px;
            background: rgba(0,0,0,0.75);
            color: #7c83ff;
            padding: 4px 10px;
            border-radius: 6px;
            font-size: 0.85rem;
            font-family: 'JetBrains Mono', 'Fira Code', monospace;
            font-weight: 600;
        }}
        .slide-text {{
            padding: 1.2rem 1.5rem;
        }}
        .slide-text p {{
            font-size: 1rem;
            line-height: 1.8;
            color: #d4d4d4;
        }}
        .stats {{
            text-align: center;
            color: #666;
            padding: 2rem;
            font-size: 0.85rem;
        }}
        .toc {{
            background: #1a1a1a;
            border-radius: 12px;
            padding: 1.5rem;
            margin-bottom: 2rem;
        }}
        .toc h2 {{
            font-size: 1rem;
            color: #7c83ff;
            margin-bottom: 1rem;
        }}
        .toc-list {{
            list-style: none;
            max-height: 300px;
            overflow-y: auto;
        }}
        .toc-list li {{
            padding: 0.3rem 0;
        }}
        .toc-list a {{
            color: #aaa;
            text-decoration: none;
            font-size: 0.85rem;
        }}
        .toc-list a:hover {{ color: #7c83ff; }}
        .toc-list .ts {{
            color: #7c83ff;
            font-family: monospace;
            margin-right: 0.5rem;
        }}
    </style>
</head>
<body>
    <div class="header">
        <h1>{title}</h1>
        <div class="meta">{meta_info}</div>
        <a href="{url}" target="_blank">YouTube에서 보기 &rarr;</a>
    </div>
    <div class="container">
        <div class="toc">
            <h2>목차 ({len(segments)}개 슬라이드)</h2>
            <ul class="toc-list">
"""

    for seg in segments:
        ts = escape(seg["timestamp"])
        text_preview = escape(seg["text"][:60]) + ("..." if len(seg["text"]) > 60 else "")
        html += f'                <li><a href="#slide-{seg["index"]}"><span class="ts">{ts}</span>{text_preview}</a></li>\n'

    html += f"""            </ul>
        </div>
{chr(10).join(html_segments)}
    </div>
    <div class="stats">{len(segments)}개 슬라이드 | Generated by youtube-slides</div>
</body>
</html>"""

    with open(output_path, "w", encoding="utf-8") as f:
        f.write(html)


def main():
    parser = argparse.ArgumentParser(description="캡쳐 프레임 + 자막 → 마크다운/HTML 생성")
    parser.add_argument("output_dir", help="출력 디렉토리 (segments.json이 있는 곳)")
    parser.add_argument("--title", default="YouTube Slides", help="영상 제목")
    parser.add_argument("--url", default="", help="YouTube URL")
    parser.add_argument("--channel", default="", help="채널명")
    parser.add_argument("--date", default="", help="업로드 날짜")
    parser.add_argument("--duration", default="", help="영상 길이")
    args = parser.parse_args()

    segments_path = os.path.join(args.output_dir, "segments.json")
    if not os.path.exists(segments_path):
        print(f"Error: {segments_path} 파일을 찾을 수 없습니다.")
        print("먼저 capture_frames.py를 실행하세요.")
        sys.exit(1)

    with open(segments_path, "r", encoding="utf-8") as f:
        segments = json.load(f)

    metadata = {
        "title": args.title,
        "url": args.url,
        "channel": args.channel,
        "date": args.date,
        "duration": args.duration,
    }

    md_path = os.path.join(args.output_dir, "slides.md")
    html_path = os.path.join(args.output_dir, "slides.html")

    generate_markdown(segments, metadata, md_path)
    generate_html(segments, metadata, html_path)

    print(f"마크다운: {md_path}")
    print(f"HTML:     {html_path}")


if __name__ == "__main__":
    main()
