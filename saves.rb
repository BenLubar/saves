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

open(ARGV[0] || 'ushul-minbaz/world.dat', 'rb') do |f|
  f = Decompressor.new f
  expect 'Version', f.version, 1404, '0.34.11'
  puts

begin
  a0 = i16(f)
  expect 'A-0', a0, 0
  a1 = i32(f)
  annotate 'A-1', a1, 'unknown A-1'
  a2 = i32(f)
  expect 'A-2', a2, a1, 'unknown A-1'
  a3 = i32(f)
  annotate 'A-3', a3, 'max artifact id'
  a4 = i32(f)
  annotate 'A-4', a4, 'unknown A-4'
  a5 = i32(f)
  expect 'A-5', a5, 0..a1, 'unknown A-1 (discovered)'
  a6 = i32(f)
  expect 'A-6', a6, 0..a3, 'max artifact id (discovered)'
  a7 = i32(f)
  annotate 'A-7', a7, 'unknown A-7; only seen in abandoned fortresses'
  a8 = i32(f)
  annotate 'A-8', a8, 'unknown A-8; only seen in abandoned fortresses'
  a9 = i32(f)
  annotate 'A-9', a9, 'max historical figure id'
  a10 = i32(f)
  annotate 'A-10', a10
  a11 = i32(f)
  annotate 'A-11', a11
  a12 = i32(f)
  annotate 'A-12', a12, 'max unit id'
  a13 = i32(f)
  annotate 'A-13', a13
  a14 = i32(f)
  expect 'A-14', a14, -1
  a15 = i32(f)
  annotate 'A-15', a15, 'unknown A-15; only seen in abandoned fortresses'
  expect 'A-16', i32(f), -1
  a17 = i32(f)
  annotate 'A-17', a17, 'unknown A-17; only seen in abandoned fortresses'
  a18 = i32(f)
  annotate 'A-18', a18, 'unknown A-18'
  a19 = i32(f)
  annotate 'A-19', a19, 'unknown A-19'
  a20 = i32(f)
  annotate 'A-20', a20, 'unknown A-20'
  a21 = i32(f)
  annotate 'A-21', a21, 'unknown A-21; only seen in abandoned fortresses'
  a22 = i32(f)
  annotate 'A-22', a22, 'unknown A-22; only seen in abandoned fortresses'
  a23 = i32(f)
  annotate 'A-23', a23, 'unknown A-23; only seen in abandoned fortresses'
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
  annotate 'A-55', a55, 'artifact types'
  expect 'A-56', (l(f){i32(f)}), []
  annotate 'A-57', (l(f){i32(f)}), "unknown A-4 (#{a4})"
  annotate 'A-58', (l(f){i32(f)}), "unknown A-1 (#{a1})"
  annotate 'A-59', (l(f){i32(f)}), "artifact ids (#{a3})"
  annotate 'A-60', (l(f){i16(f)}), 'unknown A-60; only seen in abandoned fortresses'
  annotate 'A-61', (l(f){i32(f)}), 'unknown A-61; only seen in abandoned fortresses'
  annotate 'A-62', (l(f){i32(f)}), 'unknown A-62; only seen in abandoned fortresses'
  annotate 'A-63', (l(f){i32(f)}), 'unknown A-63; only seen in abandoned fortresses'
  annotate 'A-64', (l(f){i32(f)}), 'unknown A-64; only seen in abandoned fortresses'
  annotate 'A-65', (l(f){i32(f)}), "unknown A-18 (#{a18})"
  annotate 'A-66', (l(f){i32(f)}), "unknown A-19 (#{a19})"
  annotate 'A-67', (l(f){i32(f)}), "unknown A-20 (#{a20})"
  annotate 'A-68', (l(f){i32(f)}), 'unknown A-68; only seen in abandoned fortresses'
  annotate 'A-69', (l(f){i32(f)}), 'unknown A-69; only seen in abandoned fortresses'
  annotate 'A-70', (l(f){i32(f)}), 'unknown A-70; only seen in abandoned fortresses'

  a55.each do |i, t|
    puts
    expect 'B-sep', f.read(8), "\xD0\x8A\xD0\x8A\xD0\x8A\x00\x00".b
    b0 = i32(f)
    expect 'B-0', b0, case t when 88 then 4 when 86 then 2052 else nil end, 'bitfield'
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
      annotate 'B-28', i32(f)
      expect 'B-29', i16(f), 0
      expect 'B-30', i32(f), -1
      expect 'B-31', i32(f), -1
      expect 'B-32', i32(f), 0
      expect 'B-33', i32(f), 0
      expect 'B-34', i16(f), 0
      expect 'B-35', i32(f), 6
      annotate 'B-36', i32(f)
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
      expect 'B-49', i16(f), 35..38
      annotate 'B-50', i32(f)
      annotate 'B-51', i32(f)
      expect 'B-52', i32(f), -1
      expect 'B-53', i32(f), 0
      expect 'B-54', i32(f), 0
      expect 'B-55', i16(f), 0
      annotate 'B-56', i32(f)
      expect 'B-57', i32(f), 1
      expect 'B-58', i32(f), $b58 ||= 0
      $b58 += 1
    end
    annotate 'B-59', s(f), if b0 & 0x800 == 0 then 'book title' else 'artifact description' end
    unless b0 & 0x800 == 0
      b60 = i32(f)
      annotate 'B-60', b60
      expect 'B-61', i16(f), 6
    end
  end

  (0..a4).each do |i|
    puts
    c0 = i16(f)
    expect 'C-0', c0, 0
    c1 = i32(f)
    expect 'C-1', c1, i, 'id'
    c2 = s(f)
    expect 'C-2', c2, a42
    c3 = i16(f)
    expect 'C-3', c3, 25
    c4 = i16(f)
    expect 'C-4', c4, 75
    c5 = i32(f)
    expect 'C-5', c5, i + 1, 'id + 1'
    c6 = i16(f)
    expect 'C-6', c6, 0
    c6_5 = opt(f){Name.new(f)}
    annotate 'C-6½', c6_5
    c7 = i32(f)
    expect 'C-7', c7, 0...(a39.size), "creature type (#{a39[c7]})"
    c8 = i16(f)
    expect 'C-8', c8, 0
    c9 = l(f){i16(f)}
    annotate 'C-9', c9
    c10 = l(f){i32(f)}
    annotate 'C-10', c10
    c11 = i32(f)
    expect 'C-11', c11, 0
    c12 = i32(f)
    expect 'C-12', c12, 0
    c13 = l(f){i16(f)}
    annotate 'C-13', c13
    c14 = l(f){i32(f)}
    annotate 'C-14', c14
    c15 = i32(f)
    expect 'C-15', c15, 0
    c16 = i32(f)
    expect 'C-16', c16, 0
    c17 = l(f){i16(f)}
    annotate 'C-17', c17
    c18 = l(f){i32(f)}
    annotate 'C-18', c18
    c19 = i32(f)
    expect 'C-19', c19, 0
    c20 = i32(f)
    expect 'C-20', c20, 0
    c21 = l(f){i16(f)}
    annotate 'C-21', c21
    c22 = l(f){i32(f)}
    annotate 'C-22', c22
    c23 = l(f){i16(f)}
    annotate 'C-23', c23
    c24 = l(f){i32(f)}
    annotate 'C-24', c24
    c25 = l(f){i16(f)}
    annotate 'C-25', c25
    c26 = l(f){i32(f)}
    annotate 'C-26', c26
    c27 = l(f){i16(f)}
    annotate 'C-27', c27
    c28 = l(f){i32(f)}
    annotate 'C-28', c28
    c29 = l(f){i16(f)}
    annotate 'C-29', c29
    c30 = l(f){i32(f)}
    annotate 'C-30', c30
    c31 = l(f){i16(f)}
    annotate 'C-31', c31
    c32 = l(f){i32(f)}
    annotate 'C-32', c32
    c33 = l(f){i16(f)}
    annotate 'C-33', c33
    c34 = l(f){i32(f)}
    annotate 'C-34', c34
    c35 = i32(f)
    expect 'C-35', c35, 0
    c36 = i32(f)
    expect 'C-36', c36, 0
    c37 = l(f){i16(f)}
    annotate 'C-37', c37
    c38 = l(f){i32(f)}
    annotate 'C-38', c38
    c39 = i32(f)
    expect 'C-39', c39, 0
    c40 = i32(f)
    expect 'C-40', c40, 0
    c41 = l(f){i16(f)}
    annotate 'C-41', c41
    c42 = l(f){i32(f)}
    annotate 'C-42', c42
    c43 = l(f){i16(f)}
    annotate 'C-43', c43
    c44 = l(f){i32(f)}
    annotate 'C-44', c44
    c45 = l(f){i32(f)}
    annotate 'C-45', c45
    c46 = l(f){i16(f)}
    annotate 'C-46', c46
    c47 = l(f){i32(f)}
    annotate 'C-47', c47
    c48 = l(f){i16(f)}
    annotate 'C-48', c48
    c49 = i32(f)
    expect 'C-49', c49, 0
    c50 = i32(f)
    expect 'C-50', c50, 0
    c51 = i32(f)
    expect 'C-51', c51, 0
    c52 = i32(f)
    expect 'C-52', c52, 0
    c53 = i32(f)
    expect 'C-53', c53, 0
    c54 = i32(f)
    expect 'C-54', c54, 0
    c55 = i32(f)
    expect 'C-55', c55, 0
    c56 = i32(f)
    expect 'C-56', c56, 0
    c57 = l(f){i32(f)}
    annotate 'C-57', c57
    c58 = l(f){i16(f)}
    annotate 'C-58', c58
    c59 = l(f){i32(f)}
    annotate 'C-59', c59
    c60 = l(f){i16(f)}
    annotate 'C-60', c60
    c61 = i32(f)
    expect 'C-61', c61, 0
    c62 = i32(f)
    expect 'C-62', c62, 0
    c63 = i32(f)
    expect 'C-63', c63, 0
    c64 = i32(f)
    expect 'C-64', c64, 0
    c65 = l(f){i32(f)}
    annotate 'C-65', c65
    c66 = l(f){i16(f)}
    annotate 'C-66', c66
    c67 = l(f){i32(f)}
    annotate 'C-67', c67
    c68 = l(f){i16(f)}
    annotate 'C-68', c68
    c69 = l(f){i32(f)}
    annotate 'C-69', c69
    c70 = l(f){i16(f)}
    annotate 'C-70', c70
    c71 = l(f){i16(f)}
    annotate 'C-71', c71
    c72 = l(f){i32(f)}
    annotate 'C-72', c72
    c73 = i32(f)
    expect 'C-73', c73, 0
    c74 = i32(f)
    expect 'C-74', c74, 0
    c75 = i32(f)
    expect 'C-75', c75, 0
    c76 = l(f){i16(f)}
    annotate 'C-76', c76
    c77 = l(f){i32(f)}
    annotate 'C-77', c77
    c78 = i32(f)
    expect 'C-78', c78, 0
    c79 = i32(f)
    expect 'C-79', c79, 0
    c80 = i32(f)
    expect 'C-80', c80, 0
    c81 = i32(f)
    expect 'C-81', c81, 0
    c82 = l(f){i16(f)}
    annotate 'C-82', c82
    c83 = l(f){i32(f)}
    annotate 'C-83', c83
    c84 = l(f){i16(f)}
    annotate 'C-84', c84
    c85 = l(f){i32(f)}
    annotate 'C-85', c85
    c86 = i32(f)
    expect 'C-86', c86, 0
    c87 = i32(f)
    expect 'C-87', c87, 0
    c88 = l(f){i16(f)}
    annotate 'C-88', c88
    c89 = l(f){i32(f)}
    annotate 'C-89', c89
    c90 = i32(f)
    expect 'C-90', c90, 0
    c91 = i32(f)
    expect 'C-91', c91, 0
    c92 = l(f){i16(f)}
    annotate 'C-92', c92
    c93 = l(f){i32(f)}
    annotate 'C-93', c93
    c94 = i16(f)
    expect 'C-94', c94, -1
    c95 = i32(f)
    annotate 'C-95', c95
    c96 = i16(f)
    expect 'C-96', c96, -1
    c97 = i32(f)
    annotate 'C-97', c97
    c98 = i16(f)
    expect 'C-98', c98, -1
    c99 = i32(f)
    annotate 'C-99', c99
    c100 = i32(f)
    expect 'C-100', c100, 0
    c101 = l(f){i16(f)}
    annotate 'C-101', c101
    c102 = i32(f)
    expect 'C-102', c102, 0
    c103 = i32(f)
    expect 'C-103', c103, 0
    c104 = l(f){i16(f)}
    annotate 'C-104', c104
    c105 = i32(f)
    expect 'C-105', c105, 0
    c106 = i32(f)
    expect 'C-106', c106, 0
    c107 = i32(f)
    expect 'C-107', c107, 0
    c108 = i32(f)
    expect 'C-108', c108, 0
    c109 = l(f){i16(f)}
    annotate 'C-109', c109
    c110 = i32(f)
    expect 'C-110', c110, 0
    c111 = i32(f)
    expect 'C-111', c111, 0
    c112 = i32(f)
    expect 'C-112', c112, 0
    c113 = i32(f)
    expect 'C-113', c113, 0
    c114 = i32(f)
    expect 'C-114', c114, 0
    c115 = i32(f)
    expect 'C-115', c115, 0
    c116 = i32(f)
    expect 'C-116', c116, 0
    c117 = l(f){i16(f)}
    annotate 'C-117', c117
    c118 = l(f){i32(f)}
    annotate 'C-118', c118
    c119 = l(f){i16(f)}
    annotate 'C-119', c119
    c120 = l(f){i32(f)}
    annotate 'C-120', c120
    c121 = l(f){i16(f)}
    annotate 'C-121', c121
    c122 = l(f){i32(f)}
    annotate 'C-122', c122
    c123 = i32(f)
    expect 'C-123', c123, 0
    c124 = i32(f)
    expect 'C-124', c124, 0
    c125 = l(f){i16(f)}
    annotate 'C-125', c125
    c126 = l(f){i32(f)}
    annotate 'C-126', c126
    c127 = i32(f)
    expect 'C-127', c127, 0
    c128 = i32(f)
    expect 'C-128', c128, 0
    c129 = i32(f)
    expect 'C-129', c129, 0
    c130 = i32(f)
    expect 'C-130', c130, 0
    c131 = i32(f)
    expect 'C-131', c131, 0
    c132 = i32(f)
    expect 'C-132', c132, 0
    c133 = i32(f)
    expect 'C-133', c133, 0
    c134 = i32(f)
    expect 'C-134', c134, 0
    c135 = i32(f)
    expect 'C-135', c135, 0
    c136 = i32(f)
    expect 'C-136', c136, 0
    c137 = i32(f)
    expect 'C-137', c137, 0
    c138 = i32(f)
    expect 'C-138', c138, 1
    c139 = i32(f)
    expect 'C-139', c139, i, 'id'
    c140 = i32(f)
    expect 'C-140', c140, 0
    c141 = i16(f)
    expect 'C-141', c141, 1
    c142 = i32(f)
    expect 'C-142', c142, 0
    c143 = i16(f)
    expect 'C-143', c143, 1
    c144 = i16(f)
    expect 'C-144', c144, 0
    c145 = i32(f)
    expect 'C-145', c145, 0
    c146 = i32(f)
    expect 'C-146', c146, 1
    c147 = i16(f)
    expect 'C-147', c147, i, 'id'
    c148 = i32(f)
    expect 'C-148', c148, 1
    c149 = i32(f)
    annotate 'C-149', c149
    c150 = i16(f)
    annotate 'C-150', c150
    c151 = i32(f)
    expect 'C-151', c151, 1
    c152 = i32(f)
    annotate 'C-152', c152
    c153 = i16(f)
    expect 'C-153', c153, [0, 256]
    c154 = i32(f)
    expect 'C-154', c154, 1
    c155 = i16(f)
    annotate 'C-155', c155
    c156 = i32(f)
    expect 'C-156', c156, 1
    c157 = i32(f)
    annotate 'C-157', c157
    c158 = a(6){i16(f)}
    expect 'C-158', c158, [0, 0, 0, -1, -1, -1]
    c159 = i32(f)
    annotate 'C-159', c159
    c160 = i32(f)
    expect 'C-160', c160, -1
    c161 = i32(f)
    expect 'C-161', c161, -1
    c162 = i32(f)
    expect 'C-162', c162, 0
    c163 = i32(f)
    expect 'C-163', c163, 0
    c164 = i32(f)
    expect 'C-164', c164, 3
    c165 = a(7){i32(f)}
    expect 'C-165', c165, [0, 0, 0, 0, 0, 0, 0]
    c166 = i8(f)
    expect 'C-166', c166, 0
    c167 = a(24){i16(f)}
    expect 'C-167', c167, [13, 1, 1, 1, 1, 15, 0, 1, 15, 15, 0, 0, 0, 0, 0, 2, 15, 15, 15, 15, 15, 15, 0, 0]
    c168 = a(28){i32(f)}
    expect 'C-168', c168, [0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    c169 = i8(f)
    expect 'C-169', c169, 0
  end

ensure
  IO.popen 'xxd', 'w' do |io|
    io.write f.read(0x1000)
  end
end
end
