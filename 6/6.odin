package main

import "core:slice"
import "core:strconv"
import "core:strings"
import "core:log"

main :: proc() {
	logger := log.create_console_logger()
	context.logger = logger
	defer log.destroy_console_logger(logger)

	input: string = #load("./input.txt")
	defer delete(input)

	ops, numbers := parse_input_part1(&input)

	total: uint = 0
	for op, i in ops {
		acc: uint = 0
		for rows in numbers {

			switch op {
				case Op.Mul:
					if acc == 0 do acc = 1
					acc *= rows[i]
				case Op.Sum:
					acc += rows[i]
			}
		}

		total += acc
	}
	log.info("Part 1:", total)

	part2 := part2_solution(&input)
	log.info("Part 2:", part2)

}


part2_solution :: proc(input: ^string) -> uint {
	lines := strings.split_lines(input^)

	final_answer: uint = 0

	row_count := len(lines)
	columns_count := len(lines[0])

	numbers_buf: [8]uint
	numbers_buf_used := 0
	// every column in reverse
	for i := columns_count - 1; i >= 0; i -= 1 {

		digits_buf: [4]u8
		digits_buf_used := 0
		// every row in the column
		for line, j in lines {
			// if not on the last row and not empty, remember a digit
			if line[i] != ' ' && j != row_count - 1 {
				digits_buf[digits_buf_used] = line[i]
				digits_buf_used += 1
			}

			// hit the last row, combine all remembered digits into a number
			if j == row_count - 1 {
				str := transmute(string)digits_buf[:digits_buf_used]
				num, ok := strconv.parse_uint(str)
				numbers_buf[numbers_buf_used] = num
				numbers_buf_used += 1
				digits_buf_used = 0
			} 

			// hit the last row AND an op symbol, time to perform the op on the collected numbers
			if j == row_count - 1 && line[i] != ' ' {
				numbers := numbers_buf[:numbers_buf_used]
				res: uint
				switch line[i] {
					case '*':
						res = slice.reduce(numbers, uint(1), proc(acc: uint, n: uint) -> uint {
							return acc * n
						})
					case '+':
						res = slice.reduce(numbers, uint(0), proc(acc: uint, n: uint) -> uint {
							return acc + n
						})
				}

				numbers_buf_used = 0
				i -= 1 // skip an empty column

				final_answer += res
			}
		}
	}

	return final_answer
}

Op :: enum{Mul = '*', Sum = '+'}

parse_input_part1 :: proc(input: ^string) -> ([]Op, [][]uint) {
	lines := strings.split_lines(input^)

	last_line := lines[len(lines) - 1]
	buf: [2048]Op
	columns := 0
	for char, i in last_line {
		if char == ' ' do continue
		buf[columns] = cast(Op)char
		columns += 1
	}
	ops := buf[:columns]

	numbers := make([][]uint, len(lines) - 1)
	for line, i in lines[:len(lines) - 1] {
		row := make([]uint, len(ops))
		used_row := 0

		buf: [32]u8
		used_buf := 0
		for char, j in line {
			if char != ' ' {
				buf[used_buf] = cast(u8)char
				used_buf += 1
				if j == len(line) - 1 || line[j + 1] == ' ' {
					str := transmute(string)buf[:used_buf]
					num, ok := strconv.parse_uint(str)
					row[used_row] = num
					used_buf = 0
					used_row += 1
				}
			}
		}
		numbers[i] = row
	}

	return ops, numbers
}