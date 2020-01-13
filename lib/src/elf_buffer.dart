import 'dart:async';
import 'dart:io';

import 'package:elf_analyze/src/elf_exceptions.dart';


class ElfStreamBuffer {

	RandomAccessFile _randomAccessFile;
	int _readIdx = 0;


	void setBufferStream(File file) {
		_randomAccessFile = file.openSync();
	}

	void setPosition(int position) async {
		await _randomAccessFile.setPosition(position);
	}

	Future<List<int>> nextBytes(int count, {bool allowNotEnough = false}) async {
		await _randomAccessFile.setPosition(_readIdx);
		final readBytes = await _randomAccessFile.read(count);
		if(readBytes.length != count) {
			if(allowNotEnough) {
				return readBytes;
			}
			else {
				throw ElfBufferException('byte not enough');
			}
		}
		_readIdx += count;
		return readBytes;
	}
}