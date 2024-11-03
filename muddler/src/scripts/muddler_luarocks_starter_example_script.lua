-- define muddler_luarocks_starter_example_script() for use as an event handler
function muddler_luarocks_starter_example_script(event, ...)
  echo("Received event " .. event .. " with arguments:\n")
  display(...)
end
