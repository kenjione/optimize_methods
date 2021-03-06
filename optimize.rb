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

  def render_output_form(result, params)
    erb(:output_form, locals: {result: result, params: params})
  end

  def render_input_function_form(func="x**2 + y**2 - 2 * x * sin(y) - 3 * sin(x) * y")
    erb :input_function_form, locals: {func: func}
  end
end

get '/' do
	erb :index
end

get '/:name' do |name|
    erb :"#{name}/form"
end

post '/:name' do |name|

  params[:function] = params[:opt_type].to_s + "*(" + params[:function].to_s + ")"
  params[:opt_type]= params[:opt_type].to_f
  params[:opt_type] == -1.0 ? params[:extremum] = "Max" : params[:extremum] = "Min"

   begin
    timeout(2) do
      result = name.camelize.constantize.find_extremum(params)
      drawplot(result.draw_points, name.to_s)
      drawfunc(result.func[4...-1])
      erb :"/#{name}/handler", locals: {params: params, result: result}
    end

  rescue TimeoutError => err
    #puts err.message
    erb :error, locals: {err: err}

  rescue Exception => err
    #puts err.message
    erb :error, locals: {err: err}

  end
end
