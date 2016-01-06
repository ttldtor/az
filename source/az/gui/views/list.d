module az.gui.views.list;

import az.core.az;
import az.gui.view;
import az.core.model;

class List: View {
    Model dataModel_;
    Model selectionModel_;

    this(Az parent = null) {
        super(parent);
    }
}

