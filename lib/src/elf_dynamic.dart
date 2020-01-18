import 'package:elf_analyze/src/elf_base.dart';
import 'package:elf_analyze/src/elf_buffer.dart';

import 'elf_types.dart';
import 'elf_utils.dart';

class ElfDynamicArray extends OperableProperty {


	List<ElfDynamic> dynamicArr;

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
		dynamicArr = [];
		while (realSize -- > 0) {
			await streamBuffer.setPosition(curPosition);
			curPosition += entSize;
			final dynamic = ElfDynamic();
			await dynamic.readByByteStream(streamBuffer);
			dynamicArr.add(dynamic);
		}
	}

	@override
	Iterable<int> toByteStream() sync* {
		for (final dynamic in dynamicArr) {
			yield* dynamic.toByteStream();
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
		for (final dynamic in dynamicArr) {
			headerStr += '''
--- item $count:
$dynamic
''';
			count ++;
		}
		return headerStr;
	}
}

class ElfDynamic extends OperableProperty {
	/// 动态链接标记
	/// * 置为 "必需" 的标记必需存在于数组中
	///
	/// 按照以下格式分析每个类型:
	/// 类型码 - 类型名 | d_val_ptr 取值 | 对于可执行文件是否必需 | 对于共享目标文件是否必需 | 类型说明
	///
	/// 00 - DT_NULL | 忽略 | 必需 | 必需 | 用于标记 DYNAMIC 数组的结束 |
	///
	/// 01 - DT_NEEDED | 整型值 | 可选 | 可选 | 指向一个所需库的名字，由 DT_STRTAB 表示的字符串表的下标 |
	///
	/// 02 - DT_PLTRELSZ | 整型值 | 可选 | 可选 | 与函数连接表相关的所有重定位项的总大小，以字节为单位。如果存在 DT_JMPREL 项，那么也必须有 DT_PLTRELSZ |
	///
	/// 03 - DT_PLTGOT | 地址 | 可选 | 可选 | 此元素包含于函数连接表或全局偏移量表相应的地址 |
	///
	/// 04 - DT_HASH | 地址 | 必需 | 必需 | 此元素含有符号哈希表的地址。这里所致的哈希表与 DT_SYMTAB 所指哈希表是同一个 |
	///
	/// 05 - DT_STRTAB | 地址 | 必需 | 必需 | 此元素包含字符串表的地址，此表中包含符号名、库名等 |
	///
	/// 06 - DT_SYMTAB | 地址 | 必需 | 必需 | 此元素包含符号表地址 |
	///
	/// 07 - DT_RELA | 地址 | 必需 | 可选 | 此元素包含一个重定位表的地址，连接编辑器会将全部重定位节连接在一起，形成一张大的重定位表。
	///     如果一个结构中存在 DT_RELA 元素的话，那么必须同时包含 DT_RELASZ 和 DT_RELEANT 元素。如果一个文件需要重定位的话，DT_RELA 或 DT_REL
	///     至少要出现一个 |
	///
	/// 08 - DT_RELASZ | 整型值 | 必需 | 可选 | 此元素持有 DT_RELA 相应的重定位表的大小，以字节为单位 |
	///
	/// 09 - DT_RELAENT | 整型值 | 必需 | 可选 | 此元素持有 DT_RELA 相应的重定位表项的大小，以字节为单位 |
	///
	/// 0a - DT_STRSZ | 整型值 | 必需 | 必需 | 此元素持有字符串表的大小，以字节为单位 |
	///
	/// 0b - DT_SYMENT | 整型值 | 必需 | 必需 | 此元素持有符号表项的大小，以字节为单位 |
	///
	/// 0c - DT_INIT | 地址 | 可选 | 可选 | 此元素持有初始化函数地址 |
	///
	/// 0d - DT_FINI | 地址 | 可选 | 可选 | 此元素持有终止函数地址 |
	///
	/// 0e - DT_SONAME | 整型值 | 忽略 | 可选 | 此元素持有一个字符串表的偏移量。在那个位置存储了一个以 `null` 结尾的字符串，是一个共享目标的名字。字符串由 DT_STRTAB 指定 |
	///
	/// 0f - DT_RPATH | 整型值 | 可选 | 忽略 | 此元素持有一个字符串表中的偏移量，用于搜索库文件的路径名 |
	///
	/// 10 - DT_SYMBOLIC | 忽略 | 忽略 | 可选 | 此元素决定连接器解析符号所用算法。此元素不出现的话，动态连接器先搜索可执行文件再搜索库文件；出现的话，顺序正好相反。 |
	///
	/// 11 - DT_REL | 地址 | 必需 | 可选 | 此元素与 DT_RELA 相似 |
	///
	/// 12 - DT_RELSZ | 整型值 | 必需 | 可选 | 此元素持有 DT_REL 相应的重定位表的大小，以字节为单位 |
	///
	/// 13 - DT_RELENT | 整型值 | 必需 | 可选 | 此元素持有 DT_REL 相应的重定位表项的大小，以字节为单位 |
	///
	/// 14 - DT_PLTREL | 整型值 | 可选 | 可选 | 此元素指明了函数连接表所引用重定位项的类型。d_val_addr 取值 DT_REL \ DT_RELA。函数连接表中所有的重定位类型都是相同的 |
	///
	/// 15 - DT_DEBUG | 地址 | 可选 | 忽略 | 用于调试，意义不明 |
	///
	/// 16 - DT_TEXTREL | 忽略 | 可选 | 可选 | 此元素表示在重定位过程中，连接编辑器可以修改只读段，否则不能修改 |
	///
	/// 17 - DT_JMPREL | 地址 | 可选 | 可选 | 此元素如果存在，可以让动态连接器在初始化的时候忽略该地址所指向的重定位项，前提是后期绑定是激活的。此元素存在的话，DT_PLTRELSZ 和 DT_PLTREL 也应该出现 |
	///
	/// 18 - DT_BIND_NOW | 忽略 | 可选 | 可选 | 表示动态连接器必须在程序开始执行以前，完成所有包含此项的目标的重定位工作，即使后期绑定激活也对本目标不适用 |
	///
	/// 0x70000000 - DT_LOPROC | 未定义 | 未定义 | 未定义 | 处理器保留用的字段区间下限 |
	///
	/// 0x7fffffff - DT_HIPROC | 未定义 | 未定义 | 未定义 | 处理器保留用的字段区间上限 |
	@Elf32_SWord
	int d_tag;

	/// 表示地址或者整型数
	@Elf32_Word
	@Elf32_Addr
	int d_val_ptr;

	@override
	void readByByteStream(ElfStreamBuffer streamBuffer) async {
		d_tag = await streamBuffer.nextElf32SWord();
		d_val_ptr = await streamBuffer.nextElf32Word();
	}

	@override
	Iterable<int> toByteStream() sync* {
		yield* ElfByteUtils.writeElf32SWord(d_tag);
		yield* ElfByteUtils.writeElf32Word(d_val_ptr);
	}

	@override
	String toString() {
		return '''
d_tag: ${ElfStringUtils.formatPretty16Str(d_tag, byteCount: 4)}
d_val_ptr: ${ElfStringUtils.formatPretty16Str(d_val_ptr, byteCount: 4)}
''';
	}
}