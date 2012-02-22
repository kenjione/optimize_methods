require "active_support/inflector"
require "sinatra"

class BaseOptimizeMethod

  def self.require_methods
    methods_files = methods_file_list
    #puts methods_files.inspect
    methods_files.each { |method| require File.dirname(__FILE__) + '/' + method }
	#Dir.chdir("../")
    #
    #methods_classes = methods_files.map { |filename| filename.sub('.rb', '').camelize.constantize }

    #puts methods_classes.inspect
    #
    #methods_classes.each do |method_class|
    #  method_class.build_get_route
    #  method_class.build_post_route(params)
    #end
  end

  protected

  def self.build_get_route
    erb "#{underscore_name}/form"
  end

  def self.build_post_route(params)
    result = find_extremum(params)
    erb :"#{underscore_name}/handler", locals: {params: params, result: result}
  end


  private
  def self.underscore_name
    self.to_s.underscore
  end

  def self.methods_file_list
    #Dir.chdir(File.dirname(__FILE__))
    Dir["#{File.dirname(__FILE__)}/*_method.rb"].map { |file_name| File.basename(file_name) } - [File.basename(__FILE__)]
  end
end
