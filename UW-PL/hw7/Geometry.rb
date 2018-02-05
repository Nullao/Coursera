class GeometryExpression
  # do *not* change this class definition
  Epsilon = 0.00001
end
yy
class GeometryValue 
  # do *not* change methods in this class definition
  # you can add methods if you wish

  private
  # some helper methods that may be generally useful
  def real_close(r1,r2) 
      (r1 - r2).abs < GeometryExpression::Epsilon # 非常爽，是吧！
  end
  def real_close_point(x1,y1,x2,y2)  # 主要判断这两个坐标是不是非常靠近
      real_close(x1,x2) && real_close(y1,y2)
  end
  # two_points_to_line could return a Line or a VerticalLine
  def two_points_to_line(x1,y1,x2,y2) # 两个点构成线
      if real_close(x1,x2)
	VerticalLine.new x1
      else
	m = (y2 - y1).to_f / (x2 - x1)
	b = y1 - m * x1
	Line.new(m,b)
      end
  end

  public
  # we put this in this class so all subclasses can inherit it:
  # the intersection of self with a NoPoints is a NoPoints object
  def intersectNoPoints np # 求和Nopoint的交点
    np # could also have NoPoints.new here instead
  end

  # we put this in this class so all subclasses can inhert it:
  # the intersection of self with a LineSegment is computed by
  # first intersecting with the line containing the segment and then
  # calling the result's intersectWithSegmentAsLineResult with the segment

  def intersectLineSegment seg # 其实思路和SML文件中展现的是一样的，主要的思想是转化
    # 我们主要要求的是LineSegment和其他的东西的交点,根据转化的思想：
    # 线段和其他东西相交的结果，可以转化为线和其他东西相交的结果
    # 两者是等价的，正如你在SML文件中所看到的
    # 首先将线段转化为线，然后求这个线和别的东西的相交结果
    line_result = intersect(two_points_to_line(seg.x1,seg.y1,seg.x2,seg.y2))
    # 仔细看上面的函数，其实可以转换为self.intersect(two_points_to_line(seg.x1,seg.y1,seg.x2,seg.y2))
    # 这里的self就相当于sml文件里面的v2
    # 去掉一层包裹之后，我们取a = two_points_to_line(seg.x1,seg.y1,seg.x2,seg.y2),然后会继续调用
    # a类中相应的函数来处理a类和self的关系(都会有结果),会得到相对应的结果line_result
    line_result.intersectWithSegmentAsLineResult seg
    # 然后调用line_result.intersectWithSegmentAsLineResult函数，这里值得注意的是，并没有调用intersect函数
    # 非常有意思
  end
end

class NoPoints < GeometryValue
  # do *not* change this class definition: everything is done for you
  # (although this is the easiest class, it shows what methods every subclass
  # of geometry values needs)

  # Note: no initialize method only because there is nothing it needs to do
  def eval_prog env 
    self # all values evaluate to self
  end
  def preprocess_prog
    self # no pre-processing to do here
  end
  def shift(dx,dy)
    self # shifting no-points is no-points
  end
  def intersect other
    other.intersectNoPoints self # will be NoPoints but follow double-dispatch
  end
  def intersectPoint p # 求和点的交点
    self # intersection with point and no-points is no-points
  end
  def intersectLine line # 求和线的交点
    self # intersection with line and no-points is no-points
  end
  def intersectVerticalLine vline # 求和竖线的交点
    self # intersection with line and no-points is no-points
  end
  # if self is the intersection of (1) some shape s and (2) 
  # the line containing seg, then we return the intersection of the 
  # shape s and the seg.  seg is an instance of LineSegment
  def intersectWithSegmentAsLineResult seg
    self
  end
end

