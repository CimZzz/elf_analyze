

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:elf_analyze/src/elf_buffer.dart';
import 'package:elf_analyze/src/elf_header.dart';
import 'package:elf_analyze/src/elf_program_header.dart';
import 'package:elf_analyze/src/elf_section_header.dart';
import 'package:elf_analyze/src/elf_strtab.dart';
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
    var phnum = ElfByteUtils.toLSB(elf_header.e_phnum, effectiveCount: 2);
    while(phnum -- > 0) {
      final elf_ph = ElfProgramHeader();
      await elf_ph.readByByteStream(elfByteBuffer);
      elf_phList.add(elf_ph);
    }

//    var count = 0;
//    for(final ph in elf_phList) {
//      ElfPrintUtils.printObj('elf program header $count', ph);
//      count ++;
//    }
  }

  final elf_shList = <ElfSectionHeader>[];
  if(elf_header.e_shoff != 0) {
    await elfByteBuffer.setPosition(ElfByteUtils.toLSB(elf_header.e_shoff));
    var shnum = ElfByteUtils.toLSB(elf_header.e_shnum, effectiveCount: 2);
    while(shnum -- > 0) {
      final elf_sh = ElfSectionHeader();
      await elf_sh.readByByteStream(elfByteBuffer);
      elf_shList.add(elf_sh);
    }

//    var count = 0;
//    for(final sh in elf_shList) {
//      ElfPrintUtils.printObj('elf section header $count', sh);
//      count ++;
//    }
  }


  final shstr = elf_shList[ElfByteUtils.toLSB(elf_header.e_shstrndx, effectiveCount: 2)];
  final shnamestrtab = ElfStringTable();
  shnamestrtab.setReadPosition(shstr.sh_offset, shstr.sh_size);
  await shnamestrtab.readByByteStream(elfByteBuffer);
//  print(shnamestrtab);

  // 打印各个节区的名字
  var count = 0;
  for(final sh in elf_shList) {
    print('elf section header $count name: ${shnamestrtab.getString(sh.sh_name)}');
    count ++;
  }
}
