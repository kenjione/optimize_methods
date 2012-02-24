include Math
def call_userfunc(userfunc_str, args)
  #puts args.inspect
	if args.is_a?(Array)
		variables = (('x'..'z').to_a + ('a'...'x').to_a).join(', ')
		eval("#{variables} = *args\n" + userfunc_str)
	elsif args.is_a?(Hash)
		vars, values = args.to_a.transpose.map { |arr| arr.join(', ') }
		eval("#{vars} = #{values}\n" + userfunc_str)
	elsif args.is_a?(String)
		eval("#{args}\n" + userfunc_str)
	else
		raise ArgumentError, "Invalid two argument type"
	end
end

=begin
# теперь можно так:
for i in 2..5
	puts call_userfunc("4 * a * a + 3.14 * Math.sqrt(b) - c", [2, i, 1])
end

# или так:
for i in 2..5
	puts call_userfunc("4 * a * a + 3.14 * Math.sqrt(b) - c", {:a => 2, :b => i, :c => 1})
end

# и даже со стрингой:
for i in 2..5
  puts call_userfunc("4 * a * a + 3.14 * Math.sqrt(b) - c", "a, b, c = 2, #{i}, 1")
end
=end
