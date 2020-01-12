

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:elf_analyze/src/elf_buffer.dart';
import 'package:elf_analyze/src/elf_header.dart';
import 'package:elf_analyze/src/elf_types.dart';
import 'package:elf_analyze/src/elf_utils.dart';

void main() async {
  final file = File('/Users/cimzzz/Desktop/test/libencrypt.so');
  final elfByteBuffer = ElfStreamBuffer(file.openRead());
  final elf_header = ElfHeader();
//  print(await elfByteBuffer.nextBytes(5));
  await elf_header.readByByteStream(elfByteBuffer);
  ElfPrintUtils.printObj('elf header', elf_header);
}


Stream<int> data() async* {
  for(var i = 0 ; i < 4 ; i ++) {
    yield i;
  }
}
