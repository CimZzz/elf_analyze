
import 'package:elf_analyze/src/elf_base.dart';

import 'elf_buffer.dart';
import 'elf_types.dart';
import 'elf_utils.dart';

class ElfSymbolTable extends OperableProperty {

	List<ElfSymbol> symbolTable;

	int _position;
	int _entSize;
	int _size;


	/// 设置读取位置
	/// position 和 size 都是原始数据
	void setReadPosition(int position, int entSize, int size) {
		_position = position;
		_entSize = entSize;
		_size = size;
	}

	@override
	void readByByteStream(ElfStreamBuffer streamBuffer) async {
		var curPosition = ElfByteUtils.toLSB(_position);
		final entSize = ElfByteUtils.toLSB(_entSize);
		var realSize = ElfByteUtils.toLSB(_size) ~/ entSize;
		symbolTable = [];
		while(realSize -- > 0) {
			await streamBuffer.setPosition(curPosition);
			curPosition += entSize;
			final symbol = ElfSymbol();
			await symbol.readByByteStream(streamBuffer);
			symbolTable.add(symbol);
		}
	}

	@override
	Iterable<int> toByteStream() sync* {
		for(final symbol in symbolTable) {
			yield* symbol.toByteStream();
		}
	}

	@override
	String toString() {
		var headerStr = '''
start offset: ${ElfStringUtils.formatPretty16Str(_position, byteCount: 4)}
entSize: ${ElfStringUtils.formatPretty16Str(_entSize, byteCount: 4)}
size: ${ElfStringUtils.formatPretty16Str(_size, byteCount: 4)}
''';
		var count = 0;
		for(final symbol in symbolTable) {
			headerStr += '''
--- item $count:
$symbol
''';
			count ++;
		}
		return headerStr;
	}
}


class ElfSymbol extends OperableProperty {

	/// 符号名称下标
	/// 通常指在 `.dynstr` 节区中的下标
	@Elf32_Word
	int st_name;

	/// 函数地址，或者是一个常量值
	@Elf32_Addr
	int st_value;

	/// 从 st_value 作为开始地址，共占长度的大小
	@Elf32_Word
	int st_size;

	/// 表示此符号的属性
	///
	/// 该值的低四位:
	///
	/// 00 - STB_LOCAL 局部符号在目标文件外不可见
	///
	/// 01 - STB_GLOBAL 全局符号对于所有目标文件都是可见的。一个文件中对某个全局符号的定义将满足另一个文件对相同全局符号的未定义引用
	///
	/// 02 - STB_WEAK 弱符号与全局符号类似，不过定义优先级比较较低
	///
	/// 0D - STB_LOPROC 为处理保留的属性区间
	///
	/// 0F - STB_HIPROC 为处理保留的属性区间
	///
	/// 该值的高四位:
	///
	/// 00 - STT_NOTYPE 未指定符号类型
	///
	/// 01 - STT_OBJECT 符号与某个数据对象相关，比如一个变量、数组等
	///
	/// 02 - STT_FUN 符号与某个函数或者其他可执行代码相关
	///
	/// 03 - STT_SECTION 本符号与一个节相关联，用于重定位，通常具有 STB_LOCAL 属性
	///
	/// 04 - STT_FILE 本符号是一个文件符号，具有 STB_LOCAL 属性，它的节索引值为 SHN_ABS。如果出现本符号，会出现在所有 STB_LOCAL 类符号的前面
	///
	/// 0D - STT_LOPROC 为处理保留的属性区间
	///
	/// 0F - STT_HIPROC 为处理保留的属性区间
	@Unsigned_Char
	int st_info;

	/// 暂未使用，一律赋值为 0
	@Unsigned_Char
	int st_other;

	/// 任何一个符号表项的定义都与某一个 "节" 相联系，
	/// 下列索引值将被保留，具有特殊含义:
	///
	/// 00 - SHN_UNDEF 未定义
	///
	/// 0xFF00 - SHN_LORESERVE 被保留的索引号下限
	///
	/// 0xFF00 - SHN_LOPROC 为处理器定制节所保留的索引号区间下限
	///
	/// 0xFF1F - SHN_HIPROC 为处理器定制节所保留的索引号区间上限
	///
	/// 0xFFF1 - SHN_ABS 所定义的符号具有绝对值，不会因重定位而改变
	///
	/// 0xFFF2 - SHN_COMMON 定义的符号是公共的，比如未分配的 external 变量
	///
	/// 0xFFFF - SHN_HORESERVE 被保留的索引号上限
	@Elf32_Half
	int st_shndx;


	@override
	void readByByteStream(ElfStreamBuffer streamBuffer) async {
		st_name = await streamBuffer.nextElf32Word();
		st_value = await streamBuffer.nextElf32Addr();
		st_size = await streamBuffer.nextElf32Word();
		st_info = await streamBuffer.nextElf32UnsignedChar();
		st_other = await streamBuffer.nextElf32UnsignedChar();
		st_shndx = await streamBuffer.nextElf32Half();
	}

	@override
	Iterable<int> toByteStream() sync* {
		yield* ElfByteUtils.writeElf32Word(st_name);
		yield* ElfByteUtils.writeElf32Addr(st_value);
		yield* ElfByteUtils.writeElf32Word(st_size);
		yield* ElfByteUtils.writeElf32UnsignedChar(st_info);
		yield* ElfByteUtils.writeElf32UnsignedChar(st_other);
		yield* ElfByteUtils.writeElf32Half(st_shndx);
	}

	@override
	String toString() {
		return '''
st_name: ${ElfStringUtils.formatPretty16Str(st_name, byteCount: 4)}
st_value: ${ElfStringUtils.formatPretty16Str(st_value, byteCount: 4)}
st_size: ${ElfStringUtils.formatPretty16Str(st_size, byteCount: 4)}
st_info: ${ElfStringUtils.formatPretty16Str(st_info, byteCount: 1)}
st_other: ${ElfStringUtils.formatPretty16Str(st_other, byteCount: 1)}
st_shndx: ${ElfStringUtils.formatPretty16Str(st_shndx, byteCount: 2)}
''';
	}
}