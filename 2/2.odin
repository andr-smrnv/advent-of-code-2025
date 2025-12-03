package main

import "core:strconv"
import "core:strings"
import "core:testing"
import "core:log"

just_symmetric :: proc (repeats: int) -> bool {
	return repeats == 2
}

all_repeats :: proc (repeats: int) -> bool {
	return repeats >= 2
}

main :: proc() {
	logger := log.create_console_logger()
	context.logger = logger
	defer log.destroy_console_logger(logger)

	input: string = #load("./input.txt")

	ranges := parse_ranges(&input)
	acc_1 := sum_ints_with_repeats(ranges, just_symmetric)
	log.info("Symmetric sum", acc_1)

	acc_2 := sum_ints_with_repeats(ranges, all_repeats)
	log.info("All repeats sum", acc_2)
}

sum_ints_with_repeats :: proc (ranges: []Range, cmp: proc(n: int) -> bool) -> u64 {
	acc: u64 = 0
	for range in ranges {
		start, ok_start := strconv.parse_u64(range.start)
		assert(ok_start)
		end, ok_end := strconv.parse_u64(range.end)
		assert(ok_end)

		for n in start..=end {
			if cmp(contains_repeats(n)) {
				acc += n 
			}
		}
	}

	return acc
}

contains_repeats :: proc (input: u64) -> (min_repetitions: int) {
	buf: [32]u8
	str := strconv.write_uint(buf[:], input, 10)

	for needle_width in 1..=len(str)/2 {
		needle := str[0:needle_width]

		if len(str) % needle_width != 0 {
			continue
		}

		total_segments := len(str) / needle_width

		matches := 0
		for i := 0; i + needle_width <= len(str); i += needle_width {
			segment := str[i:i+needle_width]
			if segment == needle {
				matches += 1
			}
		}

		if matches == total_segments && total_segments != 0 {
			min_repetitions = matches
		}
	}

	return min_repetitions
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
contains_repeats_test :: proc(t: ^testing.T) {
	testing.expect_value(t, contains_repeats(123123123), 3)
	testing.expect_value(t, contains_repeats(11), 2)
	testing.expect_value(t, contains_repeats(22), 2)
	testing.expect_value(t, contains_repeats(123123), 2)
	testing.expect_value(t, contains_repeats(28282828), 2)
	testing.expect_value(t, contains_repeats(145162145162), 2)
	testing.expect_value(t, contains_repeats(1), 0)
	testing.expect_value(t, contains_repeats(18282828), 0)
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
sample_1 :: proc(t: ^testing.T) {
	input: string = #load("./sample.txt")

	ranges := parse_ranges(&input)
	defer delete(ranges)

	acc := sum_ints_with_repeats(ranges, just_symmetric)

	testing.expect_value(t, acc, 1227775554)
}

@(test)
sample_2 :: proc(t: ^testing.T) {
	input: string = #load("./sample.txt")

	ranges := parse_ranges(&input)
	defer delete(ranges)

	acc := sum_ints_with_repeats(ranges, all_repeats)

	testing.expect_value(t, acc, 4174379265)
}