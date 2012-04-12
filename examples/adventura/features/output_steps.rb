When /^output is truncated$/ do
  truncate_stdout
end

Then /^(?:I should )?see "(.+?)"$/ do |text|
  step %Q(the output should contain "#{text}")
end

Then /^(?:I should )?see:$/ do |text|
  step "the output should contain:", text
end

Then /^type "(.+?)"$/ do |text|
  step %Q(I type "#{text}")
end
