package ansiterm

import "core:fmt"
import "core:strconv"
import "core:unicode/utf8"

getScreenSize :: proc() -> (row: int, cols: int) {
	fmt.print("\e7\e[999;999H\e[6n")
    runeArray, n := readSequence()
    sequence := utf8.runes_to_string(runeArray[:n], context.temp_allocator)    
    defer delete(sequence, context.temp_allocator)
	idx : u8 = 0
	for i in 0 ..< n {
		if sequence[i] == ';' {
			idx = i
			break
		}
	}
	w, h: int
    if idx == 0 {
        fmt.eprintf("Error parsing screensize : %v\n", runeArray)
        return 0,0
    }
	conversionErr: bool
	h, conversionErr = strconv.parse_int(sequence[2:idx])
	w, conversionErr = strconv.parse_int(sequence[idx + 1:n - 1])
	return h, w
}


/* return a memory allocated string */
inputLine :: proc(echo := true) -> string {
	inputBuffer := make([dynamic]rune, context.temp_allocator)
	defer delete(inputBuffer)
	done := false
	for !done {
		r := readInput()
		switch {
		case r == '\r':
			fallthrough
		case r == '\n':
			done = true
		case r >= 32:
			if echo do fmt.print(r)
			append(&inputBuffer, r)
		case:
		}
	}
	return fmt.aprintf("%s", inputBuffer)
}
