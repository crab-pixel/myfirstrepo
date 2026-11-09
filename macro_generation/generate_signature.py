"""Generate the GF180 Metal5 silicon-art macro for the project signature."""

from pathlib import Path

import gdstk


CELL_NAME = "vihaan_pingalkar"
TEXT = "VIHAAN PINGALKAR"
PIXEL = 0.8  # um; comfortably above a minimum-width decorative feature.
ART_LAYER = 81  # GF180 Metal5 drawing
PR_BOUNDARY_LAYER = 0  # GF180 PR_bndry
GLYPHS = {
    "A": ("01110", "10001", "10001", "11111", "10001", "10001", "10001"),
    "G": ("01110", "10001", "10000", "10111", "10001", "10001", "01110"),
    "H": ("10001", "10001", "10001", "11111", "10001", "10001", "10001"),
    "I": ("11111", "00100", "00100", "00100", "00100", "00100", "11111"),
    "K": ("10001", "10010", "10100", "11000", "10100", "10010", "10001"),
    "L": ("10000", "10000", "10000", "10000", "10000", "10000", "11111"),
    "N": ("10001", "11001", "10101", "10011", "10001", "10001", "10001"),
    "P": ("11110", "10001", "10001", "11110", "10000", "10000", "10000"),
    "R": ("11110", "10001", "10001", "11110", "10100", "10010", "10001"),
    "V": ("10001", "10001", "10001", "10001", "10001", "01010", "00100"),
    " ": ("00000",) * 7,
}


def write_lef(path: Path, width: float, height: float) -> None:
    path.write_text(
        f"""VERSION 5.8 ;
NAMESCASESENSITIVE ON ;
DIVIDERCHAR \"/\" ;
BUSBITCHARS \"[]\" ;
UNITS
  DATABASE MICRONS 1000 ;
END UNITS

MACRO {CELL_NAME}
  CLASS BLOCK ;
  FOREIGN {CELL_NAME} 0 0 ;
  ORIGIN 0 0 ;
  SIZE {width:.3f} BY {height:.3f} ;
  SYMMETRY X Y ;
END {CELL_NAME}

END LIBRARY
"""
    )


def main() -> None:
    output_dir = Path(__file__).parents[1] / "macros"
    output_dir.mkdir(exist_ok=True)

    margin = 2 * PIXEL
    glyph_width = 5 * PIXEL
    gap = PIXEL
    space_width = 3 * PIXEL
    text_width = sum(space_width if char == " " else glyph_width + gap for char in TEXT) - gap
    width = text_width + 2 * margin
    height = 7 * PIXEL + 2 * margin

    library = gdstk.Library(unit=1e-6, precision=1e-9)
    cell = library.new_cell(CELL_NAME)
    cell.add(gdstk.rectangle((0, 0), (width, height), layer=PR_BOUNDARY_LAYER))

    x = margin
    y = margin
    for char in TEXT:
        if char == " ":
            x += space_width
            continue
        for row, pattern in enumerate(GLYPHS[char]):
            for column, pixel in enumerate(pattern):
                if pixel == "1":
                    left = x + column * PIXEL
                    bottom = y + (6 - row) * PIXEL
                    cell.add(
                        gdstk.rectangle(
                            (left, bottom),
                            (left + PIXEL, bottom + PIXEL),
                            layer=ART_LAYER,
                        )
                    )
        x += glyph_width + gap

    library.write_gds(output_dir / f"{CELL_NAME}.gds")
    write_lef(output_dir / f"{CELL_NAME}.lef", width, height)


if __name__ == "__main__":
    main()
