/**
 * 同じ題の回路図 (` ```circuit `) と実体配線図 (` ```breadboard ` / ` ```perfboard `) の
 * ネットリストが一致するかを確かめる。
 *
 * **図ごとの check は「読めた・つながった」しか見ない。** ブレッドボードで SIP3 の足を
 * 取り違えても (GND が浮き、出力が GND)、実体配線図だけなら筋の通った回路として通る。
 * そこで両方の図にある部品だけを残し、ネットごとの「乗っている部品の組」を比べる。
 * 足の名前は図ごとに違う (`U1.source` と `U1.S`) ので、部品の単位で比べる。
 *
 * 見かけの違いのうち、決まった形のものは黙って許す:
 * - 片方の図だけが部品の足を多く描く (回路図が OP アンプ・IC の電源の足を描かない)。
 *   足の多い側のネットからその部品を外して、もう片方と合えば同じとみる
 * - 片方の図だけにある電流計 (A1) と線路 (T1) は、足 2 本のネットをつないだ線とみる
 *   (板では電流計の隙間を線で埋める、線路は基板の上では短い線になる)
 * 残る見かけの違いは `netlist-parity-allow.json` に題・図・理由を書いて許す。
 */

import { spawnSync } from 'node:child_process';
import { readFileSync } from 'node:fs';
import { basename, join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { ROOT, readEntries } from './collect.mjs';
import { cliPath, fencesIn } from './fences.mjs';

export const ALLOW_FILE = 'scripts/netlist-parity-allow.json';
const BOARDS = ['breadboard', 'perfboard'];

/** 部品の名前 (R1・U2・NTC1・Rt1)。計器 (AD)・電源の記号 (GND・VCC・G1 は除けない) と分ける。 */
const PART = /^[A-Z]+[A-Za-z]*\d/;
const HEADER = /^(\S.*) \((\d+) 行目\)/;
const NET = /^\s{4}(\S+)\s*:\s*(.+)$/;

/** check --verbose の出力を図ごとに分ける。ネットは部品の名前 (足を落とす) の並び。 */
export function parseCheckOutput(out) {
  const read = [];
  for (const line of out.split('\n')) {
    const header = HEADER.exec(line);
    if (header !== null) {
      read.push({ stem: header[1], line: Number(header[2]), nets: [] });
      continue;
    }
    const net = NET.exec(line);
    if (net !== null && read.length > 0) read.at(-1).nets.push(net[2].split(/,\s*/).map((pin) => pin.split('.')[0]));
  }
  return read;
}

const partsOf = (diagram) => new Set(diagram.nets.flat().filter((name) => PART.test(name)));

/** 部品ごとの、足が乗っているネットの数。 */
function pinCounts(diagram) {
  const counts = new Map();
  for (const net of diagram.nets) for (const part of new Set(net)) counts.set(part, (counts.get(part) ?? 0) + 1);
  return counts;
}

/** 片方の図だけにあるとき、線とみる部品 (電流計・線路)。 */
const WIRE_LIKE = /^[AT]\d/;

/** 足 2 つのネットにまたがる部品 `part` を線とみて、その 2 つのネットを 1 つにする。 */
function shortOut(nets, part) {
  const touching = nets.filter((net) => net.includes(part));
  if (touching.length !== 2) return nets;
  const merged = touching.flat().filter((name) => name !== part);
  return [...nets.filter((net) => !touching.includes(net)), merged];
}

const shortOutAll = (diagram, parts) => ({ ...diagram, nets: parts.reduce(shortOut, diagram.nets) });

const signature = (parts) => [...new Set(parts)].sort().join(',');

/** 共通の部品だけで見たネット (2 部品以上) の組。 */
const netsOver = (diagram, common) =>
  diagram.nets.map((net) => net.filter((part) => common.has(part))).filter((net) => new Set(net).size >= 2).map(signature).sort();

/** a から b を多重集合として引く。 */
function minus(a, b) {
  const rest = [...b];
  return a.filter((x) => {
    const at = rest.indexOf(x);
    if (at < 0) return true;
    rest.splice(at, 1);
    return false;
  });
}

/**
 * 足の多い側だけにある部品 (extra) を外すと、相手の図のネットと合う・1 部品だけになるネットを落とす。
 * 落とした相手のネットも、まだ合っていなければ消す。
 */
function excuseExtraPins(mine, theirs, theirAll, extra) {
  if (extra.size === 0) return { mine, theirs };
  let rest = theirs;
  const kept = mine.filter((net) => {
    const parts = net.split(',');
    if (!parts.some((part) => extra.has(part))) return true;
    const reduced = parts.filter((part) => !extra.has(part));
    if (reduced.length < 2) return false;
    const key = reduced.join(',');
    if (rest.includes(key)) {
      rest = minus(rest, [key]);
      return false;
    }
    return !theirAll.includes(key);
  });
  return { mine: kept, theirs: rest };
}

/** 回路図と実体配線図の違い。`onlyCircuit` `onlyBoard` は部品の組 (`C5,FL1,L2`)。 */
export function compareDiagrams(circuit, board) {
  const onlyIn = (a, b) => [...partsOf(a)].filter((part) => WIRE_LIKE.test(part) && !partsOf(b).has(part));
  const drawn = compareAsDrawn(circuit, board);
  const shorted = compareAsDrawn(shortOutAll(circuit, onlyIn(circuit, board)), shortOutAll(board, onlyIn(board, circuit)));
  // 相手の図が電流計を部品番号の無い計器 (AM) で描くこともあるので、違いの少ない方を採る。
  return differences(shorted) < differences(drawn) ? shorted : drawn;
}

function compareAsDrawn(circuit, board) {
  const inBoard = partsOf(board);
  const common = new Set([...partsOf(circuit)].filter((part) => inBoard.has(part)));
  const sc = netsOver(circuit, common);
  const sb = netsOver(board, common);
  const pc = pinCounts(circuit);
  const pb = pinCounts(board);
  const extraBoard = new Set([...common].filter((part) => pb.get(part) > pc.get(part)));
  const extraCircuit = new Set([...common].filter((part) => pc.get(part) > pb.get(part)));

  let onlyCircuit = minus(sc, sb);
  let onlyBoard = minus(sb, sc);
  ({ mine: onlyBoard, theirs: onlyCircuit } = excuseExtraPins(onlyBoard, onlyCircuit, sc, extraBoard));
  ({ mine: onlyCircuit, theirs: onlyBoard } = excuseExtraPins(onlyCircuit, onlyBoard, sb, extraCircuit));
  return { onlyCircuit, onlyBoard, common: common.size };
}

const differences = (result) => result.onlyCircuit.length + result.onlyBoard.length;

/**
 * 実体配線図ごとに組む回路図を選んで比べる。共通の部品が多い回路図、同数なら違いの少ない回路図
 * (それでも同じなら前にある方)。共通の部品が 2 つ未満なら比べない (計器だけの図など)。
 */
export function pairBoards(diagrams) {
  const circuits = diagrams.filter((d) => d.kind === 'circuit' && d.nets.length > 0);
  const pairs = [];
  for (const board of diagrams.filter((d) => BOARDS.includes(d.kind) && d.nets.length > 0)) {
    let best = null;
    for (const circuit of circuits) {
      const { onlyCircuit, onlyBoard, common } = compareDiagrams(circuit, board);
      const candidate = { board, circuit, onlyCircuit, onlyBoard, common };
      if (best === null || common > best.common || (common === best.common && differences(candidate) < differences(best))) {
        best = candidate;
      }
    }
    if (best !== null && best.common >= 2) pairs.push(best);
  }
  return pairs;
}

const sameFigure = (result, permit) => result.file === permit.file && result.board === permit.board;

/** 許可にない違いは失敗。違いの無くなった (図や題が消えた) 許可は古い。 */
export function judge(results, allow) {
  const differing = results.filter((result) => differences(result) > 0);
  return {
    failures: differing.filter((result) => !allow.some((permit) => sameFigure(result, permit))),
    allowed: differing.filter((result) => allow.some((permit) => sameFigure(result, permit))),
    stale: allow.filter((permit) => !differing.some((result) => sameFigure(result, permit))),
  };
}

const titleOf = (lines) => (lines.map((line) => /^\s*title:\s*(.*)$/.exec(line)).find(Boolean) ?? [, '(題なし)'])[1].trim();

/** 回路図と実体配線図のある題について、図を出てくる順に集め、道具ごとに 1 度だけ check を回して読む。 */
function readDiagrams(reads) {
  const figures = [];
  for (const read of reads) {
    const { blocks } = fencesIn(read.text);
    if (!blocks.some((block) => BOARDS.includes(block.fence))) continue;
    const lines = read.text.split('\n');
    for (const block of blocks.filter((b) => b.fence === 'circuit' || BOARDS.includes(b.fence))) {
      const body = lines.slice(block.open, block.close ?? lines.length);
      figures.push({ file: read.path, kind: block.fence, line: block.open + 1, title: titleOf(body), nets: [] });
    }
  }

  for (const kind of ['circuit', ...BOARDS]) {
    const mine = figures.filter((figure) => figure.kind === kind);
    const paths = [...new Set(mine.map((figure) => figure.file))];
    if (paths.length === 0) continue;
    const run = spawnSync(process.execPath, [cliPath(ROOT, kind), 'check', ...paths], { cwd: ROOT, encoding: 'utf8', maxBuffer: 1 << 28 });
    // 道具は渡した順に図を出す。名前 (拡張子なし) と行で、次に来るはずの図に当てる。
    let at = 0;
    for (const read of parseCheckOutput(run.stdout)) {
      while (at < mine.length && (basename(mine[at].file, '.md') !== read.stem || mine[at].line !== read.line)) at += 1;
      if (at === mine.length) break;
      mine[at].nets = read.nets;
      at += 1;
    }
  }
  return figures;
}

function compareAll(reads) {
  const figures = readDiagrams(reads);
  const files = [...new Set(figures.map((figure) => figure.file))];
  return files.flatMap((file) =>
    pairBoards(figures.filter((figure) => figure.file === file)).map(({ board, circuit, onlyCircuit, onlyBoard }) => ({
      file, board: board.title, circuit: circuit.title, onlyCircuit, onlyBoard,
    })));
}

const describe = (result) => [
  `${result.file}\n    実体配線図: ${result.board}\n    回路図: ${result.circuit}`,
  ...result.onlyCircuit.map((net) => `    回路図だけ: ${net}`),
  ...result.onlyBoard.map((net) => `    実体配線図だけ: ${net}`),
].join('\n');

function main(args) {
  const verbose = args.includes('--verbose');
  const allow = JSON.parse(readFileSync(join(ROOT, ALLOW_FILE), 'utf8'));
  const results = compareAll(readEntries());
  const { failures, allowed, stale } = judge(results, allow);

  if (verbose) for (const result of allowed) console.log(`(許可済み) ${describe(result)}`);
  for (const result of failures) console.error(`--- 回路図と実体配線図のネットが合わない\n${describe(result)}`);
  for (const permit of stale) {
    console.error(`--- 許可が古い (もう違いが無いか、題・図が無い): ${permit.file} / ${permit.board} — ${ALLOW_FILE} から消す`);
  }
  if (failures.length > 0 || stale.length > 0) {
    console.error(`\n合わない組 ${failures.length}、古い許可 ${stale.length}。図を直すか、見かけの違いなら理由を書いて ${ALLOW_FILE} に足す`);
    process.exit(1);
  }
  console.log(`回路図と実体配線図を ${results.length} 組比べた。許可済みの違い ${allowed.length} 組のほかは一致`);
}

if (import.meta.url === pathToFileURL(process.argv[1]).href) main(process.argv.slice(2));
