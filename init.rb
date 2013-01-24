#! /usr/bin/env ruby

require './scale'

get '/*' do
  cross_origin
  @scale = Scale.new
  begin
    weight = @scale.get_weight
    @scale.teardown
  rescue
    halt 500
  end
  content_type :json
  {
    weight: weight
  }.to_json
end

