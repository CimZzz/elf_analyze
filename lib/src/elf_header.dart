
import 'package:elf_analyze/src/elf_buffer.dart';
import 'package:elf_analyze/src/elf_utils.dart';

import 'elf_base.dart';
import 'elf_types.dart';

const EI_NIDENT = 16;

/// ELF 文件头部
/// 位于文件开始，存放了整个文件很多重要的信息，用来描述这个文件。

class ElfHeader extends OperableProperty {
	/// ELF 标识数组
	/// 长度为 [EI_NIDENT]
	/// 0 - 3 : EI_MAG0 - EI_MAG3 为 ELF 文件头 7F 45 4C 46(ELF)
	///
	/// 4     : EI_CLASS 代表 32位 / 64位 程序
	///         01 - ELFCLASS32 表示 32 位程序
	///         02 - ELFCLASS64 表示 64 位程序
	///
	/// 5     : EI_DATA 数据编码, 取值含义如下
	///         01 - LSB 表示高位在后 (小端字节序)
	///         02 - MSB 表示低位在后 (大端字节序)
	///
	/// 6     : EI_VERSION 文件版本，固定值 01 (EV_CURRENT)
	///
	/// 7     : EI_PAD 对齐字节，将未使用的字节置为 00
	@Unsigned_Char
	List<int> e_ident;
	
	/// ELF 文件类型标识
	///
	/// 00 - ET_NONE 未知文件类型格式
	///
	/// 01 - EET_REL 可重定位文件
	///
	/// 02 - ET_EXEC 可执行文件
	///
	/// 03 - ET_DYN 共享目标文件 (so)
	///
	/// ...
	@Elf32_Half
	int e_type;
	
	/// ELF 声明 ABI
	///
	/// 03 - EM_386 表示 x86 架构
	///
	/// 0x28 - EM_ARM 标识 arm 架构
	///
	/// ...
	@Elf32_Half
	int e_machine;
	
	/// 文件版本，同 e_ident 中 EL_VERSION 一致
	@Elf32_Word
	int e_version;
	
	/// 可执行程序入口点地址
	@Elf32_Addr
	int e_entry;
	
	/// Program Header Offset
	/// 程序头部表偏移地址，如果没有则为 0
	@Elf32_Off
	int e_phoff;
	
	/// Section Header Offset
	/// 节区表偏移地址，如果没有则为 0
	@Elf32_Off
	int e_shoff;
	
	/// 特定处理器标志
	@Elf32_Word
	int e_flags;
	
	/// ELF Header Size
	/// ELF 头部大小
	@Elf32_Half
	int e_ehsize;
	
	/// 程序头部表的单个表项大小
	@Elf32_Half
	int e_phentsize;
	
	/// 程序头部表的表项数
	@Elf32_Half
	int e_phnum;
	
	/// 节区表的单个表项大小
	@Elf32_Half
	int e_shentsize;
	
	/// 节区表的表项数
	@Elf32_Half
	int e_shnum;
	
	/// String table index
	/// 每个节区表都会有一个存储各节区名称的节区(通常是最后一个),这里表示这个名称表在第几个节区
	@Elf32_Half
	int e_shstrndx;
	
	@override
	void readByByteStream(ElfStreamBuffer streamBuffer) async {
		e_ident = await streamBuffer.nextBytes(EI_NIDENT);
		e_type = await streamBuffer.nextElf32Half();
		e_machine = await streamBuffer.nextElf32Half();
		e_version = await streamBuffer.nextElf32Word();
		e_entry = await streamBuffer.nextElf32Addr();
		e_phoff = await streamBuffer.nextElf32Off();
		e_shoff = await streamBuffer.nextElf32Off();
		e_flags = await streamBuffer.nextElf32Word();
		e_ehsize = await streamBuffer.nextElf32Half();
		e_phentsize = await streamBuffer.nextElf32Half();
		e_phnum = await streamBuffer.nextElf32Half();
		e_shentsize = await streamBuffer.nextElf32Half();
		e_shnum = await streamBuffer.nextElf32Half();
		e_shstrndx = await streamBuffer.nextElf32Half();
	}
	
	@override
	Iterable<int> toByteStream() sync* {
		yield* ElfByteUtils.writeElfByteBuffer(e_ident, EI_NIDENT);
		yield* ElfByteUtils.writeElf32Half(e_type);
		yield* ElfByteUtils.writeElf32Half(e_machine);
		yield* ElfByteUtils.writeElf32Word(e_version);
		yield* ElfByteUtils.writeElf32Addr(e_entry);
		yield* ElfByteUtils.writeElf32Off(e_phoff);
		yield* ElfByteUtils.writeElf32Off(e_shoff);
		yield* ElfByteUtils.writeElf32Word(e_flags);
		yield* ElfByteUtils.writeElf32Half(e_ehsize);
		yield* ElfByteUtils.writeElf32Half(e_phentsize);
		yield* ElfByteUtils.writeElf32Half(e_phnum);
		yield* ElfByteUtils.writeElf32Half(e_shentsize);
		yield* ElfByteUtils.writeElf32Half(e_shnum);
		yield* ElfByteUtils.writeElf32Half(e_shstrndx);
	}
	
	
	@override
	String toString() {
		return '''
e_ident: ${e_ident.map((int num) => ElfStringUtils.formatPretty16Str(num)).join(" ")}
e_type: ${ElfStringUtils.formatPretty16Str(e_type, byteCount: 2)}
e_machine: ${ElfStringUtils.formatPretty16Str(e_machine, byteCount: 2)}
e_version: ${ElfStringUtils.formatPretty16Str(e_version, byteCount: 4)}
e_entry: ${ElfStringUtils.formatPretty16Str(e_entry, byteCount: 4)}
e_phoff: ${ElfStringUtils.formatPretty16Str(e_phoff, byteCount: 4)}
e_shoff: ${ElfStringUtils.formatPretty16Str(e_shoff, byteCount: 4)}
e_flags: ${ElfStringUtils.formatPretty16Str(e_flags, byteCount: 4)}
e_ehsize: ${ElfStringUtils.formatPretty16Str(e_ehsize, byteCount: 2)}
e_phentsize: ${ElfStringUtils.formatPretty16Str(e_phentsize, byteCount: 2)}
e_phnum: ${ElfStringUtils.formatPretty16Str(e_phnum, byteCount: 2)}
e_shentsize: ${ElfStringUtils.formatPretty16Str(e_shentsize, byteCount: 2)}
e_shnum: ${ElfStringUtils.formatPretty16Str(e_shnum, byteCount: 2)}
e_shstrndx: ${ElfStringUtils.formatPretty16Str(e_shstrndx, byteCount: 2)}
''';
	}
}