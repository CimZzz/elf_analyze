import 'dart:io';

import 'package:elf_analyze/src/elf_buffer.dart';
import 'package:elf_analyze/src/elf_header.dart';
import 'package:elf_analyze/src/elf_note.dart';
import 'package:elf_analyze/src/elf_program_header.dart';
import 'package:elf_analyze/src/elf_section_header.dart';
import 'package:elf_analyze/src/elf_strtab.dart';
import 'package:elf_analyze/src/elf_symtab.dart';
import 'package:elf_analyze/src/elf_utils.dart';


final elf_header = ElfHeader();
final elf_phList = <ElfProgramHeader>[];
final elf_shList = <ElfSectionHeader>[];
ElfSectionHeader shname;
ElfSectionHeader shdynsym;
ElfSectionHeader shdynstr;
final shnoteMap = <ElfSectionHeader, ElfNote>{};

final shnamestrtab = ElfStringTable();
final shdynsymtab = ElfSymbolTable();
final shdynstrtab = ElfStringTable();


void main() async {
	final file = File('libcms.so');
	final elfByteBuffer = ElfStreamBuffer();
	elfByteBuffer.setBufferStream(file);
	await elf_header.readByByteStream(elfByteBuffer);

	if (elf_header.e_phoff != 0) {
		await elfByteBuffer.setPosition(ElfByteUtils.toLSB(elf_header.e_phoff));
		var phnum = ElfByteUtils.toLSB(elf_header.e_phnum, effectiveCount: 2);
		while (phnum -- > 0) {
			final elf_ph = ElfProgramHeader();
			await elf_ph.readByByteStream(elfByteBuffer);
			elf_phList.add(elf_ph);
		}
	}
	if (elf_header.e_shoff != 0) {
		await elfByteBuffer.setPosition(ElfByteUtils.toLSB(elf_header.e_shoff));
		var shnum = ElfByteUtils.toLSB(elf_header.e_shnum, effectiveCount: 2);
		while (shnum -- > 0) {
			final elf_sh = ElfSectionHeader();
			await elf_sh.readByByteStream(elfByteBuffer);
			elf_shList.add(elf_sh);
		}
	}

	shname = elf_shList[ElfByteUtils.toLSB(elf_header.e_shstrndx, effectiveCount: 2)];
	shnamestrtab.setReadPosition(shname.sh_offset, shname.sh_size);
	await shnamestrtab.readByByteStream(elfByteBuffer);

	for(final sh in elf_shList) {
		switch(shnamestrtab.getString(sh.sh_name)) {
			case '.dynsym':
				shdynsym = sh;
				break;
			case '.dynstr':
				shdynstr = sh;
				break;
		}
		switch(ElfByteUtils.toLSB(sh.sh_type)) {
			case 0x07:
				shnoteMap[sh] = null;
				break;
		}
	}


	// 符号表
	shdynsymtab.setReadPosition(shdynsym.sh_offset, shdynsym.sh_entsize, shdynsym.sh_size);
	await shdynsymtab.readByByteStream(elfByteBuffer);

	// 符号表字符串表
	shdynstrtab.setReadPosition(shdynstr.sh_offset, shdynstr.sh_size);
	await shdynstrtab.readByByteStream(elfByteBuffer);

	final shnoteList = List<ElfSectionHeader>.from(shnoteMap.keys);
	for(final shnote in shnoteList) {
		final note = ElfNote();
		note.setReadPosition(shnote.sh_offset, shnote.sh_size);
		await note.readByByteStream(elfByteBuffer);
		shnoteMap[shnote] = note;
	}

	doPrint();
}

/// 进行信息打印
void doPrint() {
//	printElfHeader();
//	printElfProgramHeader();
//	printElfSectionHeader();
//	printElfSectionHeaderName();
	printElfSymbolTable();
	printElfSymbolName();
//    printElfDynStr();
//	printElfNote();
}

/// 打印 Elf 头
void printElfHeader() {
	ElfPrintUtils.printObj('elf header', elf_header);
}

/// 打印各个程序头
void printElfProgramHeader() {
	var count = 0;
	elf_phList.sort((ph1, ph2) {
		final ph1Vaddr = ElfByteUtils.toLSB(ph1.p_vaddr);
		final ph2Vaddr = ElfByteUtils.toLSB(ph2.p_vaddr);
		return ph1Vaddr > ph2Vaddr ? 1 : (ph1Vaddr < ph2Vaddr ? -1 : 0);
	});
	for (final ph in elf_phList) {
		ElfPrintUtils.printObj('elf program header $count', ph);
		count ++;
	}
}

/// 打印各个节区头
void printElfSectionHeader() {
	var count = 0;
	for (final sh in elf_shList) {
		ElfPrintUtils.printObj('elf section header $count', sh);
		count ++;
	}
}

/// 打印各个节区的名字
void printElfSectionHeaderName() {
	var count = 0;
	for (final sh in elf_shList) {
		print('elf section header $count name: ${shnamestrtab.getString(sh.sh_name)}');
		count ++;
	}
}

/// 打印整个符号表
void printElfSymbolTable() {
	ElfPrintUtils.printObj('elf symbol table', shdynsymtab);
}

/// 打印 `.dynstr`
void printElfDynStr() {
    ElfPrintUtils.printObj('elf dynstr table', shdynstrtab);
}

/// 打印各个符号的名字
void printElfSymbolName() {
	var count = 0;
	for (final symbol in shdynsymtab.symbolTable) {
		print('elf symbol $count name: ${shdynstrtab.getString(symbol.st_name)}');
		count ++;
	}
}

/// 打印全部备注节
void printElfNote() {
	var count = 0;
	for (final note in shnoteMap.values) {
		ElfPrintUtils.printObj('elf note $count', note);
		count ++;
	}
}