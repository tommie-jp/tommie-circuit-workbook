// sft-counter-la-defs.js — 01-counter の Logic Analyzer 信号定義 (11-2 で TD4 のレーンを足した)
//
// 素の <script src> で読み込む。js/rtlscope-la.js の前でも後でもよい（定義のみ）。
//
// ring buffer ビットレイアウト（1 サンプル = 1 word、examples/01-counter/cxx/harness.cpp）:
//   [ 7: 0] count   [ 8] rst
var COUNTER_RING_WORDS = 1;

var COUNTER_LA_SIGNALS = [
  // 11-2: TD4 の中を見るレーン (harness.cpp の record_sample で足したビット)
  { id:'td4_pc',  label:'PC',  word:0, bit:4,  type:'hex', width:4, color:'#aa5500', on:true, tip:'TD4 の PC (count[7:4])。' },
  { id:'td4_op',  label:'op',  word:0, bit:20, type:'hex', width:8, color:'#aa5500', on:true, tip:'TD4 のいまの命令 (ROM[PC])。' },
  { id:'td4_a',   label:'A',   word:0, bit:12, type:'hex', width:4, color:'#228833', on:true, tip:'TD4 のレジスタ A。' },
  { id:'td4_b',   label:'B',   word:0, bit:16, type:'hex', width:4, color:'#228833', on:true, tip:'TD4 のレジスタ B。' },
  { id:'td4_out', label:'OUT', word:0, bit:0,  type:'hex', width:4, color:'#228833', on:true, tip:'TD4 の出力ポート (count[3:0])。' },
  { id:'td4_c',   label:'C',   word:0, bit:9,  type:'bit', width:1, color:'#cc3333', on:true, tip:'TD4 の桁上げ (1 で桁上げあり)。' },
  { id:'count',     label:'count',  word:0, bit:0, type:'hex', width:8, color:'#0077cc', on:true,
    tip:'カウンタ出力（8 ビット、16 進表示）。クロックの立ち上がりごとに 1 ずつ増え、0xFF の次は 0x00 に戻ります。' },
  { id:'count_dec', label:'count10', word:0, bit:0, type:'hex', width:8, color:'#0099aa', on:false, fmt:'dec',
    tip:'カウンタ出力の 10 進表示。count と同じビット [7:0] を 10 進で見ます。' },
  { id:'rst',       label:'rst',    word:0, bit:8, type:'bit', width:1, color:'#cc3333', on:true,
    tip:'リセット入力。1 の間 count は 0 に固定されます（非同期リセット）。Reset ボタンで 2 クロック分だけ 1 になります。' },
  { id:'b7', label:'b7', word:0, bit:7, type:'bit', width:1, color:'#7722aa', on:true,
    tip:'count[7]（最上位ビット）。周期は 256 クロック。b0 の 1/128 の速さで変化します。' },
  { id:'b6', label:'b6', word:0, bit:6, type:'bit', width:1, color:'#7722aa', on:true,
    tip:'count[6]。周期は 128 クロック。' },
  { id:'b5', label:'b5', word:0, bit:5, type:'bit', width:1, color:'#7722aa', on:true,
    tip:'count[5]。周期は 64 クロック。' },
  { id:'b4', label:'b4', word:0, bit:4, type:'bit', width:1, color:'#7722aa', on:true,
    tip:'count[4]。周期は 32 クロック。' },
  { id:'b3', label:'b3', word:0, bit:3, type:'bit', width:1, color:'#7722aa', on:true,
    tip:'count[3]。周期は 16 クロック。' },
  { id:'b2', label:'b2', word:0, bit:2, type:'bit', width:1, color:'#7722aa', on:true,
    tip:'count[2]。周期は 8 クロック。' },
  { id:'b1', label:'b1', word:0, bit:1, type:'bit', width:1, color:'#7722aa', on:true,
    tip:'count[1]。周期は 4 クロック。' },
  { id:'b0', label:'b0', word:0, bit:0, type:'bit', width:1, color:'#7722aa', on:true,
    tip:'count[0]（最下位ビット）。毎クロック反転します（周期 2 クロック）。' },
];

var COUNTER_LA_GROUPS = [
  { label:'TD4',     color:'#aa5500', ids:['td4_pc','td4_op','td4_a','td4_b','td4_out','td4_c'] },
  { label:'Count',   color:'#0066bb', ids:['count','count_dec'] },
  { label:'Control', color:'#bb3333', ids:['rst'] },
  { label:'Bits',    color:'#7722aa', ids:['b7','b6','b5','b4','b3','b2','b1','b0'] },
];

// RTLScopeLA コンストラクタに渡す設定。
var COUNTER_LA_CONFIG = {
  canvasId:       'la',
  togglesId:      'la-toggles',
  signals:        COUNTER_LA_SIGNALS,
  groups:         COUNTER_LA_GROUPS,
  ringWords:      COUNTER_RING_WORDS,
  ringSize:       4096,        // harness.cpp の RING_SIZE と一致させる（起動時に上書き）
  storagePrefix:  'counter_la_',
  width:          1200,
  labelWidth:     72,
  trackH:         26,
  numberedLabels: false,
  decodeLane:     null,        // マシンサイクル等のデコードは持たない
};
