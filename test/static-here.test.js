const assert = require('node:assert/strict');
const fs = require('node:fs');
const http = require('node:http');
const net = require('node:net');
const os = require('node:os');
const path = require('node:path');
const { spawn } = require('node:child_process');
const { test } = require('node:test');

function freePort() {
  return new Promise(function (resolve, reject) {
    const probe = net.createServer();
    probe.once('error', reject);
    probe.listen(0, '127.0.0.1', function () {
      const port = probe.address().port;
      probe.close(function () { resolve(port); });
    });
  });
}

function request(port, pathname) {
  return new Promise(function (resolve, reject) {
    http.get({ host: '127.0.0.1', port: port, path: pathname }, function (response) {
      const chunks = [];
      response.on('data', function (chunk) { chunks.push(chunk); });
      response.on('end', function () {
        resolve({ status: response.statusCode, body: Buffer.concat(chunks).toString() });
      });
    }).once('error', reject);
  });
}

async function waitForServer(port) {
  for (let attempt = 0; attempt < 50; attempt++) {
    try {
      return await request(port, '/');
    } catch (error) {
      if (error.code !== 'ECONNREFUSED') throw error;
      await new Promise(function (resolve) { setTimeout(resolve, 10); });
    }
  }
  throw new Error('server did not accept connections');
}

test('local static server keeps requests inside its public root', async function (t) {
  const base = fs.mkdtempSync(path.join(os.tmpdir(), 'moedict-static-'));
  const root = path.join(base, 'public');
  fs.mkdirSync(root);
  fs.mkdirSync(path.join(root, '.git'));
  fs.writeFileSync(path.join(root, 'index.html'), 'public index');
  fs.writeFileSync(path.join(root, '.git', 'config'), 'private config');
  fs.writeFileSync(path.join(base, 'secret.txt'), 'private secret');
  fs.symlinkSync(path.join(base, 'secret.txt'), path.join(root, 'linked.txt'));
  fs.symlinkSync(path.join(root, '.git'), path.join(root, 'hidden-link'));

  const port = await freePort();
  const child = spawn(process.execPath, [path.join(__dirname, '..', 'static-here.js'), String(port)], {
    cwd: root,
    stdio: ['ignore', 'pipe', 'pipe'],
  });
  t.after(function () {
    child.kill();
    fs.rmSync(base, { recursive: true, force: true });
  });
  await new Promise(function (resolve, reject) {
    const timeout = setTimeout(function () { reject(new Error('server did not start')); }, 5000);
    child.stdout.once('data', function (data) {
      clearTimeout(timeout);
      if (!data.toString().includes('http://127.0.0.1:' + port + '/')) {
        reject(new Error('server did not bind to loopback by default'));
        return;
      }
      resolve();
    });
    child.once('error', function (error) { clearTimeout(timeout); reject(error); });
    child.once('exit', function (code) {
      clearTimeout(timeout);
      reject(new Error('server exited: ' + code));
    });
  });

  assert.deepEqual(await waitForServer(port), { status: 200, body: 'public index' });
  assert.equal((await request(port, '/.git/config')).status, 403);
  assert.equal((await request(port, '/%2e%2e/secret.txt')).status, 403);
  assert.equal((await request(port, '/%ZZ')).status, 400);
  assert.equal((await request(port, '/linked.txt')).status, 403);
  assert.equal((await request(port, '/hidden-link/config')).status, 403);
});