class Point < GeometryValue # 点
  # *add* methods to this class -- do *not* change given code and do not
  # override any methods

  # Note: You may want a private helper method like the local
  # helper function inbetween in the ML code
  attr_reader :x, :y
  def initialize(x,y)
    @x = x
    @y = y
  end

  def preprocess_prog # 提前处理一个点
    self # 事实上，并没有什么好处理的啦！
  end

  def eval_prog env
    self
  end

  def shift (dx, dy)
    Point.new(x + dx, y + dy) # 新建一个对象
  end

  def intersectPoint p
    if real_close_point(self.x, self.y, p.x, p.y)
      then self
    else
      NoPoints.new
    end
  end

  def intersectLine line # 点和线的交点
    if real_close(y, line.m * x + line.b)
      then self
    else NoPoints.new
    end
  end

  def intersectVerticalLine vline # 求点和竖线的交点
    if real_close(x, vline.x)
      then self
      else NoPoints.new
    end
  end

  def intersect exp
    exp.intersectPoint self
  end

  def intersectWithSegmentAsLineResult seg
    # 运行到这一步，说明LineSegment和某一样东西结果是一个Point
    # 对应与SML文件里的东西，x代表x0，y代表y0
    # seg代表原来的线段，也就是SML中的v1
    if inbetween(x, seg.x1, seg.x2) and inbetween(y, seg.y1, seg.y2)
      Point.new(x, y)
    else
      NoPoints.new
    end
  end

  private
  def inbetween(v, end1, end2) # 这个主要是辅助的函数
    epsilon = GeometryExpression::Epsilon
    (end1 - epsilon <= v and v <= end2 + epsilon) or
	(end2 - epsilon <= v and v <= end1 + epsilon)
  end
end

class Line < GeometryValue # 线
  # *add* methods to this class -- do *not* change given code and do not
  # override any methods
  attr_reader :m, :b 
  def initialize(m,b)
    @m = m
    @b = b
  end

  def preprocess_prog
    self
  end

  def eval_prog env
    self
  end

  def shift (dx, dy) # 一条线段位移(dx, dy)的距离
    Line.new(m, b + dy - m * dx) # 重新构建一条线
  end

  def intersectPoint p # 线和点的交点，这样的话，转化一下,换成点和线段的交点
    p.intersectLine self
  end

  def intersectVerticalLine vline # 竖线和线的交点
    Point.new(vline.x, m * vline.x + b)
  end

  def intersectLine line # 线和线的交点
    if real_close(m, line.m) # 判断两条线的斜率是否一至
      then if real_close(b, line.b)
	     then self # 两个值都相等了，自然返回self
	     else NoPoints.new # 否则的话，就是平行了，没有交点
	   end
    else
	x = (line.b - b) / (m - line.m)
	y = m * x + b
	Point.new(x, y)
    end
  end

  def intersect exp # 这里说得好听一点，叫first dispatch
    exp.intersectLine self # 调用exp的intersectLine函数
  end

  def intersectWithSegmentAsLineResult seg
    # 运行到了这一步的话，说明线段和self的结果是一条线
    # 这里的seg对应与SML中的v1
    # 这里需要直接返回v1
    seg
  end

end

class VerticalLine < GeometryValue
  # *add* methods to this class -- do *not* change given code and do not
  # override any methods
  attr_reader :x
  def initialize x
    @x = x
  end

  def preprocess_prog
    self
  end

  def eval_prog env # 计算这段代码
    self
  end

  def shift(dx, dy)
    VerticalLine.new(x + dx)
  end

  def intersectVerticalLine vline # 求垂线和垂线的交点
    if real_close(x, vline.x)
      then self
      else NoPoints.new
    end
  end

  def intersect exp  # 好吧，这也是所谓的first dispatch
    exp.intersectVerticalLine self
  end

  def intersectWithSegmentAsLineResult seg
    # 和上面的类似
    seg
  end
end

