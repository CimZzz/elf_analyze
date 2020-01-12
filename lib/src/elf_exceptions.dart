
abstract class ElfException implements Exception {
	const ElfException(this.msg);
	final String msg;
	
	@override
	String toString() {
		return msg;
	}
}


class ElfPropertyFormatException extends ElfException {
    const ElfPropertyFormatException(String msg) : super(msg);
}

class ElfBufferException extends ElfException {
	const ElfBufferException(String msg) : super(msg);
}