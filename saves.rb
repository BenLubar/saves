require 'zlib'

class Decompressor
  attr_reader :version

  def initialize io
    @buf = ''
    @io = io
    @version = i32(io)
    compressed = i32(io)
    case compressed
    when 0
      @compressed = false
    when 1
      @compressed = true
    else
      raise "Expected 0 or 1 but got #{compressed}"
    end
  end

  def read n
    while @buf.size < n
      fill_buf
    end
    result = @buf[0...n]
    @buf = @buf[n...@buf.size]
    result
  end

  def unread buf
    @buf = buf + @buf
  end

  private
  def fill_buf
    if @compressed
      n = i32(@io)
      if n < 0
        raise "Expected non-negative integer but got #{n}"
      end

      @buf << Zlib::Inflate.inflate(@io.read(n))
    else
      @buf << @io.read(1024)
    end
  end
end

class Name
  attr_reader :first
  attr_reader :nick
  attr_reader :index
  attr_reader :form
  attr_reader :language
  attr_reader :unknown

  def initialize io
    @first = s(io)
    @nick = s(io)
    @index = a(7) do i32(io) end
    @form = a(7) do i16(io) end
    @language = i32(io)
    @unknown = i16(io)
  end
end

def i8 io
  io.read(1).unpack('c')[0]
end

def i16 io
  io.read(2).unpack('s<')[0]
end

def i32 io
  io.read(4).unpack('l<')[0]
end

def i64 io
  io.read(8).unpack('q<')[0]
end

def opt io
  n = i8(io)
  case n
  when 0
    nil
  when 1
    yield
  else
    raise "Expected 0 or 1 but got #{n}"
  end
end

def a n
  if n < 0
    raise "Expected non-negative integer but got #{n}"
  end

  n.times.map do |i|
    yield i
  end
end

def l io
  a(i32(io)) do |i|
    yield i
  end
end

def s io
  io.read(i16(io)).force_encoding(Encoding::CP437).encode(Encoding::UTF_8)
end

