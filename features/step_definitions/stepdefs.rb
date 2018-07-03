module CucumberStepHelper
  def is_it_cucumberday?(day)
    'No way!'
  end
end
World CucumberStepHelper

Given("today is Sunday") do
  @today = 'Sunday'
end

When("I ask whether it's Cucumber day yet") do
  @actual_answer = is_it_cucumberday?(@today)
end

Then("I should be told {string}") do |expected_answer|
  expect(@actual_answer).to eq(expected_answer)
end