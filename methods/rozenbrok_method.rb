require "matrix"
require File.dirname(__FILE__)+"/calc_func.rb"

class RozenbrokMethod
  attr_accessor :func, :x, :y, :x_res, :draw_points, :y_res

  def self.find_extremum(params)
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
    @x.push(x0.dup)  #x_start my
    @draw_points.push(@x[0])
    @y = [Matrix[*@x].transpose, Matrix[*@x].transpose, Matrix[*@x].transpose]
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
    call_userfunc(@func, arg)
  end

  def reset_dx
    @dx = [0.1,0.1]
  end

  def step_2(i)

    if (self.calc(@y[i] + @dx[i]*@d[i])) < self.calc(@y[i])
      @y[i+1] = (@y[i] + @dx[i]*@d[i])
      @dx[i] = @alpha*@dx[i]
      @draw_points.push(@y[i+1].transpose.to_a[-1])
    else
      @y[i+1] = @y[i]
      @dx[i] = @beta*@dx[i]
    end
    self.step_3
    return
  end

  def step_3
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
        if self.calc(@y[@n+1]) < self.calc(@x[@k])
          self.step_4
          return
        end

        if self.calc(@y[@n+1]) == self.calc(@x[@k])
          if @shitstep <= @N

            @dx.each { |delta|
              if delta.abs > @eps then
                @y[0] = @y[@n+1]
                @i = 0
                self.step_2(@i)
                return
              end
            }
            @x_res = Array.new(@x[@k])
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
      puts @draw_points[-1].inspect
      @y_res = calc(@draw_points[-1])
      return
    else
      @lambda = Matrix[[@x[-1][0] - @x[-2][0]],[@x[-1][1] - @x[-2][1]]]
      a = Matrix[[@lambda[0,0]*@d[0] + @lambda[1,0]*@d[1]],[@lambda[1,0]*@d[1]]]

      b1 = a[0,0]
      d1 = b1/(Math.sqrt(b1[0,0]**2 + b1[1,0]**2))

      b2 = a[1,0] - (a[1,0].transpose*d1)[0,0]*d1
      d2 = b2/(Math.sqrt(b2[0,0]**2 + b2[1,0]**2))

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
    Math.sqrt(sum)
  end
end
