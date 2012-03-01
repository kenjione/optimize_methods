require File.dirname(__FILE__)+"/calc_func.rb"


class PowellMethod
  attr_accessor  :x , :draw_points, :func, :y , :y_res
  def self.find_extremum(params)
    new([params[:x1].to_f,params[:x2].to_f], params[:function], params[:eps].to_f)
  end
  def initialize(x0,func,eps)
    @func = func
    @eps = eps #0.00001
    @d = [[1.0, 0.0],[0.0, 1.0],[1.0, 0.0]]
    @x = Array.new.push(x0)
    @y = Array.new.push(x0)
    @draw_points = Array.new
    @draw_points.push(x0)
    self.step_2
  end

  def calc(x)
    call_userfunc(@func, x)
  end

  def step_2

    for i in 0..2
      @y[i+1] = (  [@y[-1][0]  +  self.minimize(@y[-1],@d[i])*@d[i][0] , @y[-1][1] + self.minimize(@y[-1],@d[i]) * @d[i][1]])
      @draw_points.push(@y[i+1].dup)
    end
    self.step_4
  end

  def step_4
    @x.push(@y[-1])
    norm = Math.sqrt((@x[-1][0] - @x[-2][0])**2 + (@x[-1][1] - @x[-2][1])**2)
    if norm < @eps then
      @y_res = calc(@y[-1])
    else
      temp_d2 = Array.new(@d[2])
      for i in 0..1
        @d[0][i] = @d[2][i] = (@y[3][i] - @y[1][i] )
        @d[1][i] = temp_d2[i]
      end
      self.step_2
    end
  end

  def minimize(y,d)
    t0 = 0
    h = 10.0
    min = self.calc([y[0] + d[0]*t0, y[1] + d[1]*t0])

    begin
      if self.calc([y[0] + d[0]*(t0+h), y[1] + d[1]*(t0+h)]) < min then
        min = self.calc([y[0] + d[0]*(t0+h), y[1] + d[1]*(t0+h)])
        t0+=h
      else
        if self.calc([y[0] + d[0]*(t0-h), y[1] + d[1]*(t0-h)]) < min then
          min = self.calc([y[0] + d[0]*(t0-h), y[1] + d[1]*(t0-h)])
          t0-=h
      else
        h/=2
      end
      end
    end while h > 0.001
    return t0
  end

end