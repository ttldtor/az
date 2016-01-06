module az.gui.views.combo;

import az.core.az;
import az.gui.view;
import az.core.model;

class Combo: View {
    Model dataModel_;
    Model selectionModel_;

    this(Az parent = null) {
        super(parent);
    }
}

