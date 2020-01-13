

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:elf_analyze/src/elf_buffer.dart';
import 'package:elf_analyze/src/elf_header.dart';
import 'package:elf_analyze/src/elf_program_header.dart';
import 'package:elf_analyze/src/elf_types.dart';
import 'package:elf_analyze/src/elf_utils.dart';

void main() async {
  final file = File('/Users/wangyanxiong/Desktop/c/libnativetest.so');
  final elfByteBuffer = ElfStreamBuffer();
  final elf_header = ElfHeader();
  elfByteBuffer.setBufferStream(file);
//  print(await elfByteBuffer.nextBytes(5));
  await elf_header.readByByteStream(elfByteBuffer);
  ElfPrintUtils.printObj('elf header', elf_header);

  final elf_phList = <ElfProgramHeader>[];
  if(elf_header.e_phoff != 0) {
    await elfByteBuffer.setPosition(ElfByteUtils.toLSB(elf_header.e_phoff));
    var phnum = ElfByteUtils.toLSB(elf_header.e_phnum);
    print('phnum: $phnum');
    while(phnum -- > 0) {
      final elf_ph = ElfProgramHeader();
      await elf_ph.readByByteStream(elfByteBuffer);
      elf_phList.add(elf_ph);
    }

    var count = 0;
    for(final ph in elf_phList) {
      ElfPrintUtils.printObj('elf program header $count', ph);
      count ++;
    }
  }
}
