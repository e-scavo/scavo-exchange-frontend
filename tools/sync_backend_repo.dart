import 'dart:convert';
import 'dart:io';

import 'package:dartssh2/dartssh2.dart';

const String kDefaultConfigPath = 'tools/sync_backend_repo.local.json';

Future<void> main(List<String> args) async {
  final bool verbose = !args.contains('--quiet');
  final bool clean = args.contains('--clean');
  final String configPath =
      _readArgumentValue(args, '--config') ?? kDefaultConfigPath;

  final config = await SyncConfig.load(configPath);

  stdout.writeln('========================================');
  stdout.writeln('SCAVO Exchange Backend Downloader');
  stdout.writeln('Mode       : full copy');
  stdout.writeln('Remote root: ${config.remoteRoot}');
  stdout.writeln('Local root : ${config.localRoot}');
  stdout.writeln('Excludes   : ${config.excludePatterns.join(', ')}');
  stdout.writeln('Clean      : $clean');
  stdout.writeln('Config     : $configPath');
  stdout.writeln('========================================');

  SSHSocket? socket;
  SSHClient? client;
  SftpClient? sftp;

  try {
    final localRootDir = Directory(config.localRoot);

    if (clean && localRootDir.existsSync()) {
      if (verbose) {
        stdout.writeln('CLEAN       ${localRootDir.absolute.path}');
      }
      localRootDir.deleteSync(recursive: true);
    }

    if (!localRootDir.existsSync()) {
      localRootDir.createSync(recursive: true);
    }

    if (verbose) {
      stdout.writeln('CONNECT     ${config.host}:${config.port}');
    }

    socket = await SSHSocket.connect(config.host, config.port);

    client = SSHClient(
      socket,
      username: config.username,
      onPasswordRequest: () => config.password,
    );

    sftp = await client.sftp();

    final stats = CopyStats();

    await copyDirectoryRecursive(
      sftp: sftp,
      remoteDirPath: normalizeRemotePath(config.remoteRoot),
      localDirPath: localRootDir.absolute.path,
      verbose: verbose,
      stats: stats,
      excludePatterns: config.excludePatterns,
    );

    stdout.writeln('');
    stdout.writeln('Copy finished');
    stdout.writeln('  Directories created : ${stats.directoriesCreated}');
    stdout.writeln('  Files downloaded    : ${stats.filesDownloaded}');
    stdout.writeln('  Entries excluded    : ${stats.entriesExcluded}');
    stdout.writeln('  Bytes downloaded    : ${stats.bytesDownloaded}');
  } catch (e, st) {
    stderr.writeln('Error: $e');
    stderr.writeln(st);
    exitCode = 1;
  } finally {
    try {
      sftp?.close();
    } catch (_) {}

    try {
      client?.close();
    } catch (_) {}

    try {
      socket?.close();
    } catch (_) {}
  }
}

class SyncConfig {
  const SyncConfig({
    required this.host,
    required this.port,
    required this.username,
    required this.password,
    required this.remoteRoot,
    required this.localRoot,
    required this.excludePatterns,
  });

  final String host;
  final int port;
  final String username;
  final String password;
  final String remoteRoot;
  final String localRoot;
  final List<String> excludePatterns;

  static Future<SyncConfig> load(String configPath) async {
    final file = File(configPath);
    if (!file.existsSync()) {
      throw StateError(
        'Missing local sync config at "$configPath". Create it from tools/sync_backend_repo.example.json.',
      );
    }

    final dynamic decoded = jsonDecode(await file.readAsString());
    if (decoded is! Map<String, dynamic>) {
      throw StateError('Invalid sync config JSON structure.');
    }

    return SyncConfig(
      host: decoded['host']?.toString() ?? '',
      port: (decoded['port'] as num?)?.toInt() ?? 22,
      username: decoded['username']?.toString() ?? '',
      password: decoded['password']?.toString() ?? '',
      remoteRoot: decoded['remote_root']?.toString() ?? '',
      localRoot:
          decoded['local_root']?.toString() ?? '../scavo.exchange-backend',
      excludePatterns: (decoded['exclude_patterns'] as List<dynamic>? ??
              const <dynamic>['.git', '*.zip'])
          .map((item) => item.toString())
          .toList(growable: false),
    );
  }
}

