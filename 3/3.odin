package main

import sa "core:container/small_array"
import "core:strconv"
import "core:strings"
import "core:testing"
import "core:log"
import "core:unicode/utf8"
import "core:math"



main :: proc() {
	logger := log.create_console_logger()
	context.logger = logger
	defer log.destroy_console_logger(logger)

	input: string = #load("./input.txt")
	defer delete(input)

	max_batteries := 2
	banks := parse_input(&input)
	defer {
		for bank in banks do delete(bank)
		delete(banks)
	}

	result := find_consecutive_largest_jolts(banks, 12)
	defer {
		for digits in result do delete(digits)
		delete(result)
	}
	acc := 0
	for digits in result {
		acc += combine_digits_into_int(digits[:])
	}

	log.info(len(result), result)

	log.info("Sum:", acc)
}

find_consecutive_largest_jolts :: proc (banks: [dynamic][dynamic]int, max_batteries: int) -> [dynamic][dynamic]int {
	result := make([dynamic][dynamic]int)

	for bank, bank_pos in banks {

		digits := make([dynamic]int)

		min_possible_pos := 0
		batteries_loop: for curr_battery in 1..=max_batteries {

			max_possible_pos := len(bank) - (max_batteries - curr_battery)
			for digit := 9; digit > 0; digit -= 1 {

				for joltage, index in bank[min_possible_pos:max_possible_pos] {
					if joltage == digit {
						inject_at(&digits, curr_battery - 1, joltage)
						min_possible_pos = min_possible_pos + index + 1

						continue batteries_loop
					}
				}
			}
		}

		inject_at(&result, bank_pos, digits)
	}

	return result
}

parse_input :: proc(input: ^string) -> [dynamic][dynamic]int {
	banks := make([dynamic][dynamic]int)

	raw_banks := strings.split_lines(input^)
	defer delete(raw_banks)
	for raw_bank, i in raw_banks {
		bank := make([dynamic]int)
		inject_at(&banks, i, bank)
		for joltage_rune, j in raw_bank {
			joltage_runes_arr := [?]rune{joltage_rune}
			joltage_str := utf8.runes_to_string(joltage_runes_arr[:])
			defer delete(joltage_str)
			joltage, ok := strconv.parse_int(joltage_str)
			inject_at(&banks[i], j, joltage)
		}
	}

	return banks
}

combine_digits_into_int :: proc(digits: []int) -> (result: int) {
	length := len(digits)
	for digit, i in digits {
		multiplier := cast(int)math.pow_f64(10, cast(f64)(length - i - 1))
		result += multiplier * digit
	}
	return result
}

@(test)
combine_digits_into_int_test :: proc(t: ^testing.T) {
	input := [?]int{9, 8}
	testing.expect_value(t, combine_digits_into_int(input[:]), 98)

	input_2 := [?]int{1, 2, 3, 4, 5, 6}
	testing.expect_value(t, combine_digits_into_int(input_2[:]), 123456)
}

@(test)
parse_input_test :: proc(t: ^testing.T) {
	input := "123123123\n222224222"

	banks := parse_input(&input)
	defer {
		for bank in banks do delete(bank)
		delete(banks)
	}

	expected := [?][9]int{
		{1, 2, 3, 1, 2, 3, 1, 2, 3},
		{2, 2, 2, 2, 2, 4, 2, 2, 2}
	}

	for bank, i in banks {
		for joltage, j in bank {
			testing.expect(t, expected[i][j] == joltage)
		}
	}
}

@(test)
sample_test :: proc(t: ^testing.T) {
	input: string = #load("./sample.txt")

	max_batteries := 2
	banks := parse_input(&input)
	defer {
		for bank in banks do delete(bank)
		delete(banks)
	}

	result := find_consecutive_largest_jolts(banks, 2)
	defer {
		for digits in result do delete(digits)
		delete(result)
	}
	acc := 0
	for digits in result {
		acc += combine_digits_into_int(digits[:])
	}

	testing.expect_value(t, acc, 357)
}

@(test)
sample_test_part2 :: proc(t: ^testing.T) {
	input: string = #load("./sample.txt")

	max_batteries := 12
	banks := parse_input(&input)
	defer {
		for bank in banks do delete(bank)
		delete(banks)
	}

	result := find_consecutive_largest_jolts(banks, 12)
	log.info(result)
	defer {
		for digits in result do delete(digits)
		delete(result)
	}
	acc := 0
	for digits in result {
		acc += combine_digits_into_int(digits[:])
	}

	testing.expect_value(t, acc, 3121910778619)
}

