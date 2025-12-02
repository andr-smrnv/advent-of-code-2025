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
	delimiters := [?]string{"   ", "\r\n"}

	lines := strings.split_lines(input)

	stopped, crossed := count_zeroes(&lines)

	log.info(stopped + crossed)
}

count_zeroes :: proc(lines: ^[]string) -> (stopped: int, crossed: int) {
	current := 50
	upper := 100

	for line in lines {
		letter := rune(line[0])
		direction : int
		if letter == 'L' {
			direction = -1
		} else {
			direction = 1
		}

		clicks, ok := strconv.parse_int(line[1:])

		revolutions := math.abs(clicks / upper)
		log.info(current, line, clicks)
		log.info(">>", "crossed 0 (extra revolutions)", revolutions)

		crossed += revolutions
		clicks = clicks - revolutions * upper
		log.info("clicks after", clicks)
		unwrapped := current + clicks * direction
		if current != 0 && (unwrapped > upper || unwrapped < 0) {
			log.info(">>", "crossed 0")
			crossed += 1
		}

		current = ((unwrapped % upper) + upper) % upper

		if current == 0 {
			log.info(">>", "stopped 0")
			stopped += 1
		}

		log.info(">>", "now points to", current)
	}

	return stopped, crossed
}


@(test)
first_part :: proc(t: ^testing.T) {
	input: string = #load("./sample.txt")
	delimiters := [?]string{"   ", "\r\n"}

	lines := strings.split_lines(input)
	defer delete(lines)

	stopped, _ := count_zeroes(&lines)
	testing.expect_value(t, stopped, 3)
}

@(test)
second_part :: proc(t: ^testing.T) {
	input: string = #load("./sample.txt")
	delimiters := [?]string{"   ", "\r\n"}

	lines := strings.split_lines(input)
	defer delete(lines)

	stopped, crossed := count_zeroes(&lines)

	testing.expect_value(t, stopped + crossed, 6)
}

@(test)
extra_right_revolutions :: proc(t: ^testing.T) {
	lines := []string{
		"R1000",
	}

	stopped, crossed := count_zeroes(&lines)

	testing.expect_value(t, stopped + crossed, 10)
}

@(test)
extra_left_revolutions :: proc(t: ^testing.T) {
	lines := []string{
		"L1000",
	}

	stopped, crossed := count_zeroes(&lines)

	testing.expect_value(t, stopped + crossed, 10)
}
