module Mapcrusha
  include Magick

  def self.crush_tiles(tiles, tile_width=32, tile_height=32, width=16)
    row = ImageList.new
    rows = ImageList.new

    blank = Image.new tile_width, tile_height
    blank.alpha TransparentAlphaChannel

    tiles.each_with_index do |tile, n|
      image = if is_data_url tile
        Image.from_blob(parse_data_url(tile))
      else
        Image.read(tile)
      end.first

      row << blank.composite(image, 0, 0, OverCompositeOp)

      if n % width == width - 1
        rows << row.append(false)
        row = ImageList.new
      end
    end

    if row.length > 0
      rows << row.append(false)
    end

    rows.append(true)
  end

  def self.is_data_url(tile)
    tile =~ /\Adata:/
  end

  def self.parse_data_url(url)
    url =~ /\Adata:.*;base64\,(.*)\z/m

    Base64.decode64($1)
  end

  def self.test
    a = "data:image/png;base64,
iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAABGdBTUEAALGP
C/xhBQAAAAlwSFlzAAALEwAACxMBAJqcGAAAAAd0SU1FB9YGARc5KB0XV+IA
AAAddEVYdENvbW1lbnQAQ3JlYXRlZCB3aXRoIFRoZSBHSU1Q72QlbgAAAF1J
REFUGNO9zL0NglAAxPEfdLTs4BZM4DIO4C7OwQg2JoQ9LE1exdlYvBBeZ7jq
ch9//q1uH4TLzw4d6+ErXMMcXuHWxId3KOETnnXXV6MJpcq2MLaI97CER3N0
vr4MkhoXe0rZigAAAABJRU5ErkJggg=="

    b = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgEAYAAAAj6qa3AAAABmJLR0T///////8JWPfcAAAACXBIWXMAAABIAAAASABGyWs+AAABrElEQVRo3u2Yva6CMBiGPwyjC6sD9+Di4OgFYOLi7uLi4AW4aUxMHFxZvId6ASTGxMHduDgYd/UGTHoGTlvTky9Y7A/geRfa0gLPQwsEgC+P5+rEgwHAfk+p3L5eA7TbnrXrsi4AA8diWog1AargtoQYF6AL3JQQYwJMg+sSol2AK/C8IrQJKAq4qpCPBRQdPEtEbgFlA8dE1L4NXM7bAqoGnobSTAFVA79cAJJE1FEBZQXv91erXi8bnOXPQ7Cs4JiIxWI8Ho1Ee5IATCaizmdAVcCxyOBpPK9WNXA21bfb261ex8FZSfk1WNTIa3w+n07PZxyct7BCWWeCDJ51x+XwGRBFcXy9im3R8yk4i88Kj0er5ftihyxisxkOw9A1tj5w3pMV7ndCTiexBAgJw+NRdAyCw+H5dCdENzgfwdb+cklIEOAdXQkxBc5HphtKUxFih2shpsElASxiCbgSYgscESBHvxBMhG3wNwXoF7LbNZuNhntwFl+tu7iQ9I/K64dTt6sixDV4TgH5hURRHL8+E1yD8zOZPbwQ0ukAzGbFAbckABfiGvw/v/kBtatAtbkX3D0AAAAASUVORK5CYII="

    c = "http://dev.pixie.strd6.com/sprites/1088/original.png?1280972840"

    d = "data:image/png;base64,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"

    e = "http://rmagick.rubyforge.org/decorations/logo-small.gif"

    crush_tiles [a, b, c, d, e]
  end
end