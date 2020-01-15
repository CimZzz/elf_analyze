import 'package:elf_analyze/src/elf_base.dart';
import 'package:elf_analyze/src/elf_buffer.dart';
import 'package:elf_analyze/src/elf_types.dart';
import 'package:elf_analyze/src/elf_utils.dart';

/// 节气表头部
class ElfSectionHeader extends OperableProperty {

	/// 在名称节区表中下标
	@Elf32_Word
	int sh_name;

	/// 节区类型
	///
	/// 00 - SHN_UNDEF 表示该节区无效，各成员取值无意义
	///
	/// 01 - SHT_PROGBITS 表示此节区为程序 bits，其格式和含义都由程序来解释
	///
	/// 02 - SHT_SYMTAB 表示此节区包含一个符号表，提供用于链接编辑的符号，也可以用来实现动态链接
	///
	/// 03 - SHT_STRTAB 表示此节区包含一个字符串表。目标文件可能包含多个字符串表节区
	///
	/// 04 - SHT_RELA 表示此节区包含重定位表项，其中可能会有补齐内容(addend) 例如 32 位目标文件中的 Elf32_Rela 类型。目标文件可能包含多个重定位节区
	///
	/// 05 - SHT_HASH 表示此节区包含符号哈希表。所有参与动态链接的目标都必须包含一个符号哈希表。目前一个目标文件只能包含一个哈希表，不过此限制将来可能会解除。
	///
	/// 06 - SHT_DYNAMIC 表示此节区包含动态链接的信息，目前一个目标文件只能包含一个动态节区，不过此限制将来可能会解除。
	///
	/// 07 - SHT_NOTE 表示此节区包含某种方法标记文件的信息
	///
	/// 08 - SHT_NOBITS 表示此节区不占用文件中的空间，其他方面与 SHT_PROGBITS 类似。
	///
	/// 09 - SHT_REL 表示此节区包含重定位表项，其中没有补齐内容（addends）. 例如 32 位目标文件中的 Elf32_Rel 类型。目标文件可能包含多个重定位节区
	///
	/// 10 - SHT_SHLIB 此节区被保留。
	///
	/// 11 - SHT_DYNSYM 作为一个完整的符号表,它可能包含很多对动态链接而言不必要的符号。因此,目标文件也可以包含一个 SHT_DYNSYM 节区,其中保存动态链接符号的一个最小集合,以节省空间
	///
	/// 0x70000000 - SHT_LOPROC 保留给处理器专用处理语义的
	///
	/// 0X7FFFFFFF - SHT_HIPROC 保留给处理器专用处理语义的
	///
	/// 0x80000000 - SHT_LOUSER 保留给应用程序的索引下界
	///
	/// 0X8FFFFFFF - SHT_HIUSER 保留给应用程序的索引上界
	@Elf32_Word
	int sh_type;

	/// 表示本节区的数据
	/// 分为以下几种权限:
	/// 01 - PF_X 可执行
	/// 02 - PF_W 可写
	/// 04 - PF_R 只读
	@Elf32_Word
	int sh_flags;

	/// 节区索引地址
	@Elf32_Addr
	int sh_addr;

	/// 节区相对于文件的偏移地址
	@Elf32_Off
	int sh_offset;

	/// 节区的大小
	@Elf32_Word
	int sh_size;

	/// 节区头部表索引链接
	@Elf32_Word
	int sh_link;

	/// 附加信息
	/// 下面是 sh_type、sh_link 和 sh_info 三个字段的联动:
	///
	/// SHT_DYNAMIC - sh_link 表示此节区中条目所用到的字符串表的节区头部索引；sh_info 为 0
	///
	/// SHT_HASH - sh_link 表示此哈希表所使用的符号表节区头部索引；sh_info 为 0
	///
	/// SHT_REL \ SHT_RELA - sh_link 表示相关符号表的节区头部索引；sh_info 表示重定位所使用的节区的节区头部索引
	///
	/// SHT_SYMTAB \ SHT_DYNSYM - 相关联的字符串表的节区头部索引；sh_info 表示最后一个局部符号(绑定 STB_LOCAL) 的符号表索引值 +1
	///
	/// 其他 - sh_link 未定义；sh_info 为 0
	@Elf32_Word
	int sh_info;

	/// 某些节区由地址对齐约束，比如一个节区中保存一个 `double-word`(双字节) 数据的话，那么系统必须保证整个节区能够按照双字对齐
	/// sh_addr 对 sh_addralign 取模必须为 0. 目前仅允许取值为 0 和 2 的幂次数。数值 0 和 1 表示没有对齐约束
	@Elf32_Word
	int sh_addralign;

	/// 如果某些节区(比如符号表)包含固定大小的项目，这个属性表示包含多少个项目，其他类型节区该值为 0
	@Elf32_Word
	int sh_entsize;

	@override
	void readByByteStream(ElfStreamBuffer streamBuffer) async {
		sh_name = await streamBuffer.nextElf32Word();
		sh_type = await streamBuffer.nextElf32Word();
		sh_flags = await streamBuffer.nextElf32Word();
		sh_addr = await streamBuffer.nextElf32Addr();
		sh_offset = await streamBuffer.nextElf32Off();
		sh_size = await streamBuffer.nextElf32Word();
		sh_link = await streamBuffer.nextElf32Word();
		sh_info = await streamBuffer.nextElf32Word();
		sh_addralign = await streamBuffer.nextElf32Word();
		sh_entsize = await streamBuffer.nextElf32Word();
	}

	@override
	Iterable<int> toByteStream() sync* {
		yield* ElfByteUtils.writeElf32Word(sh_name);
		yield* ElfByteUtils.writeElf32Word(sh_type);
		yield* ElfByteUtils.writeElf32Word(sh_flags);
		yield* ElfByteUtils.writeElf32Addr(sh_addr);
		yield* ElfByteUtils.writeElf32Off(sh_offset);
		yield* ElfByteUtils.writeElf32Word(sh_size);
		yield* ElfByteUtils.writeElf32Word(sh_link);
		yield* ElfByteUtils.writeElf32Word(sh_info);
		yield* ElfByteUtils.writeElf32Word(sh_addralign);
		yield* ElfByteUtils.writeElf32Word(sh_entsize);
	}

	@override
  String toString() {
    return '''
sh_name: ${ElfStringUtils.formatPretty16Str(sh_name, byteCount: 4)}
sh_type: ${ElfStringUtils.formatPretty16Str(sh_type, byteCount: 4)}
sh_flags: ${ElfStringUtils.formatPretty16Str(sh_flags, byteCount: 4)}
sh_addr: ${ElfStringUtils.formatPretty16Str(sh_addr, byteCount: 4)}
sh_offset: ${ElfStringUtils.formatPretty16Str(sh_offset, byteCount: 4)}
sh_size: ${ElfStringUtils.formatPretty16Str(sh_size, byteCount: 4)}
sh_link: ${ElfStringUtils.formatPretty16Str(sh_link, byteCount: 4)}
sh_info: ${ElfStringUtils.formatPretty16Str(sh_info, byteCount: 4)}
sh_addralign: ${ElfStringUtils.formatPretty16Str(sh_addralign, byteCount: 4)}
sh_entsize: ${ElfStringUtils.formatPretty16Str(sh_entsize, byteCount: 4)}
''';
  }
}