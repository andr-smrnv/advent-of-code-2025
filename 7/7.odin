package main

import "core:slice"
import "core:strconv"
import "core:strings"
import "core:log"
import sa "core:container/small_array"

main :: proc() {
	logger := log.create_console_logger()
	context.logger = logger
	defer log.destroy_console_logger(logger)

	input: string = #load("./sample.txt")
	defer delete(input)

	part1(&input)

}

part1 :: proc(input: ^string) {
	lines := strings.split_lines(input^)

	initial_pos := [2]int { 0, strings.index(lines[0], "S") }

	back_buf, ray_origins: sa.Small_Array(254, [2]int)
	sa.push(&ray_origins, initial_pos)

	splitters_hits := make(map[[2]int]int)
	defer delete(splitters_hits)

	split_count := 0
	for {
		log.info("Checking rays", sa.slice(&ray_origins))
		for ray_pos in sa.slice(&ray_origins) {
			curr := ray_pos + {1, 0}
			for {
				if curr[0] == len(lines) do break // out of bounds

				if lines[curr[0]][curr[1]] == '^' {
					sa.push(&back_buf, curr + {0, 1}, curr + {0, -1})
					splitters_hits[curr] += 1
					split_count += 1
					break
				} else {
					curr += {1, 0}
				}
			}
		}

		dedup_points(&back_buf)

		if sa.len(back_buf) == 0 {
			break
		}

		ray_origins = back_buf
		sa.clear(&back_buf)
	}

	log.info(split_count, len(splitters_hits))
}



dedup_points :: proc(a: ^sa.Small_Array($N, [2]int)) {
    pts := sa.slice(a)

    slice.sort_by(pts, proc(p, q: [2]int) -> bool {
        if p[0] < q[0] do return true
        if p[0] > q[0] do return false
        return p[1] < q[1]
    })

    pts = slice.unique_proc(pts, proc(p, q: [2]int) -> bool {
        return p == q
    })

    sa.resize(a, len(pts))
}
