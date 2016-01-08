module az.string;

import std.string;
import std.algorithm;
import std.array;
import std.format;

string stripMargin(string s, char marginChar = '|') {
    return s.splitLines.map!(line => line.stripLeft.chompPrefix("" ~ marginChar)).join("\n");
}

unittest {
    assert(`|test
            |test2
            |test3`.stripMargin == "test\ntest2\ntest3");

    assert(`$test
            $test2
            $test3`.stripMargin('$') == "test\ntest2\ntest3");
}