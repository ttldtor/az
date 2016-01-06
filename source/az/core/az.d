module az.core.az;

import std.variant;
import std.algorithm;
import std.string;
//import std.bitmanip;
import std.regex;
import std.exception;
import std.conv;

class Az {

private:

    ulong id_;
    string name_;

    invariant() {
        assert(id_ >= 0);
        assert(name_.length > 0);
    }

    Az parent_;

    Az[] children_;
    size_t[ulong] childId2idx_;
    size_t[string] childName2idx_;

    Variant[string] properties_;

    //    mixin(bitfields!(
    //        bool, "isModel_", 1));

    bool isModel_;

public:

    static ulong getId() {
        static ulong currentId = 0;

        return ++currentId;
    }

    this(string name, Az parent = null) {
        id_ = getId();

        if (strip(name) == "") {
            name_ = this.classinfo.name ~ "_" ~ to!string(id_);
        } else {
            name_ = name;
        }

        parent_ = parent;

        if (parent !is null) {
            parent.addChild(this);
        }
    }

    this(Az parent = null) {
        this("", parent);
    }

    @property ulong id() {
        return id_;
    }

    @property string name() {
        return name_;
    }

    @property string name(string newName) {
        if (parent !is null) {
            if (parent.hasChild(newName)) {
                return name_;
            } else {
                parent.childName2idx_[newName] = parent.childName2idx_[name_];
                parent.childName2idx_.remove(name_);
            }
        }

        return name_ = newName;
    }

    @property Az parent() {
        return parent_;
    }

    @property Az parent(Az p) {
        if (p !is null) {
            if (parent_ !is null) {
                if (p.addChild(this)) {
                    parent_.removeChild(this);
                    parent_ = p;
                }
            } else if (!p.hasChild(name)) {
                p.addChild(this, true);
            }
        } else if (parent_ !is null) {
            parent_.removeChild(this, true);
        }

        return parent_;
    }

    @property Az[] children() {
        return children_;
    }

    bool hasChild(ulong id) {
        return (id in childId2idx_) !is null;
    }

    bool hasChild(Az child) {
        return hasChild(child.id);
    }

    bool hasChild(string name) {
        return (name in childName2idx_) !is null;
    }

    bool hasChild(Regex!char rx) {
        foreach (k; childName2idx_.keys) {
            auto cap = matchFirst(k, rx);

            if (!cap.empty) {
                return true;
            }
        }

        return false;
    }

    bool addChild(Az child, bool childControl = false) {
        if (hasChild(child.id) || hasChild(child.name)) {
            return false;
        }

        children_ ~= child;
        childId2idx_[child.id] = children_.length - 1;
        childName2idx_[child.name_] = children_.length - 1;

        if (childControl) {
            child.parent_ = this;
        }

        return true;
    }

    void removeChild(Az child, bool childControl = false) {
        removeChild(child.id, childControl);
    }

    void removeChildByIndex(size_t idx, bool childControl = false) {
        assert(idx < children_.length, "removeChildByIndex: idx out of range");

        childName2idx_.remove(children_[idx].name);
        childId2idx_.remove(children_[idx].id);

        if (childControl) {
            children_[idx].parent = null;
        }

        children_ = remove(children_, idx);
    }

    void removeChild(ulong id, bool childControl = false) {
        if (hasChild(id)) {
            removeChildByIndex(childId2idx_[id], childControl);
        }
    }

    void removeChild(string name, bool childControl = false) {
        if (hasChild(name)) {
            removeChildByIndex(childName2idx_[name], childControl);
        }
    }

    bool hasProperty(string propertyName) {
        return (propertyName in properties_) !is null;
    }

    bool hasProperty(Regex!char rx) {
        foreach (k; properties_.keys) {
            auto cap = matchFirst(k, rx);

            if (!cap.empty) {
                return true;
            }
        }

        return false;
    }

    void setProperty(string name, Variant value) {
        properties_[name] = value;
    }

    void removeProperty(string name) {
        properties_.remove(name);
    }

    @property Variant property(string name) {
        return (hasProperty(name)) ? properties_[name] : Variant();
    }

    bool hasParent(ulong id) {
        return parent_ !is null && parent_.id == id;
    }

    bool hasParent(Az p) {
        return hasParent(p.id);
    }

    bool hasParent(string name) {
        return parent_ !is null && parent_.name == name;
    }

    bool hasParent(Regex!char rx) {
        auto cap = matchFirst(parent_.name, rx);

        if (!cap.empty) {
            return true;
        }

        return false;
    }
};

unittest {
    Az a = new Az("");

    assert(!matchFirst(a.name, regex(`\S+?_\d+?`)).empty);
}

unittest {
    Az a = new Az("a");
    Az b = new Az("b", a);
    Az c = new Az("c", a);

    c.setProperty("me", Variant(c));

    assert(a.hasChild("b"));
    assert(a.hasChild(c));
    assert(a.hasChild(b.id));
    assert(a.hasChild(regex(`C|b`, "i")));
    assert(a.id != b.id);

    a.removeChild(b, true);

    assert(!a.hasChild(b));
    assert(c.hasParent(a));
    assert(c.parent == a);
    assert(!c.hasParent(b.id));
    assert(!c.hasParent(regex(`A`)));

    assert(c.hasProperty("me"));
    assert(c.hasProperty(regex(`Me`, "i")));
    assert(c.property("me").get!(Az).property("me").get!(Az));

    c.removeProperty("me");

    assert(!c.hasProperty("me"));
}