module az.core.models.stringlistmodel;

import az.core.az;
import az.core.models.listmodel;
import az.core.model;
import az.core.role;
import std.variant;
import az.core.handler;

class StringListModel: ListModel {
    private string[] data_;

    this(Az parent = null) {
        super(parent);
    }

    this(in string[] strings, Az parent = null) {
        super(parent);

        data_ = strings.dup;
    }

    override @property int rowCount(const ModelIndex parent = new ModelIndex()) const {
        if (parent.isValid) {
            return 0;
        }

        return data_.length;
    }

    override ModelIndex siblingIndex(int row, int column, const ModelIndex index) const {
        if (!index.isValid || column != 0 || row < 0 || row >= data_.length) {
            return new ModelIndex();
        } else {
            return super.createIndex(row, 0);
        }
    }

    override Variant data(const ModelIndex index, Role role = Role.Display) const {
        if (index.row < 0 || index.row >= data_.length) {
            return Variant();
        }

        if (role == Role.Display || role == Role.Edit) {
            return Variant(data_[index.row]);
        }

        return Variant();
    }

    override bool setData(const ModelIndex index, Variant value, Role role = Role.Edit) {
        if (index.row >=0 && index.row < data_.length && (role == Role.Display || role == Role.Edit)) {
            data_[index.row] = value.get!string;

            dataChanged(index, index, [role]);

            return true;
        }

        return false;
    }

    @property const(string[]) stringList() const {
        return data_;
    }

    @property void stringList(const(string[]) strings) {
        beginResetModel();

        data_ = strings.dup;

        endResetModel();
    }
}

unittest {
    StringListModel m = new StringListModel(["asd", "213", "dsf"]);

    assert(m.rowCount == 3);
    assert((m.data(m.index(0, 0)).get!string ~ m.data(m.index(2, 0)).get!string) == "asddsf");
    assert(!m.data(m.index(0, 4)).hasValue);
    assert(!m.hasIndex(4, 0));
    assert(m.index(0, 0) == m.index(2, 0).model.index(0, 0));

    StringListModel m2 = new StringListModel();

    assert(m2.rowCount == 0);

    m2.stringList = m.stringList;

    assert(m2.rowCount == 3);
    assert(m.index(0, 0) != m2.index(0, 0));

    bool changed;

    m2.dataChanged += delegate (const ModelIndex topLeft, const ModelIndex bottomRight, const(Role[]) roles) {
        changed = true;
        assert(topLeft == bottomRight && roles == [Role.Edit] && topLeft.data.get!string == "zzz");
    };

    m2.setData(m2.index(1, 0), Variant("zzz"));
    assert(changed);

    bool beginReset;
    int endReset;

    m.beginResetModel += delegate () {
        beginReset = true;
    };

    m.endResetModel += delegate () {
        endReset++;
    };

    m.endResetModel += delegate () {
        endReset++;
    };

    m.stringList = ["111"];

    assert(beginReset && endReset == 2);
    assert(m.rowCount == 1);
}

