import 'dart:async';
import 'dart:io';

import 'package:elf_analyze/src/elf_exceptions.dart';
import 'package:elf_analyze/src/elf_utils.dart';

import 'elf_types.dart';


class ElfStreamBuffer {

	RandomAccessFile _randomAccessFile;


	void setBufferStream(File file) {
		_randomAccessFile = file.openSync();
	}

	void setPosition(int position) async {
		_randomAccessFile = await _randomAccessFile.setPosition(position);
	}

	Future<List<int>> nextBytes(int count, {bool allowNotEnough = false}) async {
		final readBytes = await _randomAccessFile.read(count);
		if(readBytes.length != count) {
			if(allowNotEnough) {
				return readBytes;
			}
			else {
				throw ElfBufferException('byte not enough, need : $count');
			}
		}
		return readBytes;
	}

	@Elf32_Word
	Future<int> nextElf32Word() async {
		return ElfByteUtils.readElf32Word(await nextBytes(4));
	}

	@Elf32_Off
	Future<int> nextElf32Off() async {
		return ElfByteUtils.readElf32Off(await nextBytes(4));
	}

	@Elf32_Addr
	Future<int> nextElf32Addr() async {
		return ElfByteUtils.readElf32Addr(await nextBytes(4));
	}

	@Elf32_SWord
	Future<int> nextElf32SWord() async {
		return ElfByteUtils.readElf32SWord(await nextBytes(4));
	}

	@Elf32_Half
	Future<int> nextElf32Half() async {
		return ElfByteUtils.readElf32Half(await nextBytes(2));
	}

	@Unsigned_Char
	Future<int> nextElf32UnsignedChar() async {
		return ElfByteUtils.readElf32UnsignedChar(await nextBytes(1));
	}
}