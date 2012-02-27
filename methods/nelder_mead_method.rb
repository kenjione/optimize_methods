require File.dirname(__FILE__)+"/calc_func.rb"


class Point
  attr_accessor :x, :y

  def initialize(x0)
    @x = Array.new(x0)
    @y = self.calc
  end

  def self.setfunc(func)
    @@func = func
  end

  def calc
    call_userfunc(@@func, @x)
  end
end

class NelderMeadMethod
  attr_accessor :points, :draw_points, :alpha, :beta, :gamma, :func , :y_res

  def self.find_extremum(params)
    Point.setfunc(params[:function].to_s)
    p1 = Point.new([params[:x0_1].to_f, params[:x0_2].to_f])
    p2 = Point.new([params[:x1_1].to_f, params[:x1_2].to_f])
    p3 = Point.new([params[:x2_1].to_f, params[:x2_2].to_f])
    new(params[:function].to_s, [p1,p2,p3], params[:alpha].to_f, params[:beta].to_f, params[:gamma].to_f)
  end

  def initialize(func, points, alpha, beta, gamma)
    @points = Array.new(points)
    @func = func
    @draw_points = Array.new()
    @draw_points.push([@points[0].x.dup, @points[1].x.dup, @points[2].x.dup] )
    @alpha = alpha
    @beta = beta
    @gamma = gamma
    self.center
  end

  def sort
    @points.sort! { |a, b| a.y <=> b.y }
  end

  def center
    x_center = Array.new([0.0,0.0])
    self.sort
    for i in 0..1 do
      x_center[i] = (@points[0].x[i] + @points[1].x[i])/(2.0)
    end
    f_c = call_userfunc(@func, x_center)
    sum = 0.0
    @points.each { |p|
      sum+= ((p.calc - f_c)**2)
    }
    if Math.sqrt(sum/3.0) < 0.0001 then
      @y_res = @points[0].calc
      return
    end
    point_r = Point.new([0.0, 0.0])
    self.reflection(point_r, x_center)
  end

  def reflection(point_r, x_center)
    for i in 0..1 do
      point_r.x[i] = x_center[i] + @alpha*(x_center[i] - @points[2].x[i]) #(1+@alpha)*x_center[i] - @alpha*@points[2].x[i]
    end
    point_r.y = point_r.calc
    self.explore(point_r, x_center)
  end

  def explore(point_r, x_center)

    point_e = Point.new([0.0,0.0])
    if point_r.y <= @points[0].y then

      for i in 0..1 do
        point_e.x[i] = (1-@gamma)*x_center[i] + @gamma*point_r.x[i]
      end
      point_e.y = point_e.calc

      if point_e.y < @points[0].y then
        @points[2] = Point.new(point_e.x)
      else
        @points[2] = Point.new(point_r.x)
      end

      @draw_points.push([@points[0].x.dup, @points[1].x.dup, @points[2].x.dup] )
      self.center
      return
    end

    if @points[1].y < point_r.y and point_r.y <= @points[2].y then

      for i in 0..1 do
        point_r.x[i] = x_center[i] + @beta*(@points[2].x[i] - x_center[i])
      end

      point_r, @points[2] = @points[2], point_r
      @draw_points.push([@points[0].x.dup, @points[1].x.dup, @points[2].x.dup] )
      self.center
	    return
    end


    if @points[0].y < point_r.y and point_r.y <= @points[1].y then
      @points[2] = Point.new(point_r.x)
      @draw_points.push([@points[0].x.dup, @points[1].x.dup, @points[2].x.dup] )
      self.center
      return
    end



    if @points[2].y < point_r.y then
      self.sort
      @points[1].x[0] = @points[0].x[0] + (@points[1].x[0] - @points[0].x[0] )/2.0
      @points[1].x[1] = @points[0].x[1] + (@points[1].x[1] - @points[0].x[1] )/2.0
      @points[2].x[0] = @points[0].x[0] + (@points[2].x[0] - @points[0].x[0] )/2.0
      @points[2].x[1] = @points[0].x[1] + (@points[2].x[1] - @points[0].x[1] )/2.0
      self.center
	    return
    end
	return
  end
end