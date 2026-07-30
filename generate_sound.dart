import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

void main() {
  const sampleRate = 22050;
  const duration = 1.0;
  const numSamples = (sampleRate * duration);
  const dataSize = (numSamples * 2);
  const fileSize = 44 + dataSize;

  final builder = BytesBuilder();

  // WAV Header
  builder.add('RIFF'.codeUnits);
  final fileSizeData = ByteData(4)..setUint32(0, (fileSize - 8).toInt(), Endian.little);
  builder.add(fileSizeData.buffer.asUint8List());

  builder.add('WAVE'.codeUnits);
  builder.add('fmt '.codeUnits);

  final fmtChunk = ByteData(20)
    ..setUint32(0, 16, Endian.little)
    ..setUint16(4, 1, Endian.little)
    ..setUint16(6, 1, Endian.little)
    ..setUint32(8, sampleRate, Endian.little)
    ..setUint32(12, sampleRate * 2, Endian.little)
    ..setUint16(16, 2, Endian.little)
    ..setUint16(18, 16, Endian.little);
  builder.add(fmtChunk.buffer.asUint8List());

  builder.add('data'.codeUnits);
  final dataHeader = ByteData(4)..setUint32(0, dataSize.toInt(), Endian.little);
  builder.add(dataHeader.buffer.asUint8List());

  final pcmData = ByteData((dataSize).toInt());
  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final env = exp(-3.0 * t);
    final val = (sin(2 * pi * 880.0 * t) + 0.5 * sin(2 * pi * 1174.66 * t)) * env * 0.4;
    int sample = (val * 32767).toInt();
    if (sample > 32767) sample = 32767;
    if (sample < -32768) sample = -32768;
    pcmData.setInt16(i * 2, sample, Endian.little);
  }
  builder.add(pcmData.buffer.asUint8List());

  Directory('L:/assets/sounds').createSync(recursive: true);
  File('L:/assets/sounds/reminder_ring.wav').writeAsBytesSync(builder.toBytes());
  print('WAV generated successfully: ${builder.toBytes().length} bytes');
}
