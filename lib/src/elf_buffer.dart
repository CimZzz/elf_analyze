import 'dart:async';

import 'package:elf_analyze/src/elf_exceptions.dart';


class ElfStreamBuffer {
	ElfStreamBuffer(Stream<List<int>> byteStream)
		: _byteStream = byteStream {
		_initStream();
	}

	final Stream<List<int>> _byteStream;
	Completer _syncCompleter;
	Completer<List<int>> _byteListCompleter;
	List<int> _remainByteList;
	int _remainIdx = 0;

	Future<List<int>> nextBytes(int count) async {
		final returnList = <int>[];
		var remainedCount = count;
		while(returnList.length != count) {
			if (_remainByteList == null) {
				_remainByteList = await _getNextByteList();
				if(_remainByteList == null) {
					throw const ElfBufferException('not enough byte');
				}
			}

			if(_remainIdx + remainedCount <= _remainByteList.length) {
				returnList.addAll(_remainByteList.sublist(_remainIdx, _remainIdx + remainedCount));
				_remainIdx += remainedCount;
			}
			else {
				returnList.addAll(_remainByteList.sublist(_remainIdx));
				remainedCount = _remainIdx + remainedCount - _remainByteList.length;
				_remainIdx = 0;
				_remainByteList = null;
			}
		}
		return returnList;
	}

	Future<List<int>> _getNextByteList() async {
		_syncCompleter.complete(null);
		return _byteListCompleter.future;
	}

	void _initStream() async {
		_syncCompleter = Completer();
		_byteListCompleter = Completer();
		await for(final byteList in _byteStream) {
			await _syncCompleter.future;
			_syncCompleter = Completer();
			_byteListCompleter.complete(byteList);
			_byteListCompleter = Completer();
		}
	}
}