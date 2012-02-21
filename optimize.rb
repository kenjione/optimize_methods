require 'sinatra'
require 'active_support/inflector'
require File.dirname(__FILE__)+"/methods/drawplot.rb"
require File.dirname(__FILE__)+"/methods/base_optimize_method"

BaseOptimizeMethod.require_methods

helpers do
  def link_to(name, path, options = {})
    params = options.map { |k, v| %|#{k}="#{v}"| }.join
    params = ' ' + params unless params == ''
    %|<a href="#{path}"#{params}>#{name}</a>|
  end

  def print_float(float, acc = 3)
    "%.#{acc}f" % float
  end
end

get '/' do
	erb :index
end

get '/:name' do |name|
    erb :"#{name}/form"
end

post '/:name' do |name|
  result = name.camelize.constantize.find_extremum(params)
  drawplot(result.draw_points, name.to_s)
  drawfunc(result.func)
  erb :"/#{name}/handler", locals: {params: params, result: result}
end
