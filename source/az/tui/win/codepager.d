module az.tui.win.codepager;

version (Windows) {
    import core.sys.windows.windows;
    
    class CodePager {
        shared static const UINT codepage;
        
        shared static this() {
            codepage = GetConsoleOutputCP();
            SetConsoleOutputCP(65001);
        }
        
        shared static ~this() {
            SetConsoleOutputCP(codepage);
        }
    };
}