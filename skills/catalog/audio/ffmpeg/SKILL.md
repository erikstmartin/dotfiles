---
name: ffmpeg
description: Use when programmatically processing video/audio with libffmpeg C API. Not for command-line ffmpeg operations.
---

## Workflow

### 1. Setup Context & Input

Initialize libffmpeg components and open input file:

```c
#include <libavformat/avformat.h>
#include <libavcodec/avcodec.h>
#include <libswscale/swscale.h>
#include <libavutil/imgutils.h>

int main() {
    // Initialize libavformat and register all formats/codecs
    av_register_all();
    
    AVFormatContext *fmt_ctx = NULL;
    if (avformat_open_input(&fmt_ctx, "input.mp4", NULL, NULL) < 0) {
        fprintf(stderr, "Error opening input file\n");
        return -1;
    }
    
    // Retrieve stream information
    if (avformat_find_stream_info(fmt_ctx, NULL) < 0) {
        fprintf(stderr, "Error finding stream info\n");
        return -1;
    }
    
    // Find video stream
    int video_stream_idx = av_find_best_stream(fmt_ctx, AVMEDIA_TYPE_VIDEO, -1, -1, NULL, 0);
    if (video_stream_idx < 0) {
        fprintf(stderr, "No video stream found\n");
        return -1;
    }
```

### 2. Decoder Setup

Configure decoder for the input stream:

```c
    AVStream *video_stream = fmt_ctx->streams[video_stream_idx];
    AVCodecParameters *codecpar = video_stream->codecpar;
    
    // Find decoder
    const AVCodec *decoder = avcodec_find_decoder(codecpar->codec_id);
    if (!decoder) {
        fprintf(stderr, "Decoder not found\n");
        return -1;
    }
    
    // Allocate codec context
    AVCodecContext *dec_ctx = avcodec_alloc_context3(decoder);
    if (avcodec_parameters_to_context(dec_ctx, codecpar) < 0) {
        fprintf(stderr, "Failed to copy decoder parameters\n");
        return -1;
    }
    
    // Open decoder
    if (avcodec_open2(dec_ctx, decoder, NULL) < 0) {
        fprintf(stderr, "Failed to open decoder\n");
        return -1;
    }
```

### 3. Frame Processing Loop

Decode and process frames:

```c
    AVPacket *packet = av_packet_alloc();
    AVFrame *frame = av_frame_alloc();
    AVFrame *filtered_frame = av_frame_alloc();
    
    while (av_read_frame(fmt_ctx, packet) >= 0) {
        if (packet->stream_index == video_stream_idx) {
            // Send packet to decoder
            int ret = avcodec_send_packet(dec_ctx, packet);
            if (ret < 0) continue;
            
            // Receive decoded frame
            while (ret >= 0) {
                ret = avcodec_receive_frame(dec_ctx, frame);
                if (ret == AVERROR(EAGAIN) || ret == AVERROR_EOF) break;
                if (ret < 0) {
                    fprintf(stderr, "Error during decoding\n");
                    break;
                }
                
                // Process frame (scaling, filtering, etc.)
                process_frame(frame, filtered_frame);
            }
        }
        av_packet_unref(packet);
    }
```

### 4. Encoder Setup & Output

Configure encoder and write processed frames:

```c
// Find encoder
const AVCodec *encoder = avcodec_find_encoder(AV_CODEC_ID_H264);
AVCodecContext *enc_ctx = avcodec_alloc_context3(encoder);

// Set encoder parameters
enc_ctx->width = 1920;
enc_ctx->height = 1080;
enc_ctx->pix_fmt = AV_PIX_FMT_YUV420P;
enc_ctx->time_base = (AVRational){1, 25}; // 25 fps
enc_ctx->bit_rate = 2000000; // 2 Mbps

// Open encoder
if (avcodec_open2(enc_ctx, encoder, NULL) < 0) {
    fprintf(stderr, "Could not open encoder\n");
    return -1;
}

// Encode frame
AVPacket *output_packet = av_packet_alloc();
int ret = avcodec_send_frame(enc_ctx, filtered_frame);
while (ret >= 0) {
    ret = avcodec_receive_packet(enc_ctx, output_packet);
    if (ret == AVERROR(EAGAIN) || ret == AVERROR_EOF) break;
    if (ret < 0) break;
    
    // Write packet to output file
    av_packet_unref(output_packet);
}
```

---

## Key API Patterns

**Memory management:** Always pair `av_*_alloc()` with `av_*_free()`. Use `av_packet_unref()` after processing packets.

**Error handling:** Most libavformat/libavcodec functions return `< 0` on error. Check `AVERROR(EAGAIN)` and `AVERROR_EOF` for expected conditions.

**Pixel format conversion:**
```c
struct SwsContext *sws_ctx = sws_getContext(
    src_width, src_height, src_pix_fmt,
    dst_width, dst_height, dst_pix_fmt,
    SWS_BILINEAR, NULL, NULL, NULL);

sws_scale(sws_ctx, frame->data, frame->linesize, 0, src_height,
          scaled_frame->data, scaled_frame->linesize);
```

**Seeking:** Use `av_seek_frame()` with `AVSEEK_FLAG_BACKWARD` for keyframe seeks.

## Common Pitfalls

- **Initialization:** Call `av_register_all()` before any other libav* functions
- **Threading:** libavcodec is not thread-safe by default. Use `avcodec_open2()` with thread options if needed
- **Memory leaks:** Every `av_frame_alloc()` needs `av_frame_free()`, every `av_packet_alloc()` needs `av_packet_free()`
- **Pixel formats:** Ensure encoder supports the pixel format from decoder or add conversion step
