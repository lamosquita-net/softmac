#!/bin/bash
# Genera los flujos de prueba HLS (TS y fMP4, variante y maestra) y un MP4 de control.
# Uso: FlyWeb/tools/hls/generar.sh [carpeta]   (por defecto ./medios). Exige ffmpeg con libx264 o VideoToolbox.
set -euo pipefail
OUT="${1:-medios}"
mkdir -p "$OUT/ts" "$OUT/fmp4"
command -v ffmpeg >/dev/null || { echo "Falta ffmpeg (brew install ffmpeg)"; exit 1; }
VC=(-c:v libx264 -profile:v main -level 3.0 -pix_fmt yuv420p)
ENC=$(ffmpeg -hide_banner -encoders 2>/dev/null || true)
if ! grep -q libx264 <<<"$ENC"; then
  grep -q h264_videotoolbox <<<"$ENC" || { echo "ffmpeg sin libx264 ni VideoToolbox"; exit 1; }
  VC=(-c:v h264_videotoolbox -profile:v main -pix_fmt yuv420p)
fi
ffmpeg -y -loglevel error -f lavfi -i testsrc2=size=640x360:rate=30 -f lavfi -i sine=frequency=440:sample_rate=44100 \
  -t 12 "${VC[@]}" -g 60 -keyint_min 60 -sc_threshold 0 -c:a aac -b:a 96k -ar 44100 -shortest \
  -movflags +faststart "$OUT/control.mp4"
ffmpeg -y -loglevel error -i "$OUT/control.mp4" -c copy -f hls -hls_time 4 -hls_playlist_type vod \
  -hls_segment_filename "$OUT/ts/seg%03d.ts" "$OUT/ts/variante.m3u8"
ffmpeg -y -loglevel error -i "$OUT/control.mp4" -c copy -f hls -hls_time 4 -hls_playlist_type vod \
  -hls_segment_type fmp4 -hls_fmp4_init_filename init.mp4 -hls_segment_filename "$OUT/fmp4/seg%03d.m4s" \
  "$OUT/fmp4/variante.m3u8"
for f in ts fmp4; do
  printf '#EXTM3U\n#EXT-X-STREAM-INF:BANDWIDTH=900000,RESOLUTION=640x360,CODECS="avc1.4d401e,mp4a.40.2"\nvariante.m3u8\n' > "$OUT/$f/maestra.m3u8"
  printf '#EXTM3U\n#EXT-X-STREAM-INF:BANDWIDTH=900000\nvariante.m3u8\n' > "$OUT/$f/maestra-sin-codecs.m3u8"
  # Misma maestra sin la extensión .m3u8: obliga a la vía de respaldo (DEMUXER_ERROR_DETECTED_HLS).
  cp "$OUT/$f/maestra.m3u8" "$OUT/$f/maestra-sin-extension"
done
echo "Listo en $OUT"