open('ushul-minbaz/world.dat', 'rb') do |f|
  f = Decompressor.new f
  puts "Version #{f.version}"
  puts "A-0 #{i16(f)}"
  puts "A-1 #{i32(f)}"
  puts "A-2 #{i32(f)}"
  puts "A-3 #{i32(f)} (observed to be the max artifact id)"
  puts "A-4 #{i32(f)}"
  puts "A-5 #{i32(f)}"
  puts "A-6 #{i32(f)} (observed to be the max artifact id)"
  puts "A-7 #{i32(f)}"
  puts "A-8 #{i32(f)}"
  puts "A-9 #{i32(f)}"
  puts "A-10 #{i32(f)}"
  puts "A-11 #{i32(f)}"
  puts "A-12 #{i32(f)}"
  puts "A-13 #{i32(f)}"
  puts "A-14 #{i32(f)}"
  puts "A-15 #{i32(f)}"
  puts "A-16 #{i32(f)}"
  puts "A-17 #{i32(f)}"
  puts "A-18 #{i32(f)}"
  puts "A-19 #{i32(f)}"
  puts "A-20 #{i32(f)}"
  puts "A-21 #{i32(f)}"
  puts "A-22 #{i32(f)}"
  puts "A-23 #{i32(f)}"
  opt(f) do
    puts "A-24 #{Name.new(f).inspect}"
  end
  puts "A-25 #{i8(f)}"
  puts "A-26 #{i16(f)}"
  puts "A-27 #{i32(f)}"
  puts "A-28 #{i32(f)}"
  puts "A-29 #{i32(f)}"
  puts "A-30 #{s(f).inspect}"
  puts "A-31 #{l(f){l(f){s(f)}}.inspect}"
  puts "A-32 #{l(f){l(f){s(f)}}.inspect}"
  puts "A-33 #{l(f){l(f){s(f)}}.inspect}"
  puts "A-34 #{l(f){l(f){s(f)}}.inspect}"
  puts "A-35 #{l(f){s(f)}.inspect}"
  puts "A-36 #{l(f){s(f)}.inspect}"
  puts "A-37 #{l(f){s(f)}.inspect}"
  puts "A-38 #{l(f){s(f)}.inspect}"
  puts "A-39 #{l(f){s(f)}.inspect}"
  puts "A-40 #{l(f){s(f)}.inspect}"
  puts "A-41 #{l(f){s(f)}.inspect}"
  puts "A-42 #{l(f){s(f)}.inspect}"
  puts "A-43 #{l(f){s(f)}.inspect}"
  puts "A-44 #{l(f){s(f)}.inspect}"
  puts "A-45 #{l(f){s(f)}.inspect}"
  puts "A-46 #{l(f){s(f)}.inspect}"
  puts "A-47 #{l(f){s(f)}.inspect}"
  puts "A-48 #{l(f){s(f)}.inspect}"
  puts "A-49 #{l(f){s(f)}.inspect}"
  puts "A-50 #{l(f){s(f)}.inspect}"
  puts "A-51 #{l(f){s(f)}.inspect}"
  puts "A-52 #{l(f){s(f)}.inspect}"
  puts "A-53 #{l(f){s(f)}.inspect}"
  puts "A-54 #{l(f){s(f)}.inspect}"
  puts "A-55 #{Hash[l(f){[i32(f), i32(f)]}].inspect}"
  puts "A-56 #{i32(f)}"
  puts "A-57 #{l(f){i32(f)}.inspect}"
  puts "A-58 #{l(f){i32(f)}.inspect}"
  puts "A-59 #{l(f){i32(f)}.inspect}"
  puts "A-60 #{l(f){i32(f)}.inspect}"
  puts "A-61 #{l(f){i32(f)}.inspect}"
  puts "A-62 #{l(f){i32(f)}.inspect}"
  puts "A-63 #{l(f){i32(f)}.inspect}"
  puts "A-64 #{l(f){i32(f)}.inspect}"
  puts "A-65 #{l(f){i32(f)}.inspect}"
  puts "A-66 #{l(f){i32(f)}.inspect}"
  puts "A-67 #{l(f){i32(f)}.inspect}"
  puts "A-68 #{l(f){i32(f)}.inspect}"
  puts "A-69 #{l(f){i32(f)}.inspect}"
  puts "A-70 #{l(f){i32(f)}.inspect}"

  loop do
    buf = f.read(8)
    unless buf == "\xD0\x8A\xD0\x8A\xD0\x8A\x00\x00".b
      f.unread(buf)
      break
    end

    b0 = i32(f)
    puts "B-0 #{sprintf '%08x', b0}"
    puts "B-1 #{i16(f)}"
    puts "B-2 #{i16(f)}"
    puts "B-3 #{i16(f)}"
    puts "B-4 #{i32(f)}"
    puts "B-5 #{i32(f)}"
    puts "B-6 #{i32(f)}"
    puts "B-7 #{i32(f)}"
    puts "B-8 #{i32(f)}"
    puts "B-9 #{i32(f)}"
    puts "B-10 #{i32(f)}"
    puts "B-11 #{i32(f)}"
    puts "B-12 #{i8(f)}"
    puts "B-13 #{i8(f)}"
    puts "B-14 #{i8(f)}"
    puts "B-15 #{f.read(2).inspect}"
    puts "B-16 #{i32(f)}"
    puts "B-17 #{i32(f)}"
    puts "B-18 #{i32(f)}"
    puts "B-19 #{i16(f)}"
    puts "B-20 #{i32(f)}"
    puts "B-21 #{i16(f)}"
    puts "B-22 #{i16(f)}"
    puts "B-23 #{i32(f)}"
    puts "B-24 #{i32(f)}"
    puts "B-25 #{i32(f)}"
    b26 = i32(f)
    puts "B-26 #{sprintf '%08x', b26}"
    puts "B-27 #{f.read(74).inspect}" unless b26 & 2 == 0
    puts "B-28 #{f.read(40).inspect}" unless b26 & 1 == 0
    puts "B-29 #{s(f).inspect}"
    puts "B-30 #{f.read(6).inspect}" unless b0 & 0x800 == 0
  end
end
