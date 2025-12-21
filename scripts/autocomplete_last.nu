# @maxim_uvarov https://discord.com/channels/601130461678272522/615253963645911060/1412981516514103379
export-env {
  $env.config.keybindings ++= [
    {
      name: pipe_completions_menu
      modifier: shift_alt
      keycode: char_s
      mode: emacs
      event: {send: menu name: pipe_completions_menu}
    }
  ]
  $env.config.menus ++= [
    {
      # session menu
      name: pipe_completions_menu
      only_buffer_difference: false # Search is done on the text written after activating the menu
      marker: "# "
      type: { layout: list page_size: 25 }
      style: { text: green selected_text: green_reverse description_text: yellow }
      source: {|buffer position|
        let last_segment = $buffer | split row -r '(\s\|\s)|\(|;|(\{\|\w\| )' | last
        let last_segment_length = $last_segment | str length

        let last_segment_escaped = '\.^$*+?{}()[]|/' | split chars # regex special symbols
        | reduce -f $last_segment {|i| str replace -a $i $'\($i)' }

        history
        | get command
        | uniq
        | where $it =~ $last_segment_escaped
        | str replace -a (char nl) ' ' # might cause troubles?
        | str replace -r $'.*($last_segment_escaped)' $last_segment
        | reverse
        | uniq
        | each {|it| { value: $it span: { start: ($position - $last_segment_length) end: ($position) } } }
      }
    }
  ]
}
