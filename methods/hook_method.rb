require File.dirname(__FILE__)+"/calc_func.rb"
#require "rubygems"


#$func = "-(3*a*b - 5*(a**2) - 5*(b**2))"
#$func = "2*a*a + a*b + b*b"
#$func = "4*(a-5)**2 + (b-6)**2"


class HookMethod

  attr_accessor :draw_points, :x, :func, :y

  def self.find_extremum(params)
    new(params[:function].to_s, [params[:x1].to_f,params[:x2].to_f], params[:eps].to_f, params[:lambda].to_f, params[:alpha].to_f, params[:step1].to_f, params[:step2].to_f)
  end

  def initialize(func,x0, eps, lambda, alpha, step1, step2)
    @func = func
    @x = Array.new.push(x0)
    @eps = eps    #0.3
    @lambda = lambda #1.0
    @alpha = alpha #2.0
    @d = [[1.0, 0.0], [0.0, 1.0]]
    @step = [step1, step2] #[1.0, 2.0]
    @y = [x0.dup,x0.dup,x0.dup]
    @draw_points  = Array.new
    @draw_points.push(x0.dup)

    puts "-------------------- ZALUPA"
    puts self.inspect

    step_2
  end

  def calc(x)
    call_userfunc(@func, x)
  end

  def step_2 #explore

    @draw_points.push(@y[0].dup)
    for i in 0..1
      if calc([@y[i][0] + @step[0]*@d[i][0], @y[i][1] + @step[1]*@d[i][1]]) < calc(@y[i])
        puts calc([@y[i][0] + @step[0]*@d[i][0], @y[i][1] + @step[1]*@d[i][1]]).inspect + "<" + calc(@y[i]).inspect
        puts "nice step"
        @y[i+1][0] = @y[i][0] + @step[0]*@d[i][0]
        @y[i+1][1] = @y[i][1] + @step[1]*@d[i][1]
      else  if calc([@y[i][0] - @step[0]*@d[i][0], @y[i][1] - @step[1]*@d[i][1]]) < calc(@y[i])
        puts calc([@y[i][0] - @step[0]*@d[i][0], @y[i][1] - @step[1]*@d[i][1]]).inspect + "<" + calc(@y[i]).inspect
          puts "nice step"
          @y[i+1][0] = @y[i][0] - @step[0]*@d[i][0]
          @y[i+1][1] = @y[i][1] - @step[1]*@d[i][1]
        else
          "step is bad"
           @y[i+1][0] = @y[i][0]
           @y[i+1][1] = @y[i][1]
        end
      end
      @draw_points.push(@y[i+1].dup)
    end

    if calc(@y[-1]) < calc(@x[-1])
      #step_4

      puts "step4 by example:"
      puts calc(@y[-1]).inspect + "<" + calc(@x[-1]).inspect

      @x.push(@y[-1].dup)

      for k in 0..1
        @y[0][k] = @x[-1][k] + @lambda*(@x[-1][k] - @x[-2][k])
      end

      #@draw.push(@y[0].dup)

      step_2
    else
      if @step[0] < @eps and @step[1] < @eps
        puts "awesome!"
        puts @x[-1].inspect
      else
        @step[0] /= @alpha
        @step[1] /= @alpha
        @y[0] = @x[-1].dup
        @x.push(@x[-1].dup)
        #@draw.push(@y[0].dup)
        step_2
      end
    end
  end
end

#<Hook:0x8a133c8 @func="a**2+b**2", @x=[[8.0, 9.0]], @eps=0.3, @lambda=1.0, @alpha=2.0, @d=[[1.0, 0.0], [0.0, 1.0]], @step=[1.0, 2.0], @y=[[8.0, 9.0], [8.0, 9.0], [8.0, 9.0]], @draw_points=[[8.0, 9.0]]>
#<HookMethod:0x924819c @func="a**2 + b**2", @x=[[8.0, 9.0]], @eps=0.3, @lambda=0.0, @alpha=2.0, @d=[[1.0, 0.0], [0.0, 1.0]], @step=[1.0, 2.0], @y=[[8.0, 9.0], [8.0, 9.0], [8.0, 9.0]], @draw_points=[[8.0, 9.0]]>