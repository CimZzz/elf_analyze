import 'package:elf_analyze/src/elf_buffer.dart';

/// 可操作属性
/// 主要提供 2 个方法:
/// 转化数据为 Byte 流
/// 将 Byte 流转换为 数据
abstract class OperableProperty {
	Iterable<int> toByteStream();
	void readByByteStream(ElfStreamBuffer streamBuffer);
}