class CopyStats {
  int directoriesCreated = 0;
  int filesDownloaded = 0;
  int entriesExcluded = 0;
  int bytesDownloaded = 0;
}

Future<void> copyDirectoryRecursive({
  required SftpClient sftp,
  required String remoteDirPath,
  required String localDirPath,
  required bool verbose,
  required CopyStats stats,
  required List<String> excludePatterns,
}) async {
  final localDir = Directory(localDirPath);

  if (!localDir.existsSync()) {
    localDir.createSync(recursive: true);
    stats.directoriesCreated++;
    if (verbose) {
      stdout.writeln('CREATE DIR   $localDirPath');
    }
  }

  if (verbose) {
    stdout.writeln('SCAN         $remoteDirPath');
  }

  final List<SftpName> items = await sftp.listdir(remoteDirPath);

  for (final item in items) {
    final String name = item.filename;

    if (name == '.' || name == '..') {
      continue;
    }

    if (isExcluded(name, excludePatterns)) {
      stats.entriesExcluded++;
      if (verbose) {
        stdout.writeln('EXCLUDED     ${joinRemote(remoteDirPath, name)}');
      }
      continue;
    }

    final String remoteItemPath = joinRemote(remoteDirPath, name);
    final String localItemPath = joinLocal(localDirPath, name);

    final SftpFileAttrs attrs = item.attr;

    if (isDirectory(attrs)) {
      await copyDirectoryRecursive(
        sftp: sftp,
        remoteDirPath: remoteItemPath,
        localDirPath: localItemPath,
        verbose: verbose,
        stats: stats,
        excludePatterns: excludePatterns,
      );
      continue;
    }

    if (!isRegularFile(attrs)) {
      if (verbose) {
        stdout.writeln('SKIP SPECIAL ${remoteItemPath}');
      }
      continue;
    }

    final int downloaded = await downloadFile(
      sftp: sftp,
      remoteFilePath: remoteItemPath,
      localFilePath: localItemPath,
      verbose: verbose,
    );

    stats.filesDownloaded++;
    stats.bytesDownloaded += downloaded;
  }
}

Future<int> downloadFile({
  required SftpClient sftp,
  required String remoteFilePath,
  required String localFilePath,
  required bool verbose,
}) async {
  if (verbose) {
    stdout.writeln('DOWNLOAD     $remoteFilePath');
  }

  final localFile = File(localFilePath);
  localFile.parent.createSync(recursive: true);

  final sink = localFile.openWrite(mode: FileMode.writeOnly);

  try {
    final int bytes = await sftp.download(
      remoteFilePath,
      sink,
      closeDestination: false,
    );

    await sink.flush();
    await sink.close();

    return bytes;
  } catch (_) {
    try {
      await sink.flush();
    } catch (_) {}
    try {
      await sink.close();
    } catch (_) {}
    rethrow;
  }
}

bool isDirectory(SftpFileAttrs attrs) {
  return attrs.type == SftpFileType.directory;
}

bool isRegularFile(SftpFileAttrs attrs) {
  return attrs.type == SftpFileType.regularFile;
}

String normalizeRemotePath(String path) {
  if (path.endsWith('/')) {
    return path.substring(0, path.length - 1);
  }
  return path;
}

String joinRemote(String base, String name) {
  if (base.endsWith('/')) {
    return '$base$name';
  }
  return '$base/$name';
}

String joinLocal(String base, String name) {
  return '$base${Platform.pathSeparator}$name';
}

bool matchesPattern(String name, String pattern) {
  if (!pattern.contains('*')) {
    return name == pattern;
  }

  final parts = pattern.split('*');
  if (parts.length == 2) {
    final start = parts[0];
    final end = parts[1];
    return name.startsWith(start) && name.endsWith(end);
  }

  return name.contains(pattern.replaceAll('*', ''));
}

bool isExcluded(String name, List<String> excludePatterns) {
  for (final pattern in excludePatterns) {
    if (matchesPattern(name, pattern)) {
      return true;
    }
  }
  return false;
}

String? _readArgumentValue(List<String> args, String optionName) {
  final index = args.indexOf(optionName);
  if (index == -1 || index + 1 >= args.length) {
    return null;
  }
  return args[index + 1];
}
