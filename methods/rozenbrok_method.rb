require "matrix"
require File.dirname(__FILE__)+"/base_optimize_method.rb"
require File.dirname(__FILE__)+"/calc_func.rb"
require "sinatra"

#$func = "4*(a-5)**2 + (b-6)**2"

class RozenbrokMethod < BaseOptimizeMethod
  attr_accessor :func, :x, :d, :alpha, :beta, :eps, :i, :y, :dx, :N, :k, :n, :shitstep, :lambda, :x_res, :a, :draw_points

  def self.find_extremum(params)

    puts params.inspect
    new([params[:x1].to_f, params[:x2].to_f], params[:function].to_s, params[:alpha].to_f, params[:beta].to_f, params[:epsilon].to_f)

  end

  def initialize(x0, func, alpha, beta, eps)
    @func = func
    @alpha = alpha
    @beta = beta
    @eps = eps
    @i = 0
    @shitstep = 0
    @x = Array.new
    @d = [Matrix[[1.0],[0.0]], Matrix[[0.0],[1.0]]]
    @draw_points = Array.new

    #@x.push([1.0, 0.5])  #x_start renat
    #@x.push([10.0, 11.5])  #x_start toxa
    #@x.push([10.0, 11.5])  #x_start serg
    @x.push(x0.dup)  #x_start my

    @draw_points.push(@x[0])


    @y = [Matrix[*@x].transpose, Matrix[*@x].transpose, Matrix[*@x].transpose]
    #puts "y init = " + @y.inspect
    @x_res = Array.new

    @dx = [1.0,2.0]
    @N = 3
    @n = 1
    @k = 0
    self.step_2(@i)
  end

  def calc(arg)
    if arg.is_a?(Matrix)
      arg = arg.transpose.to_a[-1]
    end

    #call_userfunc("-(3*a*b - 5*(a**2) - 5*(b**2))", arg)   #my
    #call_userfunc("-(a*a*b*(5-2*a - 3*b))", arg) #renat
    #call_userfunc("10*(a*a-6)**2+50*(b-8)**2", arg) #toxa
    #call_userfunc("2*(a**4) + 2*(b**2) - 64*a - 64*b", arg) #serg
    #call_userfunc("2*(a)**2 + a*b + (b)**2",arg)   #rozenbrok
    call_userfunc(@func, arg)
  end

  def reset_dx
    @dx = [0.1,0.1]
  end

  def step_2(i)
    puts "--------"
    puts "call step_2(): "

    puts "d = " + @d[i].inspect
    puts "dx = " + @dx[i].inspect
    puts "dx*d = " + (@dx[i]*@d[i]).inspect
    puts "y + dd = " + (@y[i] + @dx[i]*@d[i]).inspect
    puts "f(y+dd) = " + self.calc(@y[i] + @dx[i]*@d[i]).inspect
    puts "f(y) = " + self.calc(@y[i]).inspect
    puts "delta  = "  + @dx.inspect


    if (self.calc(@y[i] + @dx[i]*@d[i])) < self.calc(@y[i])
      @y[i+1] = (@y[i] + @dx[i]*@d[i])
      @dx[i] = @alpha*@dx[i]
      @draw_points.push(@y[i+1].transpose.to_a[-1])
    else
      #puts "..step is shit"
      @y[i+1] = @y[i]
      @dx[i] = @beta*@dx[i]
    end

    puts "y(after calc) = " + @y.inspect
    puts "delta(after calc)  = "  + @dx.inspect



    puts "--------"

    self.step_3
    return
  end

  def step_3
    puts "--------"
    puts "call step_3(): "
    if @i < @n
      @i+=1
      self.step_2(@i)
      return
    else

      if self.calc(@y[@n+1]) < self.calc(@y[0])
        @y[0] = y[@n+1]
        @i = 0
        self.step_2(@i)
        return
      end

      if self.calc(@y[@n+1]) == self.calc(@y[0])
        @shitstep+=1
        puts "bad step  = " + @shitstep.inspect
        if self.calc(@y[@n+1]) < self.calc(@x[@k])
          self.step_4
          return
        end

        if self.calc(@y[@n+1]) == self.calc(@x[@k])
          if @shitstep <= @N

            @dx.each { |delta|
              puts "delta = " + delta.inspect
              if delta.abs > @eps then
                @y[0] = @y[@n+1]
                @i = 0
                self.step_2(@i)
                return
              end
            }
            puts "RESULT: " + (@x_res = Array.new(@x[@k])).inspect
            return
          else
            self.step_4
            return
          end
        end
      end

    end
  end

  def step_4
    @x.push(@y[@n+1].transpose.to_a[-1])

    if self.norm <= @eps then
      @x_res = @x[-1]
      return
    else
      puts "calc lambda"
      @lambda = Matrix[[@x[-1][0] - @x[-2][0]],[@x[-1][1] - @x[-2][1]]]


      a = Matrix[[@lambda[0,0]*@d[0] + @lambda[1,0]*@d[1]],[@lambda[1,0]*@d[1]]]
      puts "a = " +  a.to_s

      puts "b1 = " + (b1 = a[0,0]).inspect
      puts "d1 = " + (d1 = b1/(Math.sqrt(b1[0,0]**2 + b1[1,0]**2))).inspect

      puts "b2 = " + (b2 = a[1,0] - (a[1,0].transpose*d1)[0,0]*d1).inspect
      puts "d2 = " + (d2 = b2/(Math.sqrt(b2[0,0]**2 + b2[1,0]**2))).inspect

      @d[0] = d1
      @d[1] = d2

      @k+=1
      @shitstep = 0
      self.reset_dx
      #puts "x[-1] = " + Matrix[[*@x[-1]]].transpose.inspect
      @y[0] = Matrix[[*@x[-1]]].transpose
      @i = 0
      self.step_2(@i)
      return
    end

  end

  def norm
    sum = 0.0
    for i in 0..1
      sum += ((@x[-1][i] - @x[-2][i])**2)
    end

    puts "-------------"
    puts "f(x) = " + calc(@x[-1]).to_s
    puts "x = "  + @x.inspect
    puts "norm = " + Math.sqrt(sum).to_s
    puts "-------------"
    puts @draw_points.inspect
    Math.sqrt(sum)

  end

end

#
#example = RozenbrokMethod.new([8.0, 9.0], 2, -0.5, 0.6)
#puts example.x_res.inspect
#
#
#a = [[],[]]
#example.draw_x.each do |arr|
#    a[0].push(arr[0])
#    a[1].push(arr[1])
#end
#
#Gnuplot.open do |gp|
#  Gnuplot::Plot.new( gp ) do |plot|
#
#    plot.xrange "[0:10]"
#    plot.title  "RozenbrokMethod"
#    plot.ylabel "x2"
#    plot.xlabel "x1"
#
#    plot.data = [
#      Gnuplot::DataSet.new( [a[0],a[1]] ) { |ds|
#        ds.with = "linespoints"
#        ds.title = "x"
#    	  #ds.linewidth = 4
#      }
#    ]
#  end
#end