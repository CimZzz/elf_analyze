
import 'package:elf_analyze/src/elf_base.dart';

import 'elf_buffer.dart';
import 'elf_types.dart';
import 'elf_utils.dart';

class ElfSymbolTable extends OperableProperty {

	List<ElfSymbol> _symbolTable;

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
		final realSize = ElfByteUtils.toLSB(_size);
		buffers = await streamBuffer.nextBytes(realSize);
	}

	@override
	Iterable<int> toByteStream() sync* {
		yield* buffers;
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
	/// 0F -  STB_HIPROC 为处理保留的属性区间
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
	/// 0F - STB_HIPROC 为处理保留的属性区间
	@Unsigned_Char
	int st_info;

	/// 暂未使用，一律赋值为 0
	@Unsigned_Char
	int st_other;

	/// 任何一个符号表项的定义都与某一个 "节" 相联系，
	@Elf32_Half
	int st_shndx;




	@override
  void readByByteStream(ElfStreamBuffer streamBuffer) {
    // TODO: implement readByByteStream
  }

  @override
  Iterable<int> toByteStream() {
    // TODO: implement toByteStream
    return null;
  }

}