class LineSegment < GeometryValue # 线段
  attr_reader :x1, :y1, :x2, :y2
  def initialize (x1,y1,x2,y2)
    @x1 = x1
    @y1 = y1
    @x2 = x2
    @y2 = y2
  end

  def preprocess_prog # LineSegment的预处理
    if real_close(x1, x2)
      if real_close(y1, y2)
	Point.new(x1, y1) # 两点坐标都非常接近，那么结果就是一个点
      elsif y1 > y2
	LineSegment.new(x2, y2, x1, y1)
      else
	self
      end
    elsif x1 > x2
      LineSegment.new(x2, y2, x1, y1)
    else
      self
    end
  end

  def eval_prog env
    self
  end

  def shift(dx, dy) # 线段的移动
    LineSegment.new(x1 + dx, y1 + dy, x2 + dx, y2 + dy)
  end


  def intersectWithSegmentAsLineResult seg
    # 好吧，这一部分算是最难理清楚的啦！
    # 这里的seg想当于SML文件中的v1
    # 而self相当与SML中的LineSegment seg2
    seg1 = [x1, y1, x2, y2]
    seg2 = [seg.x1, seg.y1, seg.x2, seg.y2]
    if real_close(x1, x2)
      aXstart, aYstart, aXend, aYend, bXstart, bYstart, bXend, bYend =
	  y1 < seg.y1 ? seg1 + seg2 : seg2 + seg1
      if real_close(aYend, bYstart)
	Point.new(aXend, aYend)
      elsif aYend < bYstart
	NoPoints.new
      elsif aYend > bYend
	LineSegment.new(bXstart, bYstart, bXend, bYend)
      else
	LineSegment.new(bXstart, bYstart, aXend, aYend)
      end
    else
      aXstart, aYstart, aXend, aYend, bXstart, bYstart, bXend, bYend =
	  x1 < seg.x1 ? seg1 + seg2 : seg2 + seg1
      if real_close(aXend, bXstart)
	Point.new(aXend, aYend)
      elsif aXend < bXstart
	NoPoints.new
      elsif aXend > bXend
	LineSegment.new(bXstart, bYstart, bXend, bYend)
      else
	LineSegment.new(bXstart, bYstart, aXend, aYend)
      end
    end
  end

  def intersect exp
    exp.intersectLineSegment self # 求exp和线段的交点
  end
end

# Note: there is no need for getter methods for the non-value classes
class Intersect < GeometryExpression
  # *add* methods to this class -- do *not* change given code and do not
  # override any methods
  def initialize(e1,e2)
    @e1 = e1
    @e2 = e2
  end

  def preprocess_prog
    Intersect.new(@e1.preprocess_prog, @e2.preprocess_prog) # 重新构建一个玩意
  end

  def eval_prog env
    # 到这里了，怎么玩
    @e1.eval_prog(env).intersect(@e2.eval_prog(env))
  end
end

class Let < GeometryExpression # let表达式
  def initialize(s,e1,e2)
    @s = s
    @e1 = e1
    @e2 = e2
  end

  def preprocess_prog # 构建出一个新的表达式，非常好啊！
    Let.new(@s, @e1.preprocess_prog, @e2.preprocess_prog)
  end

  def eval_prog env # let表达式的计算
    @e2.eval_prog(Array.new(env).unshift([@s, @e1]))
  end
end

class Var < GeometryExpression # 变量测试
  # *add* methods to this class -- do *not* change given code and do not
  # override any methods
  def initialize s
    @s = s
  end
  def eval_prog env # remember: do not change this method
    pr = env.assoc @s
    raise "undefined variable" if pr.nil?
    pr[1] # 返回这个值
  end
  def preprocess_prog
    self
  end
end

class Shift < GeometryExpression # shift表达式
  # *add* methods to this class -- do *not* change given code and do not
  # override any methods
  def initialize(dx,dy,e)
    @dx = dx
    @dy = dy
    @e = e
  end

  def preprocess_prog
    Shift.new(@dx, @dy, @e.preprocess_prog)
  end
  def eval_prog env
    @e.eval_prog(env).shift(@dx, @dy)
  end
end