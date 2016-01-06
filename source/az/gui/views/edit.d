module az.gui.views.edit;

import az.core.az;
import az.gui.view;
import az.core.model;

class Edit: View {
    Model dataModel_;
    Model selectionModel_;

    this(Az parent = null) {
        super(parent);
    }
}

