import 'package:elf_analyze/src/elf_base.dart';
import 'package:elf_analyze/src/elf_buffer.dart';
import 'package:elf_analyze/src/elf_types.dart';

class ElfProgramHeader extends OperableProperty {
	
	/// 程序头部表类型
	///
	/// 00 - PT_NULL, 表示此数组未使用
	///
	/// 01 - PT_LOAD, 表示一个可加载的段, 段的大小由 p_filesz 和 p_memsz 描述. 如果 p_filesz 大于 p_memsz, 那么剩余
	///      部分将会被清零. (p_filesz 不能大于 p_memsz)
	///      可加载的段在程序头部表中按照 p_vaddr 升序排序
	///
	/// 02 - PT_DYNAMIC 表明动态链接的信息
	///
	/// 03 - PT_INTERP 指向一个以 `null` 结尾的字符串，表示 ELF 解析器的路径. 只在 Executable ELF 中有效
	///
	/// 04 - PT_NOTE 指向一个以 `null` 结尾的字符串, 可以包含一些附加的信息
	///
	/// 05 - PT_SHLIB 未定义语法，保留字段
	///
	/// 06 - PT_PHDR 表示自身所在程序头表在文件或内存中的位置和大小. 这样的段可以不存在，如果出现只能出现一次，并且要在其他可装载段
	///      的表项之前。
	@Elf32_Word
	int p_type;
	
	/// 表示本段内容在文件中的位置
	@Elf32_Off
	int p_offset;
	
	/// 此数据成员表示本段内容的开始位置在进程空间中的虚拟地址
	@Elf32_Addr
	int p_vaddr;
	
	/// 此数据成员表示本段内容的开始位置在进程空间中的物理地址. 因为大多数操作系统事先不知道物理地址, 所以目前这个
	/// 字段保留不用
	@Elf32_Addr
	int p_paddr;
	
	/// 表示本段内容在文件中的大小，单位是字节，可以为 0。
	@Elf32_Word
	int p_filesz;
	
	/// 表示本段内容在内存中的大小，单位是字节，可以为 0。
	@Elf32_Word
	int p_memsz;
	
	/// 表示本段内容的数据
	/// 分为以下几种权限:
	/// 01 - PF_X 可执行
	/// 02 - PF_W 可写
	/// 04 - PF_R 只读
	@Elf32_Word
	int p_flags;
	
	/// 对齐字节
	/// p_vaddr 和 p_offset 对 p_align 取模后应该等于 0
	@Elf32_Word
	int p_align;
	
	@override
	void readByByteStream(ElfStreamBuffer streamBuffer) {
	
	}
	
	@override
	Iterable<int> toByteStream() {
		return null;
	}
}