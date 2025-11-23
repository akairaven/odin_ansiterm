#+build !windows
package ansiterm
import "core:fmt"
import "core:io"
import os "core:os/os2"
import psx "core:sys/posix"

@(private = "file")
origMode: psx.termios

// Read a sequence from input up to 16 runes
//
// Returns : An array of rune and the number read
readSequence :: proc() -> (runeArray: [16]rune, nChar: u8) {
	inputBuffer: [64]u8 // each codepoint is possibly 4bytes long
	outputBuffer: [16]rune
	inStream := os.stdin.stream
	charCount, err := io.read(inStream, inputBuffer[:])
	if err != nil || charCount == 0 {
		fmt.eprint("Error reading input")
		return outputBuffer, 0
	}
	i := 0
	for r in string(inputBuffer[:charCount]) {
		if i >= 15 do break
		outputBuffer[i] = r
		i += 1
	}

	return outputBuffer, u8(charCount)
}

readInput :: proc() -> rune {
	// stdinStream := os.stream_from_handle(os.stdin) // for old os
	stdinStream := os.stdin.stream
	r, n, err := io.read_rune(stdinStream)
	if err != nil {
		fmt.eprintf("Error reading rune: %v\n", err)
		return 0
	}
	return r
}

enableVTMode :: proc() {
	res := psx.tcgetattr(psx.STDIN_FILENO, &origMode)
	assert(res == .OK)

	raw := origMode
	raw.c_lflag -= {.ECHO, .ICANON}
	res = psx.tcsetattr(psx.STDIN_FILENO, .TCSANOW, &raw)
	assert(res == .OK)
}

disableVTMode :: proc "c" () {
	psx.tcsetattr(psx.STDIN_FILENO, .TCSANOW, &origMode)
}

setUTF8Terminal :: proc() {
}
