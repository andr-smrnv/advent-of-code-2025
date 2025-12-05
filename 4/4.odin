package main

import "core:strings"
import "core:testing"
import "core:log"

main :: proc() {
	logger := log.create_console_logger()
	context.logger = logger
	defer log.destroy_console_logger(logger)

	input: string = #load("./input.txt")
	defer delete(input)
	grid := strings.split_lines(input)
	front_buf := make([]string, len(grid))
	copy_slice(front_buf, grid)


	total_count := 0
	for {
		back_buf := make([]string, len(grid))
		copy_slice(back_buf, front_buf)

		count_removed := 0
		for row, i in back_buf {
			for cell, j in row {
				if cell == '@' && count_neighbors(back_buf, {i, j}) < 4 {
					temp := make([]u8, len(back_buf[i]))
					copy_from_string(temp, front_buf[i])
					temp[j] = 'x'
					front_buf[i] = string(temp)
					count_removed += 1
				}
			}
		}
		if count_removed == 0 do break

		total_count += count_removed
	}
	log.info(total_count)
}

count_neighbors :: proc(grid: []string, pos: [2]int) -> int {
	directions := [?][2]int{
		{-1, -1}, {-1, 0}, {-1, 1},
		{ 0, -1}, /*    */ { 0, 1},
		{ 1, -1}, { 1, 0}, { 1, 1},
	}

	count := 0
	for dir in directions {
		if get_tile_at(grid, pos + dir) == '@' {
			count += 1
		}
	}
	return count
}

get_tile_at :: proc(grid: []string, pos: [2]int) -> u8 {
	if pos[0] < 0 || pos[0] >= len(grid) {
		return '^'
	}

	if pos[1] < 0 || pos[1] >= len(grid[pos[0]]) {
		return '^'
	}

	return grid[pos[0]][pos[1]]
}

@(test)
get_tile_at_test :: proc(t: ^testing.T) {
	input := [?]string{
		"..@.@..@",
		"@@.@.@@.",
		"@@.@.@@.",
	}

	testing.expect_value(t, get_tile_at(input[:], {0,0}), '.')
	testing.expect_value(t, get_tile_at(input[:], {-1,-50}), '^')
	testing.expect_value(t, get_tile_at(input[:], {200,300}), '^')
	testing.expect_value(t, get_tile_at(input[:], {0,4}), '@')
	testing.expect_value(t, get_tile_at(input[:], {2,3}), '@')
}
