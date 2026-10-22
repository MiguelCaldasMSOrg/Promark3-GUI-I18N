import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pm3gui/backend/desktop_cli/desktop_cli_backend.dart';
import 'package:pm3gui/backend/desktop_cli/pm3_process.dart';
import 'package:pm3gui/backend/desktop_cli/pm3_process_messages.dart';
import 'package:pm3gui/l10n/app_localizations.dart';
import 'package:pm3gui/l10n/localized_pm3_process_messages.dart';

void main() {
  test('standalone Chinese defaults match every generated process message', () {
    final chinese = lookupAppLocalizations(const Locale('zh'));
    expect(
      _snapshot(const Pm3ProcessMessages()),
      _snapshot(LocalizedPm3ProcessMessages(chinese)),
    );
  });

  test('backend adapts live language changes without changing the process',
      () async {
    final process = Pm3Process();
    final backend = DesktopCliBackend(process: process);
    addTearDown(backend.shutdown);
    final english = lookupAppLocalizations(const Locale('en'));
    final chinese = lookupAppLocalizations(const Locale('zh'));

    backend.updateLocalizations(english);
    expect(process.l10n, isA<LocalizedPm3ProcessMessages>());
    expect(process.l10n.pm3Busy, english.pm3Busy);
    expect(process.l10n.messageConnectionFailed('detail'),
        english.messageConnectionFailed('detail'));
    expect(process.l10n.messageCouldNotStartPm3PathCheckThe('error', 'path'),
        english.messageCouldNotStartPm3PathCheckThe('error', 'path'));
    expect(process.l10n.messagePm3ProgramNotFoundOnWindowsSelect('path'),
        english.messagePm3ProgramNotFoundOnWindowsSelect('path'));

    backend.updateLocalizations(chinese);
    expect(_snapshot(process.l10n), _snapshot(const Pm3ProcessMessages()));
  });

  test('process accepts a framework-independent message implementation',
      () async {
    final process = Pm3Process(l10n: const _CustomMessages());
    await process.shutdown();

    expect(await process.connect('unused-client', 'unused-port'), isFalse);
    expect(process.lastError, 'custom disposed message');
  });
}

List<String> _snapshot(Pm3ProcessMessages messages) => [
      messages.messageConnectionFailed('detail'),
      messages.messageConnectionTimedOut,
      messages.messageConnectionTimedOutSCheckThatThe('3'),
      messages.messageCoolingDownS('3'),
      messages.messageCouldNotReadTheExitStatusAfter('stdout', 'detail'),
      messages.messageCouldNotStartPm3PathCheckThe('detail', 'path'),
      messages.messageError('detail'),
      messages.messageErrorCommandTimedOutTheSessionWas,
      messages.messageFailedToForceTerminatePm3KillProcess,
      messages.messageFailedToSendQuit('detail'),
      messages.messageFailedToSendTheReadOnlyPm3('detail'),
      messages.messageFailedToTerminatePm3('detail'),
      messages.messageFailedToTerminatePm3ReturnedFalse('TERM'),
      messages.messageFailedToTerminatePm3TermProcessTree,
      messages.messageFailedWhileWaitingForPm3ToExit('detail'),
      messages.messageFailedWhileWaitingForPm3ToStart('detail'),
      messages.messageFatalErrorOnPm3Stderr,
      messages.messageFatalErrorOnPm3Stdout,
      messages.messageNotConnected,
      messages.messagePermissionDeniedForTheSerialPortTry,
      messages.messagePleaseWaitSecondsBeforeRetrying('3'),
      messages.messagePm3ProcessExitStatusError('detail'),
      messages.messagePm3ProcessExitedBeforeTheConnectionPrompt('9'),
      messages.messagePm3ProcessExitedCode('9'),
      messages.messagePm3ProgramNotFoundOnWindowsSelect('path'),
      messages.messagePm3StderrStreamError('detail'),
      messages.messagePm3StdoutStreamError('detail'),
      messages.messagePm3StreamClosed('stdout'),
      messages.messageSerialConnectionError('detail'),
      messages.messageSerialDeviceNotFoundCheckThePm3,
      messages.messageThePm3ProcessManagerHasBeenDisposed,
      messages.messageThePm3SessionDisconnectedBeforeTheCommand,
      messages.messageTheSerialPortIsInUseBy,
      messages.messageTimedOutWaitingForPm3ToExit,
      messages.messageUsingPm3('path'),
      messages.messageWorkingDirectory('directory'),
      messages.pm3Busy,
    ];

class _CustomMessages extends Pm3ProcessMessages {
  const _CustomMessages();

  @override
  String get messageThePm3ProcessManagerHasBeenDisposed =>
      'custom disposed message';
}
