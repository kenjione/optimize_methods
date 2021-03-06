require 'gnuplot'

def drawplot(drawpoints, name)
	a = [[],[]]
	if drawpoints[0].size < 3 then 

		drawpoints.each do |arr|
			a[0].push(arr[0])
			a[1].push(arr[1])
		end	

	else
		drawpoints.each do |arr|
		  arr.each do |pnt|
        a[0].push(pnt[0])
        a[1].push(pnt[1])
		  end
		  a[0].push(arr[0][0])
		  a[1].push(arr[0][1])
		end
	end

	path = File.dirname(__FILE__) + "/../public/#{name}.png"

	Gnuplot.open do |gp|
	  Gnuplot::Plot.new( gp ) do |plot|

		plot.output path
		plot.terminal 'png truecolor'
		plot.grid
		plot.xrange "[" + (a[0].min-1).to_s +  ":" + (a[0].max+1).to_s + "]"
		plot.yrange "[" + (a[1].min-1).to_s +  ":" + (a[1].max+1).to_s + "]"
    plot.obj "1 rectangle behind from screen 0,0 to screen 1,1 fillstyle solid 0.25 fillcolor rgb 'gray'"
		plot.title  "#{name}"
		plot.ylabel "x2"
		plot.xlabel "x1"

		plot.data = [
		  Gnuplot::DataSet.new( [a[0],a[1]] ) { |ds|
		ds.with = "linespoints"
			  #ds.linewidth = 4
		  }
		]
	  end
	end					
end

def drawfunc(func)
		
  path = File.dirname(__FILE__) + "/../public/function.png"

	Gnuplot.open do |gp|
	  Gnuplot::SPlot.new( gp ) do |plot|

		plot.output path
		plot.terminal 'png truecolor transparent xffffff'
		plot.grid
    plot.obj "1 rectangle behind from screen 0,0 to screen 1,1 fillstyle solid 0.25 fillcolor rgb 'gray'"
    #plot.obj '1 fillstyle solid 0.0 rgbcolor "black"'
		plot.ylabel "x2"
		plot.xlabel "x1"

		plot.data = [
      Gnuplot::DataSet.new(func.to_s) { |ds|
		    #ds.with = "linespoints"
        ds.with = "pm3d at b"
      },
		  Gnuplot::DataSet.new(func.to_s) { |ds|
		    ds.with = "linespoints notitle"
      }
		]
	  end
	end 	
	
end

