module az.gui.actiongroup;

import az.core.az;
import az.gui.action;

class ActionGroup: Az {
    Action[] actions_;

    this(Az parent = null) {
        super(parent);
    }

    void opOpAssign(string op)(Action a) {
        static if (op == "+") {

        } else static if (op == "-") {
        } else {
            static assert(0, "ActionGroup " ~ op ~ "= " ~ Action.stringof ~ " is not supported");
        }
    }
}

