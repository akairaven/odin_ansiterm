package ansiterm

import "core:fmt"
import win32 "core:sys/windows"

@(private = "file")

origMode: win32.DWORD
stdin: win32.HANDLE
ConsoleSize :: struct {
	width:  u16,
	height: u16,
}
// Read a sequence from input up to 16 runes
//
// Returns : An array of rune and the number read
readSequence :: proc() -> (runeArray: [16]rune, nChar: u8) {
	records_read: win32.DWORD
	input_records: [32]win32.INPUT_RECORD
	buf: [16]rune
	success := win32.ReadConsoleInputW(stdin, &input_records[0], len(input_records), &records_read)
	if !success || records_read == 0 {
		fmt.eprint("Error reading input")
		return buf, 0
	}
	charCount: u8 = 0
	for i in 0 ..< records_read {
		record := input_records[i]
		if charCount >= 15 do break
		if record.EventType == .KEY_EVENT {
			key := record.Event.KeyEvent.uChar.UnicodeChar
			// fmt.printf("key : %v", key)
			if (record.Event.KeyEvent.bKeyDown) & (key != 0) {
				buf[charCount] = rune(key)
				charCount += 1
			}
		}
	}
	return buf, charCount
}

readInput :: proc() -> rune {
	records_read: win32.DWORD
	input_record: win32.INPUT_RECORD // Can be an array if reading multiple at once

	for {
		success := win32.ReadConsoleInputW(stdin, &input_record, 1, &records_read)
		if !success || records_read == 0 {
			fmt.eprint("Error reading input")
		}
		#partial switch input_record.EventType {
		// implement a function or cb for when screen resize
		// case .WINDOW_BUFFER_SIZE_EVENT:
		//     fmt.printf("Resize : %v %v\n",input_record.Event.WindowBufferSizeEvent.dwSize.X, input_record.Event.WindowBufferSizeEvent.dwSize.Y)
		case .KEY_EVENT:
			key_event := input_record.Event.KeyEvent
			key := key_event.uChar.UnicodeChar
			if key_event.bKeyDown {
				return rune(key)
			}
		}
	}
	return 0
	// return 'q'
}

enableVTMode :: proc() {
	stdin = win32.GetStdHandle(win32.STD_INPUT_HANDLE)
	assert(stdin != win32.INVALID_HANDLE_VALUE)
	ok := win32.GetConsoleMode(stdin, &origMode)
	assert(ok == true)

	raw := origMode
	raw &= ~win32.ENABLE_ECHO_INPUT
	raw &= ~win32.ENABLE_LINE_INPUT
	raw |= win32.ENABLE_VIRTUAL_TERMINAL_INPUT // returns VT/ansi sequences
	// new_mode := current_mode | windows.ENABLE_MOUSE_INPUT | windows.ENABLE_WINDOW_INPUT;
	// raw |= win32.ENABLE_MOUSE_INPUT
	// raw |= win32.ENABLE_MOUSE_INPUT | win32.ENABLE_WINDOW_INPUT;
	// raw |= current_mode | windows.ENABLE_MOUSE_INPUT | windows.ENABLE_WINDOW_INPUT;
	raw &= ~win32.ENABLE_PROCESSED_INPUT // handles ctrl-c

	ok = win32.SetConsoleMode(stdin, raw)
	assert(ok == true)
	win32.FlushConsoleInputBuffer(stdin)
}

disableVTMode :: proc() {
	stdin := win32.GetStdHandle(win32.STD_INPUT_HANDLE)
	assert(stdin != win32.INVALID_HANDLE_VALUE)
	win32.SetConsoleMode(stdin, origMode)
}

// @(win32: "subsystem:console") // Ensure it runs as a console application
keyboardInput :: proc() {
	// if stdin == win32.INVALID_HANDLE_VALUE {
	//     fmt.println("Failed to get input handle");
	//     return;
	// }

	previous_key: u16
	frame := 0
	for {
		frame += 1
		records_read: win32.DWORD
		input_record: win32.INPUT_RECORD // Can be an array if reading multiple at once
		count: win32.DWORD
		ok := win32.GetNumberOfConsoleInputEvents(stdin, &count)
		if !ok {
			fmt.eprintf("Error count")
		}

		fmt.printf("フレームFrame count is : %v\r", frame)
		if count > 0 {
			success := win32.ReadConsoleInputW(
				stdin,
				&input_record,
				1, // Read 1 record at a time
				&records_read,
			)

			if !success || records_read == 0 {
				break // Exit loop on error or no input
			}

			#partial switch input_record.EventType {
			case .WINDOW_BUFFER_SIZE_EVENT:
				fmt.printf(
					"Resize : %v %v\n",
					input_record.Event.WindowBufferSizeEvent.dwSize.X,
					input_record.Event.WindowBufferSizeEvent.dwSize.Y,
				)
			case .KEY_EVENT:
				key_event := input_record.Event.KeyEvent
				key := key_event.uChar.UnicodeChar
				// fmt.printf("Repeated : %v", input_record.Event.KeyEvent.wRepeatCount)
				keyState := input_record.Event.KeyEvent.dwControlKeyState
				if !key_event.bKeyDown {
					// fmt.printf("Key release %v", key)
					previous_key = 60000
				}
				if key_event.bKeyDown {
					if key != previous_key {
						if .LEFT_ALT_PRESSED in keyState do fmt.print("ALT-")
						if .SHIFT_PRESSED in keyState do fmt.print("SHIFT-")
						fmt.printf(
							"%c pressed (Virtual Key: %d)\n",
							cast(rune)key,
							key_event.wVirtualKeyCode,
						)
					}
					// fmt.printf(
					// 	"Key pressed: %v (Virtual Key: %d)\n",
					// 	key_event.uChar.UnicodeChar,
					// 	key_event.wVirtualKeyCode,
					// )
					if key_event.wVirtualKeyCode == win32.VK_ESCAPE {
						return // Exit on Escape key
					}
					if cast(rune)key_event.uChar.UnicodeChar == 'q' {
						return // Exit on Escape key
					}

					if cast(rune)key_event.uChar.UnicodeChar == 's' {

						fmt.print("\e7\e[999;999H\e[6n")
					}
					previous_key = key
				}
			case .MOUSE_EVENT:
				// Handle mouse events here if enabled with SetConsoleMode
				mouse_event := input_record.Event.MouseEvent
				fmt.printf(
					"Mouse event at X:%d, Y:%d\n",
					mouse_event.dwMousePosition.X,
					mouse_event.dwMousePosition.Y,
				)
			}
		}
	}
	// stdin := win32.GetStdHandle(win32.STD_INPUT_HANDLE)
	// assert_contextless(stdin != win32.INVALID_HANDLE_VALUE)

}

setUTF8Terminal :: proc() {

	success_out := win32.SetConsoleOutputCP(.UTF8)
	if !success_out {
		fmt.println("Failed to set console output to UTF-8")
	}
	success_in := win32.SetConsoleCP(.UTF8)
	if !success_in {
		fmt.println("Failed to set console input to UTF-8")
	}
}
