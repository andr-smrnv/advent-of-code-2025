package main

import "core:slice"
import "core:strconv"
import "core:strings"
import "core:testing"
import "core:log"

main :: proc() {
	logger := log.create_console_logger()
	context.logger = logger
	defer log.destroy_console_logger(logger)

	input: string = #load("./input.txt")
	defer delete(input)

	ranges, ids := parse_input(&input)


	// part 1
	fresh := 0
	ids_loop: for id in ids {
		for range in ranges {
			if id >= range.start && id <= range.end {
				fresh += 1
				continue ids_loop
			}
		}
	}
	log.info("Fresh", fresh)

  // part 2
  possible_ids := count_ranges(ranges)
	log.info("Unique", possible_ids)
}

count_ranges :: proc(ranges: []Range) -> uint {
	deduped_ranges := merge_overlaps(ranges)
	possible_ids: uint = 0
	for range in deduped_ranges {
		span :=  (range.end - range.start) + 1
		possible_ids += span
	}

	return possible_ids
}

merge_overlaps :: proc(ranges: []Range) -> []Range {
	result := make([dynamic]Range)

	sorted := slice.clone(ranges)
	defer delete(sorted)
	slice.stable_sort_by(sorted, proc(i, j: Range) -> bool {
		if i.start == j.start {
			return i.end > j.end
		} else {
			return i.start < j.start
		}
	})

	curr_range := Range{
		start = sorted[0].start,
		end = sorted[0].end
	}

	for range in sorted[1:] {
		// there's an overlap
		if range.start >= curr_range.start && range.start <= curr_range.end {
			if range.end <= curr_range.end {
				// swallow
				continue
			} else {
				// extend
				curr_range.end = range.end
				continue
			}
		}

		// no overlap, record the range and start a new one
		append(&result, curr_range)
		curr_range = range
	}
	// we're one iteration short
	append(&result, curr_range)

	return result[:]
}

Range :: struct {
	start: uint,
	end: uint
}

parse_input :: proc(input: ^string) -> ([]Range, []uint) {
	ranges := make([dynamic]Range)
	identifiers := make([dynamic]uint)

	parsing_ranges := true
	for line in strings.split_lines_iterator(input) {
		if line == "" {
			parsing_ranges = false
			continue
		}

		if parsing_ranges {
			pair := strings.split(line, "-")
			start, start_ok := strconv.parse_uint(pair[0])
			end, end_ok := strconv.parse_uint(pair[1])
			range := Range{start, end}
			append(&ranges, range)
		} else {
			id, ok := strconv.parse_uint(line)
			append(&identifiers, id)
		}
	}



	return ranges[:], identifiers[:]
}

@(test)
count_ranges_test1 :: proc(t: ^testing.T) {
	ranges := [?]Range{
		Range{3, 5},
		Range{3, 5},
		Range{10, 14},
		Range{10, 15},
		Range{10, 16},
		Range{16, 20},
		Range{16, 20},
		Range{16, 20},
		Range{3, 3},
		Range{12, 18},
	}

	testing.expect_value(t, count_ranges(ranges[:]), 14)
}

@(test)
merge_overlaps_test_long :: proc(t: ^testing.T) {
	ranges := [?]Range{
		Range{3, 5},
		Range{10, 14},
		Range{12, 18},
		Range{16, 20},
		Range{2, 5},
		Range{2, 11}
	}

	result := merge_overlaps(ranges[:])
	defer delete(result)

	sorted := [?]Range{
	  Range{2, 20},
	}

	for range, i in result {
		testing.expect_value(t, range, sorted[i])
	}
}

@(test)
merge_overlaps_test_sample :: proc(t: ^testing.T) {
	ranges := [?]Range{
		Range{3, 5},
		Range{10, 14},
		Range{16, 20},
		Range{12, 18},
	}

	result := merge_overlaps(ranges[:])
	defer delete(result)

	sorted := [?]Range{
	  Range{3, 5},
	  Range{10, 20},
	}

	for range, i in result {
		testing.expect_value(t, range, sorted[i])
	}
}