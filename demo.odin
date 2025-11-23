package main
import "core:mem"
import "core:fmt"
import "core:unicode/utf8"
import aterm "ansiterm"

Console :: struct {
    rows : int,
    cols : int,
}

console : Console
TITLE :: " Terminal App "

drawScreen :: proc() {
    fmt.print(aterm.ClearScreen)
    fmt.printf(aterm.CursorPosition, 1, 1)
    fmt.printf(aterm.BackgroundColor, 25, 75, 127)
    fmt.printf(aterm.ForegroundColor, 250, 250, 250)
    fmt.print(aterm.EraseLine)
    fmt.printf(" %s%s%s ", aterm.EnableBold, TITLE, aterm.DisableBold) 
    fmt.print(aterm.DefaultStyle)
}

demoReadInput :: proc() {
    previousKey : rune
    for {
        drawScreen()
        fmt.printf(aterm.CursorPosition, 2, 1)
        fmt.print("This reads a single character but doesn't handle sequences like the Arrow keys\n")
        fmt.print("Press Q to quit\n")
        fmt.printf("The previous key was %r", previousKey)
        result := aterm.readInput()
        previousKey = result
        // fmt.print(result)
        switch {
            case result == 'Q':
                fallthrough
            case result == 'q':
                return
        }
    }
}

demoSequence :: proc() {
    previousSequence : [16]rune
    previousLength : u8
    for {
        drawScreen()
        fmt.printf(aterm.CursorPosition, 2, 1)
        fmt.print("This reads a sequence of characters up to 16 runes including Arrow keys\n")
        fmt.print("Press ESC or Q to quit\n")
        fmt.printf("The previous sequence was %w of length %d\n", previousSequence, previousLength)
        escapeSequence := utf8.runes_to_string(previousSequence[:previousLength])
        defer delete(escapeSequence)
        switch escapeSequence {
            case aterm.KEY_UP:
                fmt.printf("UP KEY\n") 
            case aterm.KEY_DOWN:
                fmt.printf("DOWN KEY\n") 
            case aterm.KEY_LEFT:
                fmt.printf("LEFT KEY\n") 
            case aterm.KEY_RIGHT:
                fmt.printf("RIGHT KEY\n") 
            case aterm.KEY_F1:
                fmt.printf("F1 KEY\n") 
            case:fmt.printf("Another Escape Sequence\n")
        }
        sequence, n := aterm.readSequence()
        previousSequence = sequence
        previousLength = n
        // fmt.print(result)
        switch {
            case (n == 1) & (sequence[0] == '\e'):
                return
            case sequence[0] == 'q':
                return
        }
    }
}

mainProgram :: proc() {
    aterm.setUTF8Terminal()
    aterm.enableVTMode()
    defer aterm.disableVTMode()
    fmt.print(aterm.HideCursor)
    rows, cols := aterm.getScreenSize()
    console.rows = rows
    console.cols = cols
    // single key loop
    demoReadInput()
    // sequence loop
    demoSequence()
}

main :: proc () {
    when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer {
			if len(track.allocation_map) > 0 {
				fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
				for _, entry in track.allocation_map {
					fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			}
			mem.tracking_allocator_destroy(&track)
		}
	}
    mainProgram()
    fmt.print(aterm.HardReset)
}
