"""Measure Polybar's Fontconfig/Cairo faces, including configured glyph fallback."""
import ctypes as c
import math

FC = c.CDLL("libfontconfig.so.1")
CAIRO = c.CDLL("libcairo.so.2")


def bind(lib, name, result, *args):
    function = getattr(lib, name)
    function.restype = result
    function.argtypes = args
    return function


ptr = c.c_void_p
fc_parse = bind(FC, "FcNameParse", ptr, c.c_char_p)
fc_defaults = bind(FC, "FcDefaultSubstitute", None, ptr)
fc_substitute = bind(FC, "FcConfigSubstitute", c.c_int, ptr, ptr, c.c_int)
fc_match = bind(FC, "FcFontMatch", ptr, ptr, ptr, c.POINTER(c.c_int))
fc_destroy = bind(FC, "FcPatternDestroy", None, ptr)
fc_charset = bind(FC, "FcPatternGetCharSet", c.c_int, ptr, c.c_char_p, c.c_int, c.POINTER(ptr))
fc_has_char = bind(FC, "FcCharSetHasChar", c.c_int, ptr, c.c_uint)
fc_double = bind(FC, "FcPatternGetDouble", c.c_int, ptr, c.c_char_p, c.c_int, c.POINTER(c.c_double))
fc_bool = bind(FC, "FcPatternGetBool", c.c_int, ptr, c.c_char_p, c.c_int, c.POINTER(c.c_int))
surface_create = bind(CAIRO, "cairo_image_surface_create", ptr, c.c_int, c.c_int, c.c_int)
surface_destroy = bind(CAIRO, "cairo_surface_destroy", None, ptr)
context_create = bind(CAIRO, "cairo_create", ptr, ptr)
context_destroy = bind(CAIRO, "cairo_destroy", None, ptr)
face_create = bind(CAIRO, "cairo_ft_font_face_create_for_pattern", ptr, ptr)
face_destroy = bind(CAIRO, "cairo_font_face_destroy", None, ptr)
set_face = bind(CAIRO, "cairo_set_font_face", None, ptr, ptr)
set_size = bind(CAIRO, "cairo_set_font_size", None, ptr, c.c_double)


class Extents(c.Structure):
    _fields_ = [(key, c.c_double) for key in ("x", "y", "width", "height", "advance", "y_advance")]


text_extents = bind(CAIRO, "cairo_text_extents", None, ptr, c.c_char_p, c.POINTER(Extents))


class Fonts:
    def __init__(self, patterns, dpi):
        self.faces = []
        surface = surface_create(0, 1, 1)
        self.context = context_create(surface)
        surface_destroy(surface)
        try:
            for pattern in patterns:
                self.load(pattern, dpi)
        except Exception:
            self.close()
            raise

    def load(self, pattern, dpi):
        query = fc_parse(pattern.encode())
        if not query:
            raise ValueError(f"Invalid font pattern: {pattern}")
        fc_defaults(query)
        fc_substitute(None, query, 0)
        match = fc_match(None, query, c.byref(c.c_int()))
        fc_destroy(query)
        if not match:
            raise ValueError(f"Unable to match font: {pattern}")
        charset, scalable = ptr(), c.c_int(1)
        points, pixels = c.c_double(), c.c_double()
        fc_charset(match, b"charset", 0, c.byref(charset))
        fc_bool(match, b"scalable", 0, c.byref(scalable))
        fc_double(match, b"size", 0, c.byref(points))
        fc_double(match, b"pixelsize", 0, c.byref(pixels))
        size = (points.value * dpi / 72 if scalable.value else pixels.value)
        size = size or pixels.value or points.value * dpi / 72 or 10
        self.faces.append((match, charset, face_create(match), int(size + .5)))

    def __enter__(self):
        return self

    def __exit__(self, *_):
        self.close()

    def close(self):
        context_destroy(self.context)
        for match, _, face, _ in self.faces:
            face_destroy(face)
            fc_destroy(match)

    def measure(self, text, preferred):
        order = list(range(len(self.faces)))
        order[0], order[preferred] = order[preferred], order[0]
        position, ink = 0, 0
        while text:
            char = ord(text[0])
            chosen = next((i for i in order if fc_has_char(self.faces[i][1], char)), None)
            length = 1
            if chosen == preferred:
                charset = self.faces[chosen][1]
                while length < len(text) and fc_has_char(charset, ord(text[length])):
                    length += 1
            if chosen is not None:
                _, _, face, size = self.faces[chosen]
                set_face(self.context, face)
                set_size(self.context, size)
                bounds = Extents()
                text_extents(self.context, text[:length].encode(), c.byref(bounds))
                if bounds.width:
                    ink = max(ink, position + bounds.x + bounds.width)
                position += math.ceil(bounds.advance)
            text = text[length:]
        return position, ink
