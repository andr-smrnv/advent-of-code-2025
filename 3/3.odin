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

	banks := strings.split_lines(input)
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

	result: sa.Small_Array(1000, [2]int)

	for bank, bank_pos in banks {
		log.info("BANK #", bank_pos, bank)

		sa.inject_at(&result, [2]int{}, bank_pos)

		min_possible_pos := 0
		batteries_loop: for curr_battery in 1..=max_batteries {
			log.info("Finding battery #", curr_battery, "out of", max_batteries)

			max_possible_pos := len(bank) - (max_batteries - curr_battery)

			for digit := 9; digit > 0; digit -= 1 {
				log.info("> finding digit", digit, "in", bank[min_possible_pos:max_possible_pos])

				#reverse for joltage, index in bank[min_possible_pos:max_possible_pos] {
					if joltage == digit {
						log.info("> found match at pos", index)
						ints := sa.get(result, bank_pos)
						ints[curr_battery - 1] = joltage
						sa.inject_at(&result, ints, bank_pos)
						min_possible_pos = index + 1

						continue batteries_loop
					}
				}
			}
		}

		log.info("> Max possible value for", bank, "is", sa.get(result, bank_pos))
	}

	acc := 0
	for i := 0; i < len(banks); i += 1 {
		digits := sa.get(result, i)
		acc += combine_digits_into_int(digits[:])
	}



	testing.expect_value(t, acc, 357)
}


