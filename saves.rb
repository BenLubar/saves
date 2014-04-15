require 'zlib'

class Array
  def === x
    self == x or include? x
  end
end

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

def expect label, actual, expected, description='TODO'
  raise "#{label} (#{description}): expected #{expected.inspect} but got #{actual.inspect}" unless expected === actual
  annotate label, actual, "#{expected.inspect} observed; #{description}"
end

def annotate label, value, description='TODO'
  puts "#{label}\t#{value.inspect}\t(#{description})"
end

open('ushul-minbaz/world.dat', 'rb') do |f|
  f = Decompressor.new f
  expect 'Version', f.version, 1404, '0.34.11'
  puts

  expect 'A-0', i16(f), 0
  a1 = i32(f)
  annotate 'A-1', a1, 'unknown A-1'
  expect 'A-2', i32(f), a1, 'unknown A-1'
  a3 = i32(f)
  annotate 'A-3', a3, 'max artifact id'
  a4 = i32(f)
  annotate 'A-4', a4, 'unknown A-4'
  expect 'A-5', i32(f), a1, 'unknown A-1'
  expect 'A-6', i32(f), a3, 'max artifact id'
  expect 'A-7', i32(f), -1
  expect 'A-8', i32(f), -1
  a9 = i32(f)
  annotate 'A-9', a9, 'max historical figure id'
  annotate 'A-10', i32(f)
  annotate 'A-11', i32(f)
  a12 = i32(f)
  annotate 'A-12', a12, 'max unit id'
  annotate 'A-13', i32(f)
  expect 'A-14', i32(f), -1
  expect 'A-15', i32(f), -1
  expect 'A-16', i32(f), -1
  expect 'A-17', i32(f), -1
  a18 = i32(f)
  annotate 'A-18', a18, 'unknown A-18'
  a19 = i32(f)
  annotate 'A-19', a19, 'unknown A-19'
  a20 = i32(f)
  annotate 'A-20', a20, 'unknown A-20'
  expect 'A-21', i32(f), -1
  expect 'A-22', i32(f), -1
  expect 'A-23', i32(f), -1
  annotate 'A-24', (opt(f){Name.new(f)}), 'world name'
  expect 'A-25', i8(f), 1
  expect 'A-26', i16(f), 0
  expect 'A-27', i32(f), 1
  expect 'A-28', i32(f), 0
  expect 'A-29', i32(f), 0
  annotate 'A-30', s(f), 'world name'
  a31 = l(f){l(f){s(f)}}
  annotate 'A-31', a31, 'inorganic raws'
  a32 = l(f){l(f){s(f)}}
  annotate 'A-32', a32, 'item raws'
  a33 = l(f){l(f){s(f)}}
  annotate 'A-33', a33, 'creature raws'
  a34 = l(f){l(f){s(f)}}
  annotate 'A-34', a34, 'interaction raws'
  a35 = l(f){s(f)}
  annotate 'A-35', a35, 'inorganic string table'
  a36 = l(f){s(f)}
  annotate 'A-36', a36, 'plant string table'
  a37 = l(f){s(f)}
  annotate 'A-37', a37, 'body string table'
  a38 = l(f){s(f)}
  annotate 'A-38', a38, 'bodygloss string table'
  a39 = l(f){s(f)}
  annotate 'A-39', a39, 'creature string table'
  a40 = l(f){s(f)}
  annotate 'A-40', a40, 'item string table'
  a41 = l(f){s(f)}
  annotate 'A-41', a41, 'building string table'
  a42 = l(f){s(f)}
  annotate 'A-42', a42, 'entity string table'
  a43 = l(f){s(f)}
  annotate 'A-43', a43, 'word string table'
  a44 = l(f){s(f)}
  annotate 'A-44', a44, 'symbol string table'
  a45 = l(f){s(f)}
  annotate 'A-45', a45, 'translation string table'
  a46 = l(f){s(f)}
  annotate 'A-46', a46, 'color string table'
  a47 = l(f){s(f)}
  annotate 'A-47', a47, 'shape string table'
  a48 = l(f){s(f)}
  annotate 'A-48', a48, 'color_pattern string table'
  a49 = l(f){s(f)}
  annotate 'A-49', a49, 'reaction string table'
  a50 = l(f){s(f)}
  annotate 'A-50', a50, 'material_template string table'
  a51 = l(f){s(f)}
  annotate 'A-51', a51, 'tissue_template string table'
  a52 = l(f){s(f)}
  annotate 'A-52', a52, 'body_detail_plan string table'
  a53 = l(f){s(f)}
  annotate 'A-53', a53, 'creature_variation string table'
  a54 = l(f){s(f)}
  annotate 'A-54', a54, 'interaction string table'
  a55 = Hash[l(f){[i32(f), i32(f)]}]
  annotate 'A-55', a55
  expect 'A-56', (l(f){i32(f)}), []
  annotate 'A-57', (l(f){i32(f)}), "unknown A-4 (#{a4})"
  annotate 'A-58', (l(f){i32(f)}), "unknown A-1 (#{a1})"
  annotate 'A-59', (l(f){i32(f)}), "artifact ids (#{a3})"
  expect 'A-60', (l(f){i32(f)}), []
  expect 'A-61', (l(f){i32(f)}), []
  expect 'A-62', (l(f){i32(f)}), []
  expect 'A-63', (l(f){i32(f)}), []
  expect 'A-64', (l(f){i32(f)}), []
  annotate 'A-65', (l(f){i32(f)}), "unknown A-18 (#{a18})"
  annotate 'A-66', (l(f){i32(f)}), "unknown A-19 (#{a19})"
  annotate 'A-67', (l(f){i32(f)}), "unknown A-20 (#{a20})"
  expect 'A-68', (l(f){i32(f)}), []
  expect 'A-69', (l(f){i32(f)}), []
  expect 'A-70', (l(f){i32(f)}), []

  (0..a3).each do |i|
    puts
    expect 'B-sep', f.read(8), "\xD0\x8A\xD0\x8A\xD0\x8A\x00\x00".b
    b0 = i32(f)
    expect 'B-0', b0, [0x4, 0x804], 'bitfield'
    expect 'B-1', i16(f), 0
    expect 'B-2', i16(f), 0
    expect 'B-3', i16(f), 0
    expect 'B-4', i32(f), i, 'id'
    expect 'B-5', i32(f), 0
    expect 'B-6', i32(f), 1
    expect 'B-7', i32(f), 1
    expect 'B-8', i32(f), i, 'id'
    expect 'B-9', i32(f), -1
    expect 'B-10', i32(f), -1
    expect 'B-11', i32(f), 1
    expect 'B-12', i8(f), 0
    expect 'B-13', i8(f), 0
    expect 'B-14', i8(f), 0
    expect 'B-15', f.read(2), "B'", 'magic number?'
    expect 'B-16', i32(f), 0
    expect 'B-17', i32(f), 0
    expect 'B-18', i32(f), -1
    annotate 'B-19', i16(f)
    annotate 'B-20', i32(f)
    expect 'B-21', i16(f), -1
    expect 'B-22', i16(f), if b0 & 0x800 == 0 then 0 else 5 end, '0=book, 5=slab'
    expect 'B-23', i32(f), 0
    annotate 'B-24', i32(f)
    expect 'B-25', i32(f), -1
    b26 = i32(f)
    expect 'B-26', b26, [0, 1, 3], 'bitfield'
    unless b26 & 2 == 0
      expect 'B-27', i32(f), 7
      expect 'B-28', i32(f), [33357861, 3539365]
      expect 'B-29', i16(f), 0
      expect 'B-30', i32(f), -1
      expect 'B-31', i32(f), -1
      expect 'B-32', i32(f), 0
      expect 'B-33', i32(f), 0
      expect 'B-34', i16(f), 0
      expect 'B-35', i32(f), 6
      expect 'B-36', i32(f), [33357861, 3539365]
      expect 'B-37', i16(f), 0
      expect 'B-38', i32(f), -1
      expect 'B-39', i32(f), -1
      expect 'B-40', i32(f), 0
      expect 'B-41', i32(f), 0
      expect 'B-42', i16(f), 0
      expect 'B-43', i32(f), -1
      expect 'B-44', i32(f), -1
      expect 'B-45', i16(f), -1
      expect 'B-46', i32(f), 0
      expect 'B-47', i32(f), 0
    end
    unless b26 & 1 == 0
      expect 'B-48', i32(f), 9
      expect 'B-49', i16(f), [36, 37, 38]
      annotate 'B-50', i32(f)
      annotate 'B-51', i32(f)
      expect 'B-52', i32(f), -1
      expect 'B-53', i32(f), 0
      expect 'B-54', i32(f), 0
      expect 'B-55', i16(f), 0
      annotate 'B-56', i32(f)
      expect 'B-57', i32(f), 1
      annotate 'B-58', i32(f)
    end
    annotate 'B-59', s(f), if b0 & 0x800 == 0 then 'book title' else 'artifact description' end
    unless b0 & 0x800 == 0
      b60 = i32(f)
      annotate 'B-60', b60
      expect 'B-61', i16(f), 6
    end
  end
end
