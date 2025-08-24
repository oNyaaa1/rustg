

byte = byte or {}



--

-- Helper Functions

--



local function maskBits(from, to)

    return bit.lshift(bit.bnot(0), from - 1) - bit.lshift(bit.bnot(0), to)

end



function byte.getbitrange(num, from, to)

    if (from > math.ceil(math.log(num + 1, 2))) then

        return 0

    end



    return bit.band(num, maskBits(from, to))

end



function byte.bitstobyte(bits)

    return math.max(math.ceil(bits / 8), 1)

end



--

-- Read

--



function byte.open(dir, path)

    byte.file = {}

    byte.file.data      = file.Read(dir, path)

    byte.file.byte      = 0

end



function byte.nextbyte()

    byte.file.byte = byte.file.byte + 1



    return string.byte(byte.file.data[byte.file.byte])

end



function byte.close()

    byte.file = nil

end



function byte.readint(bitcount)

    local bytecount = byte.bitstobyte(bitcount)

    local num = 0

    

    for i = 1, bytecount do

        num = num + bit.lshift(byte.nextbyte(), (i - 1) * 8)

    end



    return num

end



function byte.readchar()

    return string.char(byte.nextbyte())

end



function byte.readstring()

    local len = byte.readint(32)

    local str = {}

    

    for i = 1, len do

        str[i] = byte.readchar()

    end



    return table.concat(str)

end



function byte.readvector()

    local x = byte.readint(32)

    local y = byte.readint(32)

    local z = byte.readint(32)



    return Vector(x, y, z)

end



--

-- Write

--



function byte.startwrite(dir)

    byte.writefile = {}

    byte.writefile.dir  = dir

    byte.writefile.data = {}

end



function byte.appendbyte(b)

    b = math.max(math.min(b, 255), 0)

    byte.writefile.data[#byte.writefile.data + 1] = string.char(b)

end



function byte.endwrite()

    file.Write(byte.writefile.dir, table.concat(byte.writefile.data))

end



function byte.writeint(number, bitcount)

    local bytecount = byte.bitstobyte(bitcount)



    for i = 1, bytecount do

        local br = byte.getbitrange(number, ((i - 1) * 8) + 1, i * 8)

        br = bit.rshift(br, (i - 1) * 8)



        byte.appendbyte(br)

    end

end



function byte.writechar(char)

    byte.writeint(string.byte(char), 8)

end



function byte.writestring(str)

    local len = string.len(str)

    byte.writeint(len, 32)



    for i = 1, len do

        byte.writechar(string.sub(str, i, i))

    end

end



function byte.writevector(vec)

    byte.writeint(vec.x, 32)

    byte.writeint(vec.y, 32)

    byte.writeint(vec.z, 32)

end