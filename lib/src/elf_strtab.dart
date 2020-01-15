import 'package:elf_analyze/src/elf_base.dart';
import 'package:elf_analyze/src/elf_buffer.dart';
import 'package:elf_analyze/src/elf_types.dart';

import 'elf_utils.dart';

class ElfStringTable extends OperableProperty {

	/// 文字缓冲区
	@Unsigned_Char
	List<int> buffers;


	int _position;
	int _size;

	/// 设置读取位置
	/// position 和 size 都是原始数据
	void setReadPosition(int position, int size) {
		_position = position;
		_size = size;
	}

	/// 获取执行位置下的字符串
	/// position 为原始数据
	String getString(int position) {
		final startIdx = ElfByteUtils.toLSB(position);
		var endIdx = startIdx;
		for(var i = startIdx ; i < buffers.length ; i ++) {
			if(buffers[i] == 0) {
				endIdx = i;
				break;
			}
		}

		if(startIdx == endIdx) {
			return '';
		}

		return String.fromCharCodes(buffers, startIdx, endIdx);
	}

	@override
	void readByByteStream(ElfStreamBuffer streamBuffer) async {
		await streamBuffer.setPosition(ElfByteUtils.toLSB(_position));
		final realSize = ElfByteUtils.toLSB(_size);
		buffers = await streamBuffer.nextBytes(realSize);
	}

	@override
	Iterable<int> toByteStream() sync* {
		yield* buffers;
	}

	@override
	String toString() {
		return '''
start offset: ${ElfStringUtils.formatPretty16Str(_position, byteCount: 4)}
size: ${ElfStringUtils.formatPretty16Str(_size, byteCount: 4)}
buffers: ${buffers.map((int num) => ElfStringUtils.formatPretty16Str(num)).join(" ")}
''';
	}
}