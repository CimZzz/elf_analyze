import 'package:elf_analyze/src/elf_base.dart';
import 'package:elf_analyze/src/elf_buffer.dart';
import 'package:elf_analyze/src/elf_types.dart';

class ElfSectionHeader extends OperableProperty {

	///
	@Elf32_Word
	int sh_name;
//	typedef struct{
//
//	Elf32_Word sh_name;
//
//	Elf32_Word sh_type;
//
//	Elf32_Word sh_flags;
//
//	Elf32_Addr sh_addr;
//
//	Elf32_Off sh_offset;
//
//	Elf32_Word sh_size;
//
//	Elf32_Word sh_link;
//
//	Elf32_Word sh_info;
//
//	Elf32_Word sh_addralign;
//
//	Elf32_Word sh_entsize;
//
//}Elf32_Shdr;

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