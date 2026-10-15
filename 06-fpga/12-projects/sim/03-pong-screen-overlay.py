# 12-3 の図1: 公開ページのスクリーンショットに、形の名前と位置の数を重ねる
#   python3 -I 03-pong-screen-overlay.py 03-pong-screen-raw.png ../03-pong-screen.png
# スクリーンショット (raw) は https://tommie-jp.github.io/soft-fpga/91-pong/ を開いて撮った (625 × 514)。
# 出力は、ゲーム画面の部分だけを切り出した画像 (ボタンの行と画面の外の余白は含めない)。
# 画面は 1 画素 3.6 画素、左上が (x, y) = (8.4, 6.0)。フォントは Noto Sans CJK JP Bold。
import sys
from PIL import Image, ImageDraw, ImageFont
src, out = sys.argv[1], sys.argv[2]
im = Image.open(src).convert('RGB')
d = ImageDraw.Draw(im)
S, OX, OY = 3.6, 8.4, 6.0                      # 1 画素の大きさ・画面の左上 (スクリーンショット上)
X = lambda h: OX + S * h
Y = lambda v: OY + S * v
FONT = '/usr/share/fonts/opentype/noto/NotoSansCJK-Bold.ttc'
f = ImageFont.truetype(FONT, 15, index=0)
fs = ImageFont.truetype(FONT, 13, index=0)

WALL, PADDLE, SCORE, NET, BALL = (120, 190, 255), (90, 230, 120), (255, 235, 90), (230, 230, 230), (255, 150, 90)

def box(h0, v0, h1, v1, color, pad=3):          # 画素の範囲 [h0, h1] × [v0, v1] を囲む
    d.rectangle([X(h0) - pad, Y(v0) - pad, X(h1 + 1) + pad, Y(v1 + 1) + pad], outline=color, width=2)

def text(xy, s, color, font=f, anchor='la'):
    d.text(xy, s, font=font, fill=color, anchor=anchor, stroke_width=3, stroke_fill=(0, 0, 0))

def leader(p0, p1, color):
    d.line([p0, p1], fill=color, width=2)
    d.ellipse([p1[0] - 3, p1[1] - 3, p1[0] + 3, p1[1] + 3], fill=color)

# 壁
box(0, 0, 159, 1, WALL, 1); box(0, 118, 159, 119, WALL, 1)
text((14, 44), '上の壁  v 0〜1 (h は全部)', WALL)
leader((150, 43), (150, 14), WALL)
text((14, 393), '下の壁  v 118〜119 (h は全部)', WALL)
leader((60, 413), (60, 430), WALL)

# ラケット (スクリーンショットの白い帯の縦の範囲を数える)
box(6, 52, 8, 67, PADDLE); box(151, 52, 153, 67, PADDLE)
text((X(11), Y(53)), '左のラケット', PADDLE)
text((X(11), Y(53) + 20), 'h 6〜8、v pl〜pl+15 (3 × 16)', PADDLE, fs)
text((X(148), Y(53)), '右のラケット', PADDLE, anchor='ra')
text((X(148), Y(53) + 20), 'h 151〜153、v pr〜pr+15', PADDLE, fs, anchor='ra')

# ネット
box(79, 0, 79, 119, NET, 2)
text((X(79) + 12, Y(95)), 'ネット  h 79', NET)
text((X(79) + 12, Y(95) + 20), 'v の 2 の位が 1 の画素 (4 画素おき)', NET, fs)

# 点
box(60, 6, 67, 19, SCORE); box(92, 6, 99, 19, SCORE)
text((X(60) - 8, Y(22)), '点 L (sl)', SCORE, anchor='ra')
text((X(60) - 8, Y(22) + 20), 'h 60〜67、v 6〜19', SCORE, fs, anchor='ra')
text((X(100) + 6, Y(22)), '点 R (sr)', SCORE)
text((X(100) + 6, Y(22) + 20), 'h 92〜99、v 6〜19', SCORE, fs)

# 球 (スクリーンショットの球は左端 146 px、上端 143 px)
bx, by = round((146 - OX) / S), round((143 - 6) / S)
box(bx, by, bx + 2, by + 2, BALL, 4)
text((X(bx) - 12, Y(by) - 4), '球 3 × 3 (bx, by)', BALL, anchor='ra')
text((X(bx) - 12, Y(by) + 16), f'いまは ({bx}, {by})', BALL, fs, anchor='ra')

# 座標の向き
text((14, 17), '(h, v) = (0, 0)', (255, 255, 255), fs)
text((X(160) - 6, Y(118) - 2), '(159, 119)', (255, 255, 255), fs, anchor='rd')
d.line([(330, 415), (400, 415)], fill=(255, 255, 255), width=2); d.polygon([(400, 410), (410, 415), (400, 420)], fill=(255, 255, 255))
text((418, 414), 'h (横 0〜159)', (255, 255, 255), fs, anchor='lm')
d.line([(14, 76), (14, 108)], fill=(255, 255, 255), width=2); d.polygon([(9, 108), (14, 118), (19, 108)], fill=(255, 255, 255))
text((24, 92), 'v (縦 0〜119)', (255, 255, 255), fs, anchor='lm')
# ゲーム画面 (canvas) の部分だけを切り出す。下のボタンの行と、画面の外の余白は要らない
im = im.crop((int(OX) - 1, int(OY) - 1, int(OX + 160 * S) + 3, int(OY + 120 * S) + 2))
im.save(out, optimize=True)
print(im.size, 'ball', bx, by)
