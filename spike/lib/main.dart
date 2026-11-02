// Feasibility spike: can an unrooted app run Flutter's web toolchain on-device?
//
// On launch this runs every stage in order and skips stages already completed
// (see the `.done` markers), so relaunching resumes after a failure. Results go
// to the screen, logcat, and <files>/spike.log.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

const flutterVersion = '3.47.7';
const ubuntuUrl =
    'https://cdimage.ubuntu.com/ubuntu-base/releases/24.04/release/'
    'ubuntu-base-24.04.5-base-arm64.tar.gz';
const previewPort = 8099;
const prootAssets = ['proot', 'loader', 'libtalloc.so.2', 'libandroid-shmem.so'];

void main() => runApp(const MaterialApp(home: SpikePage()));

class SpikePage extends StatefulWidget {
  const SpikePage({super.key});

  @override
  State<SpikePage> createState() => _SpikePageState();
}

class _SpikePageState extends State<SpikePage> {
  final _lines = <String>[];
  final _scroll = ScrollController();
  WebViewController? _web;

  late final String _files;
  late final IOSink _log;
  Process? _server;

  String get _bin => '$_files/bin';
  String get _rootfs => '$_files/rootfs';

  @override
  void initState() {
    super.initState();
    unawaited(_run());
  }

  void _say(String line) {
    debugPrint('SPIKE $line');
    _log.writeln('${DateTime.now().toIso8601String()} $line');
    if (!mounted) return;
    setState(() {
      _lines.add(line);
      if (_lines.length > 400) _lines.removeAt(0);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  Future<void> _run() async {
    _files = await _filesDir();
    await Directory(_files).create(recursive: true);
    _log = File('$_files/spike.log').openWrite(mode: FileMode.append);
    try {
      _say('=== start, files=$_files');
      await _meminfo();
      await _stage('install_proot', _installProot);
      await _stage('download_ubuntu', _downloadUbuntu);
      await _stage('extract_ubuntu', _extractUbuntu);
      await _stage('apt_install', () => _sh(_aptScript));
      await _stage('clone_flutter', () => _sh(_cloneScript));
      await _stage('flutter_bootstrap', () => _sh(_bootstrapScript));
      await _stage('create_app', () => _sh(_createScript));
      await _sh(_benchScript);
      await _meminfo();
      await _serveAndReload();
      _say('=== SPIKE COMPLETE');
    } catch (e, st) {
      _say('=== SPIKE FAILED: $e\n$st');
    }
    await _log.flush();
  }

  /// dart:io can't ask for this directly and this spike has no plugin need for
  /// it; a debuggable app's data dir is derived from the package name.
  Future<String> _filesDir() async {
    final cmdline = await File('/proc/self/cmdline').readAsBytes();
    final name = utf8.decode(cmdline.takeWhile((b) => b != 0).toList());
    return '/data/data/$name/files';
  }

  Future<void> _stage(String name, Future<void> Function() body) async {
    final marker = File('$_files/$name.done');
    if (marker.existsSync()) {
      _say('--- $name: already done');
      return;
    }
    _say('--- $name: starting');
    final sw = Stopwatch()..start();
    await body();
    _say('--- $name: done in ${sw.elapsed.inSeconds}s');
    marker.writeAsStringSync('ok');
  }

  Future<void> _installProot() async {
    await Directory(_bin).create(recursive: true);
    for (final name in prootAssets) {
      final data = await rootBundle.load('assets/proot/$name');
      await File('$_bin/$name').writeAsBytes(data.buffer.asUint8List());
    }
    // This is the core W^X question: exec of a file the app itself wrote.
    await _exec('/system/bin/chmod', ['755', '$_bin/proot', '$_bin/loader']);
    await _exec('$_bin/proot', ['--version'], env: _prootEnv);
  }

  Future<void> _downloadUbuntu() async {
    final client = HttpClient();
    final response = await (await client.getUrl(Uri.parse(ubuntuUrl))).close();
    if (response.statusCode != 200) {
      throw 'download failed: ${response.statusCode}';
    }
    await response.pipe(File('$_files/ubuntu.tar.gz').openWrite());
    client.close();
  }

  Future<void> _extractUbuntu() async {
    await Directory(_rootfs).create(recursive: true);
    await Directory('$_files/tmp').create(recursive: true);
    await _exec(
      '$_bin/proot',
      [
        '--link2symlink',
        '-0',
        '/system/bin/tar',
        '-xzf',
        '$_files/ubuntu.tar.gz',
        '-C',
        _rootfs,
      ],
      env: _prootEnv,
      okCodes: {0, 1}, // Device nodes can't be created; those aren't needed.
    );
    File('$_rootfs/etc/resolv.conf')
      ..deleteSyncIfExists()
      ..writeAsStringSync('nameserver 8.8.8.8\nnameserver 1.1.1.1\n');
    File('$_rootfs/etc/hosts').writeAsStringSync('127.0.0.1 localhost\n');
    if (!File('$_rootfs/bin/bash').existsSync() &&
        !Link('$_rootfs/bin').existsSync()) {
      throw 'rootfs looks incomplete';
    }
  }

  Map<String, String> get _prootEnv => {
    'LD_LIBRARY_PATH': _bin,
    'PROOT_LOADER': '$_bin/loader',
    'PROOT_TMP_DIR': '$_files/tmp',
  };

  List<String> _prootArgs(String script) => [
    '--link2symlink',
    '--kill-on-exit',
    '-0',
    '-r',
    _rootfs,
    '-b',
    '/dev',
    '-b',
    '/proc',
    '-b',
    '/sys',
    '-b',
    '/system',
    '-b',
    '$_files/tmp:/tmp',
    '-w',
    '/root',
    '/usr/bin/env',
    '-i',
    'HOME=/root',
    'LANG=C.UTF-8',
    'TERM=dumb',
    'PUB_CACHE=/root/.pub-cache',
    'FLUTTER_SUPPRESS_ANALYTICS=true',
    'CI=true',
    'PATH=/root/flutter/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    '/bin/bash',
    '-c',
    script,
  ];

  Future<void> _sh(String script) => _exec(
    '$_bin/proot',
    _prootArgs('set -e\n$script'),
    env: _prootEnv,
  );

  Future<void> _exec(
    String exe,
    List<String> args, {
    Map<String, String>? env,
    Set<int> okCodes = const {0},
  }) async {
    final process = await Process.start(exe, args, environment: env);
    final out = _forward(process.stdout);
    final err = _forward(process.stderr);
    final code = await process.exitCode;
    await Future.wait([out, err]);
    if (!okCodes.contains(code)) throw '$exe exited with $code';
  }

  Future<void> _forward(Stream<List<int>> stream, [void Function(String)? on]) {
    return stream
        .transform(const Utf8Decoder(allowMalformed: true))
        .transform(const LineSplitter())
        .forEach((line) {
          _say(line);
          on?.call(line);
        });
  }

  Future<void> _meminfo() async {
    final lines = await File('/proc/meminfo').readAsLines();
    _say(
      'MEM ${lines.where((l) => l.startsWith('MemTotal') || l.startsWith('MemAvailable')).join(' | ')}',
    );
  }

  /// Serves the test app, waits for a real page to connect, then measures hot
  /// reload and hot restart the same way a user would trigger them.
  Future<void> _serveAndReload() async {
    final sw = Stopwatch()..start();
    final connected = Completer<void>();
    final reloaded = Completer<void>();
    final restarted = Completer<void>();
    final served = Completer<void>();

    final script =
        'cd /root/hello && flutter run -d web-server '
        '--web-port $previewPort --web-hostname 127.0.0.1';
    final process = await Process.start(
      '$_bin/proot',
      _prootArgs(script),
      environment: _prootEnv,
    );
    _server = process;
    unawaited(_forward(process.stderr));
    unawaited(
      _forward(process.stdout, (line) {
        if (line.contains('is being served at') && !served.isCompleted) {
          served.complete();
        }
        if (line.contains('Debug service listening') &&
            !connected.isCompleted) {
          connected.complete();
        }
        if (line.contains('Reloaded application') && !reloaded.isCompleted) {
          reloaded.complete();
        }
        if (line.contains('Restarted application') && !restarted.isCompleted) {
          restarted.complete();
        }
      }),
    );
    unawaited(
      process.exitCode.then((code) => _say('flutter run exited with $code')),
    );

    await served.future.timeout(const Duration(minutes: 20));
    _say('TIME first_compile_to_served ${sw.elapsed.inSeconds}s');
    await _meminfo();

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('http://127.0.0.1:$previewPort/'));
    if (mounted) setState(() => _web = controller);

    sw.reset();
    await connected.future.timeout(const Duration(minutes: 5));
    _say('TIME webview_connected ${sw.elapsed.inSeconds}s');
    await Future<void>.delayed(const Duration(seconds: 10));

    final main = File('$_rootfs/root/hello/lib/main.dart');
    await main.writeAsString(
      (await main.readAsString()).replaceAll(
        'Hello World!',
        'Hot reloaded on Android!',
      ),
    );
    sw.reset();
    process.stdin.write('r');
    await process.stdin.flush();
    await reloaded.future.timeout(const Duration(minutes: 3));
    _say('TIME hot_reload ${sw.elapsedMilliseconds}ms');

    await Future<void>.delayed(const Duration(seconds: 10));
    sw.reset();
    process.stdin.write('R');
    await process.stdin.flush();
    await restarted.future.timeout(const Duration(minutes: 3));
    _say('TIME hot_restart ${sw.elapsedMilliseconds}ms');
    await _meminfo();
  }

  @override
  void dispose() {
    _server?.kill();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final web = _web;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (web != null)
              Expanded(child: WebViewWidget(controller: web)),
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                itemCount: _lines.length,
                itemBuilder: (_, i) => Text(
                  _lines[i],
                  style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on File {
  void deleteSyncIfExists() {
    if (existsSync() || FileSystemEntity.isLinkSync(path)) deleteSync();
  }
}

const _aptScript = r'''
apt-get -o APT::Sandbox::User=root update
DEBIAN_FRONTEND=noninteractive apt-get -o APT::Sandbox::User=root \
  install -y --no-install-recommends git curl unzip xz-utils ca-certificates
git --version
''';

const _cloneScript =
    '''
rm -rf /root/flutter
git clone --depth 1 --branch $flutterVersion https://github.com/flutter/flutter.git /root/flutter
git config --global --add safe.directory /root/flutter
''';

const _bootstrapScript = r'''
flutter --version
flutter config --no-analytics
flutter precache --web --no-android --no-ios
''';

const _createScript = r'''
rm -rf /root/hello
flutter create --platforms=web --empty /root/hello
''';

const _benchScript = r'''
echo "BENCH proot/arch: $(uname -m), dart: $(dart --version 2>&1)"
s=$(date +%s%N); dart --version >/dev/null; e=$(date +%s%N)
echo "TIME dart_version $(( (e-s)/1000000 ))ms"
s=$(date +%s%N); flutter --version >/dev/null; e=$(date +%s%N)
echo "TIME flutter_version $(( (e-s)/1000000 ))ms"
s=$(date +%s%N); find /root/flutter/packages -type f | wc -l; e=$(date +%s%N)
echo "TIME find_packages $(( (e-s)/1000000 ))ms"
du -sh /root/flutter /root/hello || true
''';
