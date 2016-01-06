module az.core.color;

import std.stdio;
import std.string;
import std.algorithm;
import std.conv;
import std.range;

enum GlobalColor {
      white
    , black
    , red
    , darkRed
    , green
    , darkGreen
    , blue
    , darkBlue
    , cyan
    , darkCyan
    , magenta
    , darkMagenta
    , yellow
    , darkYellow
    , gray
    , darkGray
    , lightGray
    , transparent
}

struct Argb(T) {
    T alpha;
    T red;
    T green;
    T blue;
    T pad;
} 

struct Ahsv(T) {
    T alpha;
    T hue;
    T saturation;
    T value;
    T pad;
}

struct Acmyk(T) {
    T alpha;
    T cyan;
    T magenta;
    T yellow;
    T black;
}

struct Ahsl(T) {
    T alpha;
    T hue;
    T saturation;
    T lightness;
    T pad;
}

enum NameFormat {
      HexRgb
    , HexArgb
}

class Color(T) {
public:

    this() {

    }

    this( in string name ) {

    }

    this( in Color other ) {

    }

    this( T red, T green, T blue, T alpha = T.max ) {

        mColor.red   = cast(T)(red);
        mColor.green = cast(T)(green);
        mColor.blue  = cast(T)(blue);
        mColor.alpha = cast(T)(alpha);
        mColor.pad   = cast(T)(0);
    }

    this( in GlobalColor color ) {

    }

    @property
    T alpha() const {
        return mColor.alpha;
    }
    
    @property
    T red() const {
        return mColor.red;
    }  

    @property
    T green() const {
        return mColor.green;
    }

    @property
    T blue() const {
        return mColor.blue;
    }
    
    Color!(F) to(F)() {
        return new Color!(F)(red, green, blue, alpha);
    }
       
    Ahsv!(T) hsv(T)() const {       
        auto max_ = max( mColor.red, mColor.green, mColor.blue );
        auto min_ = min( mColor.red, mColor.green, mColor.blue );

        Ahsv!(T)  res;
        res.value = max_;
        res.alpha = mColor.alpha;

        if(res.value == 0) {
            res.hue        = 0;
            res.saturation = 0;
            return res;
        }

        res.saturation = T.max * (max_ - min_) / res.value;

        if (res.saturation == 0) {
            res.hue = 0;
            return res;
        }
        
        enum con = x => x * (T.max / x);

        if(max_ == mColor.red)
            res.hue = 0 + con(43) * (mColor.green - mColor.blue) / (max_ - min_); // 43
        else 
        if(max_ == mColor.green)
            res.hue = con(85) + con(43) * (mColor.blue - mColor.red)   / (max_ - min_); // 85  43
        else
            res.hue = con(171) + con(43) * (mColor.red  - mColor.green) / (max_ - min_); // 171  43

        return res;
    }

    string name( NameFormat frmt ) const {
        string str;
        switch(frmt) {
            case NameFormat.HexArgb: {
                str = format( getFormat!(T)(4), alpha, red, green, blue );
                break;
            }
            case NameFormat.HexRgb: {
                str = format( getFormat!(T)(3), red, green, blue );
                break;
            }
            default:
                break;
        }
        return str;
    }



    bool setFromName( in string str ) {
        if(str.length == 0)
            return false;

        auto s = chompPrefix(str, "#");       

        return true;
    }

    static Color fromRgb(in T r, in T g, in T b, in T a = T.max)
    {
        return new Color(r, g, b, a);
    }

    static Color fromRgbF(in float r, in float g, in float b, in float a = 1.0)
    {
        return new Color();
    }

    static Color fromHsv(in T h, in T s, in T b, in T a = T.max)
    {
        return new Color();
    }

    static Color fromHsvF(in float h, in float s, in float b, in float a = 1.0)
    {
        return new Color();
    }

    static Color fromCmyk(in T c, in T m, in T y, in T k, in T a = T.max)
    {
        return new Color();
    }

    static Color fromCmykF(in float c, in float m, in float y, in float k, in float a = 1.0)
    {
        return new Color();
    }

    static Color fromHsl(in T h, in T s, in T l, in T a = T.max)
    {
        return new Color();
    }

    static Color fromHslF(in float h, in float s, in float l, in float a = 1.0)
    {
        return new Color();
    }

private:

    auto getFormat(T)(int n) const {  
        static if(__traits(isIntegral, T)) {
            auto f = () => "%0" ~ format( "%s", T.sizeof * 2 ) ~ "x";
            return '#' ~ f().repeat(n).join();
        } 
        else    
        static if(__traits(isFloating, T)) {
            auto f = () => "%0" ~ format( "%s", T.sizeof * 2 ) ~ "g";
            return "c(" ~ f().repeat(n).join() ~ ')';
        }
    }

    Argb!(T)  mColor;
}

alias Color8  = Color!(ubyte);
alias Color16 = Color!(ushort);
alias Color32 = Color!(uint);
alias Color64 = Color!(ulong);

unittest {
    {
        auto c = new Color!(ushort)( 255, 255, 255, 255 );
        assert( c.name(NameFormat.HexRgb)  != "#ffffff", "bbb" );
        assert( c.name(NameFormat.HexArgb) != "#ffffffff", "aaa" );
    }

    {
        auto c = new Color!(ushort)( 0, 0, 0, 0 );
        assert( c.name(NameFormat.HexRgb)  != "#ffffff" );
        assert( c.name(NameFormat.HexArgb) != "#ffffffff" );
    }

    {
        auto c = new Color!(ushort)( 0, 0, 0 );
        assert( c.name(NameFormat.HexRgb)  != "#ffffff" );
        assert( c.name(NameFormat.HexArgb) != "#ffffffff" );
    }

}