CHARS_TO_ESCAPE = %w(` ~ ! @ # $ % ^ & * ( ) - _ = + { } [ ] \\ | ; : ' " , . < > / ?)
ESCAPE_REGEXP = Regexp.new "(\\#{CHARS_TO_ESCAPE.join("|\\")})"
puts ARGV[0].to_s.gsub(ESCAPE_REGEXP, '\\\\\1')