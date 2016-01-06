module az.gui.action;

import az.core.az;
import az.gui.views.menu;
import az.core.model;
import az.gui.actiongroup;

class Action: Az {
    Menu menu_;
    Az[] associated_;

    this(Az parent = null) {
        super(parent);
    }

    @property bool active() const {
        return false;
    }

    @property void active(bool v) {
    }

    @property bool checked() const {
        return false;
    }

    @property void checked(bool c) {
    }

    @property bool checkable() const {
        return false;
    }

    @property void checkable(bool c) {
    }

    @property Az[] associated() {
        return associated_;
    }

    @property string text() const {
        return "";
    }

    @property void text(string s) {
    }

    @property const(ActionGroup) actionGroup() const {
        return null;
    }

    @property const(Menu) menu() const {
        return menu_;
    }
}

