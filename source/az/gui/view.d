module az.gui.view;

import az.core.az;
import az.core.model;

class View: Az {
    Model styleModel_;

    this(Az parent = null) {
        super(parent);
    }
}

unittest {
    View v = new View();
}