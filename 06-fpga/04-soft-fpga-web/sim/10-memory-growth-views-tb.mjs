// WebAssembly.Memory.grow() で古い ArrayBuffer が切り離されることを node で確かめる (Emscripten なし)
const MB = 1024 * 1024;
const mem = new WebAssembly.Memory({ initial: 258, maximum: 32768 }); // 258 ページ = 16.125 MB
const heapOld = new Uint32Array(mem.buffer);
const ptr = 1040;
const ringOld = new Uint32Array(mem.buffer, ptr, 1024);
for (let i = 0; i < 1024; i++) ringOld[i] = 1000 + i;
const show = (l) => console.log(l, { heapMB: mem.buffer.byteLength / MB, 'heapOld.byteLength': heapOld.byteLength,
  'ringOld.byteLength': ringOld.byteLength, 'ringOld.length': ringOld.length, 'ringOld[5]': ringOld[5],
  detached: ringOld.buffer.detached, 'same buffer': ringOld.buffer === mem.buffer });
show('before');
mem.grow(512); // +32 MB
show('after ');
const ringNew = new Uint32Array(mem.buffer, ptr, 1024);
console.log('ringNew[5]', ringNew[5], 'new heap byteLength', new Uint32Array(mem.buffer).byteLength);
