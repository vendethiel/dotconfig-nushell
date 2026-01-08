# @yliaster. https://discord.com/channels/601130461678272522/615253963645911060/1458159022845988946
# Interactively select a date from a calendar widget.
# 
# Use arrow keys to navigate, enter to return the selected date, and escape to exit without returning a date.
export def "input date" [
  --start-date: datetime # Initial date to start the cursor on
] {
  print -n (ansi cursor_off)

  mut cursor = $start_date | default {date now}
  mut draw = true
  mut out: any = null
  mut home = (
    term query (ansi cursor_position) --prefix (ansi csi) --terminator R
    | decode
    | split row ';'
    | into int
    | {x: $in.1 y: $in.0}
  )

  loop {
    let c = $cursor | into record

    if $draw {
      let cal = (
        cal --full-year $c.year --month --year --as-table
        | where month == $c.month
        | update cells -c [su mo tu we th fr sa] {
          let cell = $in | to text | ansi strip
          let color = if $cell == $"($c.day)" {ansi wr} else {""}
          $color + $cell + (ansi reset)
        }
      )

      let height = ($cal | table | lines | length)
      let rows = (term size).rows
      if ($home.y + $height) > $rows {
        $home.y = $rows - $height
      }

      print $cal
      print -n $cursor
      $draw = false
    }

    match (input listen --types [key]).code {
      up => { $cursor -= 7day; $draw = true }
      down => { $cursor += 7day; $draw = true }
      left => { $cursor -= 1day; $draw = true }
      right => { $cursor += 1day; $draw = true }
      enter => { $out = $cursor; break }
      esc => { $out = null; break }
    }

    if $draw {
      print -n (ansi --escape $"($home.y);($home.x)H")
      print -n (ansi clear_screen_from_cursor_to_end)
    }
  }

  print -n (ansi --escape $"($home.x)G")
  print -n (ansi erase_line_from_cursor_to_end)
  print -n (ansi cursor_on)
  $out
}


