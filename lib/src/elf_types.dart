
/// ELF 字段类型
class _ElfType {
	const _ElfType();
}

/// Elf 32-bit address 无符号程序地址
/// size: 4 Byte
/// example: 00 00 00 00 00 00 00 00
const Elf32_Addr = _ElfType();

/// 无符号中等整数
/// size: 2
const Elf32_Half = _ElfType();

/// 无符号文件偏移
/// size: 4
const Elf32_Off = _ElfType();

/// 有符号大整数
/// size: 4
const Elf32_SWord = _ElfType();

/// 无符号大整数
/// size: 4
const Elf32_Word = _ElfType();

/// 无符号小整数
/// size: 1
const Unsigned_Char = _ElfType();

/// Byte 缓冲区
/// size: infinite
/// 通常由其他字段表示该缓冲区的长度
const Elf_ByteBuffer = _ElfType();