import 'package:elf_analyze/src/elf_base.dart';
import 'package:elf_analyze/src/elf_buffer.dart';
import 'package:elf_analyze/src/elf_types.dart';

import 'elf_utils.dart';

/// Elf 注释项
class ElfNote extends OperableProperty {

	/// 名称长度
	@Elf32_Word
	int namesz;

	/// 描述长度
	@Elf32_Word
	int descsz;

	/// 表示描述的类型
	@Elf32_Word
	int type;

	/// 名称字符数组
	@Unsigned_Char
	List<int> name;

	/// 描述字符数组
	@Unsigned_Char
	List<int> desc;


	int _position;
	int _size;

	/// 设置读取位置
	/// position 和 size 都是原始数据
	void setReadPosition(int position, int size) {
		_position = position;
		_size = size;
	}

	@override
	void readByByteStream(ElfStreamBuffer streamBuffer) async {
		await streamBuffer.setPosition(ElfByteUtils.toLSB(_position));
		namesz = await streamBuffer.nextElf32Word();
		descsz = await streamBuffer.nextElf32Word();
		type = await streamBuffer.nextElf32Word();
		name = await streamBuffer.nextBytes(ElfByteUtils.toLSB(namesz), alignCount: 4);
		desc = await streamBuffer.nextBytes(ElfByteUtils.toLSB(descsz), alignCount: 4);
	}

	@override
	Iterable<int> toByteStream() sync* {
		yield* ElfByteUtils.writeElf32Word(namesz);
		yield* ElfByteUtils.writeElf32Word(descsz);
		yield* ElfByteUtils.writeElf32Word(type);
		yield* ElfByteUtils.writeElfByteBuffer(name, name.length);
		yield* ElfByteUtils.writeElfByteBuffer(desc, desc.length);
	}

	@override
	String toString() {
		return '''
start offset: ${ElfStringUtils.formatPretty16Str(_position, byteCount: 4)}
size: ${ElfStringUtils.formatPretty16Str(_size, byteCount: 4)}
namesz: ${ElfStringUtils.formatPretty16Str(namesz, byteCount: 4)}
descsz: ${ElfStringUtils.formatPretty16Str(descsz, byteCount: 4)}
type: ${ElfStringUtils.formatPretty16Str(type, byteCount: 4)}
name: ${name.map((int num) => ElfStringUtils.formatPretty16Str(num)).join(" ")}
nameStr: ${String.fromCharCodes(name)}
desc: ${desc.map((int num) => ElfStringUtils.formatPretty16Str(num)).join(" ")}
descStr: ${String.fromCharCodes(desc)}
''';
	}
}