import 'package:elf_analyze/src/elf_types.dart';

import 'elf_exceptions.dart';

/// 用来转换 Byte 数据与 ELF 类型的工具
class ElfByteUtils {
	ElfByteUtils._();
	
	/// 读取 [Elf32_Addr]
	/// 流中至少应该有 4 个 byte
	@Elf32_Addr
	static int readElf32Addr(List<int> byteStream) {
		var addr = 0;
		if(byteStream.length != 4) {
			throw const ElfPropertyFormatException('Elf format error: read elf32addr not enough 4 bytes!');
		}
		
		for(final byte in byteStream.take(4)) {
			addr <<= 8;
			addr |= byte;
		}
		
		return addr;
	}
	
	/// 将 [Elf32_Addr] 转化为流
	@Elf32_Addr
	static Iterable<int> writeElf32Addr(int addr) sync* {
		for(var i = 4 ; i >= 0 ; i --) {
			yield (addr >> (8 * i)) & 0xFF;
		}
	}
	
	/// 读取 [Elf32_Off]
	/// 流中至少应该有 4 个 byte
	@Elf32_Off
	static int readElf32Off(List<int> byteStream) {
		var off = 0;
		if(byteStream.length != 4) {
			throw const ElfPropertyFormatException('Elf format error: read elf32off not enough 4 bytes!');
		}
		
		for(final byte in byteStream) {
			off <<= 8;
			off |= byte;
		}
		
		return off;
	}
	
	/// 将 [Elf32_Off] 转化为流
	@Elf32_Off
	static Iterable<int> writeElf32Off(int off) sync* {
		for(var i = 4 ; i >= 0 ; i --) {
			yield (off >> (8 * i)) & 0xFF;
		}
	}
	
	/// 读取 [Elf32_Half]
	/// 流中至少应该有 2 个 byte
	@Elf32_Half
	static int readElf32Half(List<int> byteStream) {
		var half = 0;
		if(byteStream.length != 2) {
			throw const ElfPropertyFormatException('Elf format error: read elf32half not enough 4 bytes!');
		}
		for(final byte in byteStream) {
			half <<= 8;
			half |= byte;
		}
		
		return half;
	}
	
	/// 将 [Elf32_Half] 转化为流
	@Elf32_Half
	static Iterable<int> writeElf32Half(int half) sync* {
		for(var i = 2 ; i >= 0 ; i --) {
			yield (half >> (8 * i)) & 0xFF;
		}
	}
	
	/// 读取 [Elf32_SWord]
	/// 流中至少应该有 4 个 byte
	@Elf32_SWord
	static int readElf32SWord(List<int> byteStream) {
		var sword = 0;
		
		if(byteStream.length != 4) {
			throw const ElfPropertyFormatException('Elf format error: read elf32sword not enough 4 bytes!');
		}
		
		for(final byte in byteStream) {
			sword <<= 8;
			sword |= byte;
		}
		
		return sword;
	}
	
	/// 将 [Elf32_SWord] 转化为流
	@Elf32_SWord
	static Iterable<int> writeElf32SWord(int sword) sync* {
		for(var i = 4 ; i >= 0 ; i --) {
			yield (sword >> (8 * i)) & 0xFF;
		}
	}
	
	
	
	/// 读取 [Elf32_Word]
	/// 流中至少应该有 4 个 byte
	@Elf32_Word
	static int readElf32Word(List<int> byteStream) {
		var sword = 0;
		
		if(byteStream.length != 4) {
			throw const ElfPropertyFormatException('Elf format error: read elf32sword not enough 4 bytes!');
		}
		
		for(final byte in byteStream) {
			sword <<= 8;
			sword |= byte;
		}
		
		
		return sword;
	}
	
	/// 将 [Elf32_Word] 转化为流
	@Elf32_Word
	static Iterable<int> writeElf32Word(int sword) sync* {
		for(var i = 4 ; i >= 0 ; i --) {
			yield (sword >> (8 * i)) & 0xFF;
		}
	}
	
	/// 读取 [Unsigned_Char]
	/// 流中至少应该有 4 个 byte
	@Unsigned_Char
	static int readElf32UnsignedChar(List<int> byteStream) {
		var unsignedChar = 0;
		
		if(byteStream.length != 4) {
			throw const ElfPropertyFormatException('Elf format error: read unsigned_char not enough 4 bytes!');
		}
		
		for(final byte in byteStream) {
			unsignedChar <<= 8;
			unsignedChar |= byte;
		}
		
		return unsignedChar;
	}
	
	/// 将 [Unsigned_Char] 转化为流
	@Unsigned_Char
	static Iterable<int> writeElf32UnsignedChar(int unsignedChar) sync* {
		for(var i = 4 ; i >= 0 ; i --) {
			yield (unsignedChar >> (8 * i)) & 0xFF;
		}
	}
	
	/// 将 [Elf_ByteBuffer] 转化为流
	@Elf_ByteBuffer
	static Iterable<int> writeElfByteBuffer(List<int> byteBuffer, int count) sync* {
		if (byteBuffer.length != count) {
			throw ElfPropertyFormatException(
				'Elf format error: write elf_byteBuffer not equal $count bytes!');
		}
		for (final byte in byteBuffer) {
			yield byte;
		}
	}

	/// 将原始数据转换为 大端字节序
	static int toMSB(int number, {int effectiveCount = -1}) {
		var loopCount = 0;
		if(effectiveCount == -1) {
			loopCount = 4;
		}
		var convertNumber = 0;
		for(var i = 0 ; i < loopCount ; i ++) {
			convertNumber |= (number >> (i * 8)) & 0xFF;
		}

		return convertNumber;
	}

	/// 将原始数据转换为 小端字节序
	static int toLSB(int number, {int effectiveCount = -1}) {
		var loopCount = effectiveCount;
		if(loopCount == -1) {
			loopCount = 4;
		}
		var convertNumber = 0;
		for(var i = loopCount - 1 ; i >= 0 ; i --) {
			convertNumber |= (number >> (i * 8)) & 0xFF;
		}

		return convertNumber;
	}
}


class ElfStringUtils {
	static String formatPretty16Str(int number, {int byteCount = 1, String separator = '', bool needPrefix = true}) {
		if(byteCount != 1) {
			var numStr = '';
			for(var i = byteCount - 1 ; i >= 0 ; i --) {
				if(i != byteCount) {
					numStr += separator;
				}
				numStr += formatPretty16Str((number >> (i * 8)) & 0xFF, needPrefix: false);
			}
			
			if(needPrefix) {
				return '0x$numStr';
			}
			else {
				return numStr;
			}
		}
		else {
			var numStr = (number & 0xFF).toRadixString(16);
			if(numStr.length == 1) {
				numStr = '0$numStr';
			}
			
			if(needPrefix) {
				return '0x$numStr';
			}
			else {
				return numStr;
			}
		}
		 
	}
}

/// 用来打印数据的工具
class ElfPrintUtils {
	static void printObj(String header, Object obj) {
		print('''
************************************************
* 对象名: $header
************************************************
$obj
		''');
	}
}