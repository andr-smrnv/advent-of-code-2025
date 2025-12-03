package main

import "core:strconv"
import "core:strings"
import "core:testing"
import "core:log"
import "core:math"


main :: proc() {
	logger := log.create_console_logger()
	context.logger = logger
	defer log.destroy_console_logger(logger)

	input: string = #load("./input.txt")

	ranges := parse_ranges(&input)
	acc := sum_all_symmetric(ranges)

	log.info(acc)
}

sum_all_symmetric :: proc (ranges: []Range) -> u64 {
	acc: u64 = 0
	for range in ranges {
		start, ok_start := strconv.parse_u64(range.start)
		assert(ok_start)
		end, ok_end := strconv.parse_u64(range.end)
		assert(ok_end)

		for n in start..=end {
			if is_symmetrical(n) {
				acc += n 
			}
		}
	}

	return acc
}

is_symmetrical :: proc (input: u64) -> bool {
	buf: [32]u8
	str := strconv.write_uint(buf[:], input, 10)

	if len(str) % 2 != 0 {
		return false
	}

	half := len(str) / 2
	return str[0:half] == str[half:]
}

Range :: struct {
	start: string,
	end: string
}

parse_ranges :: proc(input: ^string) -> []Range {
	chunks := strings.split(input^, ",")
	defer delete(chunks)

	ranges := make([]Range, len(chunks))
	for chunk, i in chunks {
		parts := strings.split(chunk, "-")
		defer delete(parts)

		ranges[i] = Range {
			start = parts[0],
			end = parts[1]
		}
	}

	return ranges
}


@(test)
parse_ranges_test :: proc(t: ^testing.T) {
	input := "11-22,95-115,998-1012,1188511880-1188511890,222220-222224"
	ranges := parse_ranges(&input)
	defer delete(ranges)

	expected := make([]Range, 5)
	defer delete(expected)
	expected[0] = Range {start="11", end="22"}
	expected[1] = Range {start="95", end="115"}
	expected[2] = Range {start="998", end="1012"}
	expected[3] = Range {start="1188511880", end="1188511890"}
	expected[4] = Range {start="222220", end="222224"}

	for item, i in expected {
		testing.expect_value(t, item, ranges[i])
	}
}

@(test)
sample :: proc(t: ^testing.T) {
	input: string = #load("./sample.txt")

	ranges := parse_ranges(&input)
	defer delete(ranges)

	acc := sum_all_symmetric(ranges)

	testing.expect_value(t, acc, 1227775554)
}
